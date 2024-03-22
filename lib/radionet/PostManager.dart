import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'BasePackage.dart';

import '../global.dart' as global;

class PackageSendingStatus {
  int transactionId = 0;
  int receiver = 0;
  int attemptNumber = 0;
  int totalAttemptNumber = 0;
}

enum PostType {
  Package,
  Poll,
  Alarm,
  File,
  Network,
  Response;
}

enum RequestPriority {
  Poll,
  Alarm,
  Package,
  File,
  Network,
  Response;
}

class Request {
  int transactionId = -1;
  BasePackage? package;
  late PostType postType;
  int totalAttemptNumber = -1;
  int attemptNumber = -1;
  int priority = -1;
  int offsetMs = 0;
  int wobbleMs = 0;
  bool isInterleavable = true;
}

class PostManager {
  bool keepRunning = true;

  static int mandatoryPauseMs = 60;

  final Random _random = Random();

  int _transactionIdCounter = 0;
  int _packagesIdCounter = 0;

  final List<global.Pair<int, int>> _transactions = [];

  PostManager() {
    _packagesIdCounter = _random.nextInt(32767) + 1;
  }

  void _send() {
    _offsetTimer?.cancel();

    if (!keepRunning) return;

    var req = _currentRequest.package;
    if (req == null) {
      bool isEmpty = _requests.isEmpty;
      if (isEmpty) {
        _currentRequest = Request();

        _responses.clear();
        _transactions.clear();
        _currentRequestId = -1;
      } else {
        _currentRequest = _getRequest();
        Timer.run(_send);
      }

      return;
    }

    bool hasResponse = false;
    if (_currentRequest.postType != PostType.Response) {
      hasResponse = _checkResponse(req);
    }

    if (hasResponse) {
      _closeTransaction(req.getId());
      _currentRequest = _getRequest();
      Timer.run(_send);

      return;
    }

    if (_doInterleave) {
      _doInterleave = false;

      _requests.add(_currentRequest);

      _currentRequest = _getRequest();
      Timer.run(_send);

      return;
    }

    if (_currentRequest.attemptNumber >= _currentRequest.totalAttemptNumber) {
      if (_currentRequest.postType != PostType.Response) {
        int tid = _closeTransaction(req.getId());
        Timer.run(() => global.packageProcessor.ranOutOfSendAttempts(req, tid));
      }

      _currentRequest = _getRequest();
      Timer.run(_send);

      return;
    }

    _currentRequest.attemptNumber += 1;

    if (_currentRequest.postType != PostType.Response) {
      PackageSendingStatus sendingStatus = PackageSendingStatus();
      sendingStatus.transactionId = _currentRequest.transactionId;
      sendingStatus.receiver = req.getReceiver();
      sendingStatus.attemptNumber = _currentRequest.attemptNumber;
      sendingStatus.totalAttemptNumber = _currentRequest.totalAttemptNumber;

      Timer.run(() => global.packageProcessor.packageSendingAttempt(sendingStatus));
    }

    if (!req.isAnswer()) {
      req.setId(_getNextPackageId());
    }

    if (_currentRequest.postType != PostType.Response) {
      _openTransaction(req.getId());
    }

    _currentRequestId = req.getId();

    DateTime currentSendTime = DateTime.now();
    var diffMs = currentSendTime.millisecondsSinceEpoch - _previousSendTime.millisecondsSinceEpoch;

    if (diffMs < mandatoryPauseMs) {
      print("Extra pause ${mandatoryPauseMs - diffMs}ms "
          "to complete mandatory pause ${mandatoryPauseMs}ms");
      sleep(Duration(milliseconds: mandatoryPauseMs - diffMs));
    }

    global.std!.write(req.toBytesArray());

    _previousSendTime = DateTime.now();

    _doInterleave = _currentRequest.isInterleavable;

    var wobble = _random.nextInt(_currentRequest.wobbleMs) + 1;
    var offset = _currentRequest.offsetMs + wobble;

    print("Time offset between packages: ${offset}ms ");
    _offsetTimer = Timer(Duration(milliseconds: offset), _send);
  }

  int _getNextTransactionId() {
    if (_transactionIdCounter < 0) {
      _transactionIdCounter = 0;
    }
    _transactionIdCounter += 1;

    return _transactionIdCounter;
  }

  int _getNextPackageId() {
    if (BasePackage.isAnswerId(_packagesIdCounter)) {
      _packagesIdCounter = 0;
    }

    _packagesIdCounter += 1;

    return _packagesIdCounter;
  }

  void _openTransaction(int packageId) {
    _transactions.add(global.Pair(_currentRequest.transactionId, packageId));
  }

  int _closeTransaction(int packageId) {
    var index = _transactions.indexWhere((el) => el.second == packageId);

    if (index == -1) {
      return -1;
    }
    var transactionId = _transactions[index].first;
    _transactions.removeWhere((el) => el.first == transactionId);

    return transactionId;
  }

  int _currentRequestId = -1;
  Request _currentRequest = Request();
  List<Request> _requests = [];

  List<BasePackage> _responses = [];
  Timer? _offsetTimer;

  bool _doInterleave = false;

  Request _getRequest() {
    if (_requests.isEmpty) {
      return Request();
    }

    int _previousDevice = -1;
    if (_currentRequest.package != null) {
      _previousDevice = _currentRequest.package!.getPartner();
    }

    int index = 0;
    int maxPriority = _requests.first.priority;
    for (int i = 1; i < _requests.length; i++) {
      var pt = _requests[i].priority;
      if (pt < maxPriority) continue;

      if (pt > maxPriority) {
        maxPriority = pt;
        index = i;
        continue;
      }

      int selectedDevice = 0;
      if (_requests[index].package != null) {
        selectedDevice = _requests[index].package!.getPartner();
      }

      int itDevice = 0;
      if (_requests[i].package != null) {
        itDevice = _requests[i].package!.getPartner();
      }

      if (selectedDevice == _previousDevice && itDevice != _previousDevice) {
        maxPriority = pt;
        index = i;
      }
    }
    var req = _requests.removeAt(index);
    return req;
  }

  bool _checkResponse(BasePackage request) {
    int invId = request.getInvId();
    bool hasResponse = false;

    for (int i = 0; i < _responses.length; ++i) {
      if (_responses[i].getId() == invId && _responses[i].getPartner() == request.getPartner()) {
        hasResponse = true;
        _responses.removeAt(i);
        break;
      }
    }

    return hasResponse;
  }

  DateTime _previousSendTime = DateTime.now();

  static const int _packAttemptNumber = 6;
  static const int _maxAttemptNumber = 30;

  static const int _packMsOffset = 1800; // Time period between packages
  static const int _packWobbleMs = 300; // Range of random time period change

  static const int _pollMsOffset = 2500; // Time period between poll packages
  static const int _pollWobbleMs = 800; // Range of random time period change

  // Should be executed in the same thread as PostManager instance
  void sendAcknowledge(BasePackage acknowledge) {
    global.std!.write(acknowledge.toBytesArray());
  }

  int sendPackage(BasePackage? package, [PostType type = PostType.Package, int attemptNumber = -1]) {
    if (package == null) {
      return -1;
    }

    int transactionId = 0;

    if (type != PostType.Response) {
      transactionId = _getNextTransactionId();
    }

    int offsetMs = _packMsOffset;
    int wobbleMs = _packWobbleMs;
    int attemptsCount = _packAttemptNumber;
    bool isInterleavable = false;

    RequestPriority priority;
    switch (type) {
      case PostType.Package:
        {
          priority = RequestPriority.Package;
          isInterleavable = true;
          break;
        }
      case PostType.Poll:
        {
          priority = RequestPriority.Poll;
          offsetMs = _pollMsOffset;
          wobbleMs = _pollWobbleMs;
          isInterleavable = true;
          break;
        }
      case PostType.Alarm:
        {
          priority = RequestPriority.Alarm;
          break;
        }
      case PostType.File:
        {
          priority = RequestPriority.File;
          break;
        }
      case PostType.Network:
        {
          priority = RequestPriority.Network;
          offsetMs = _pollMsOffset;
          wobbleMs = _pollWobbleMs;
          break;
        }
      case PostType.Response:
        {
          priority = RequestPriority.Response;
          break;
        }
      default:
        {
          priority = RequestPriority.Package;
          break;
        }
    }

    if (attemptNumber > 0) {
      if (attemptNumber > _maxAttemptNumber) {
        attemptNumber = _maxAttemptNumber;
      }
      attemptsCount = attemptNumber;
    }

    Request req = Request();
    req.transactionId = transactionId;
    req.postType = type;
    req.package = package;
    req.attemptNumber = 0;
    req.totalAttemptNumber = attemptsCount;
    req.priority = priority.index;
    req.offsetMs = offsetMs;
    req.wobbleMs = wobbleMs;
    req.isInterleavable = isInterleavable;

    _requests.add(req);

    if (_currentRequestId == -1) {
      _currentRequestId = package.getId();
      Timer.run(_send);
    }

    return transactionId;
  }

  void responseReceived(BasePackage? response) {
    if (response == null) {
      return;
    }

    _responses.insert(0, response);

    if (_currentRequestId == response.getInvId()) {
      Timer.run(_send);
    }
  }

  int getRequestTransactionId(int packageId) {
    var it = _transactions.indexWhere((element) => element.second == packageId);
    int transactionId = -1;
    if (it != -1) {
      transactionId = _transactions[it].first;
    }
    return transactionId;
  }
}
