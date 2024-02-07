import 'dart:async';

import 'package:projects/RoutesManager.dart';
import 'package:projects/STDConnectionManager.dart';
import 'package:projects/core/MCD.dart';

import 'AllEnum.dart';
import 'BasePackage.dart';
import 'NetCommonPackages.dart';
import 'PostManager.dart';
import 'core/NetDevice.dart';
import "global.dart" as global;

class PollManager {
  void startPollRoutines() {
    if (routinesStarted) return;
    routinesStarted = true;

    _stdPollTimer = Timer(const Duration(milliseconds: stdPollIntervalMs), _runStdPoll);
    _regularPollTimer = Timer(const Duration(milliseconds: regularPollIntervalMs), _runRegularPoll);

    _runInitPoll();
  }

  void runSavePoll() {
    var devices = getDevicesList();
    var pollType = PollType.SavePoll;

    _removePollPackages(pollType);
    _pollStarted(pollType);

    for (var device in devices) {
      var req = BasePackage.makeBaseRequest(device.id, PackageType.SAVE_PARAMETERS);
      var tid = global.postManager.sendPackage(req, PostType.Poll, _SavePollAttemptsNumber);

      if (tid == -1) {
        continue;
      }

      pollIds[tid] = pollType;
    }
  }

  void runAfterAlarmPoll(int deviceId) {
    var timePackage = _makeTimePackage(deviceId);
    var tid = global.postManager.sendPackage(timePackage, PostType.Poll, _AfterAlarmPollAttemptsNumber);

    if (tid == -1) {
      return;
    }

    pollIds[tid] = PollType.AfterAlarmPoll;
  }

  // Returns true if response is answer for poll package
  bool packageReceived(BasePackage response, [int pollId = -1]) {
    var deviceId = response.getPartner();

    for (int i = 0; i < response.getHopsSize(); ++i) {
      var hop = response.getHop(i);
      if (hop == 0) break;

      _deviceOnlineConfirmed(hop);
    }

    _deviceOnlineConfirmed(deviceId);

    var pollType = pollIds[pollId];
    if (pollType == null) return false;

    pollIds.remove(pollId);

    if (pollType == PollType.StdPoll) {
      stdPollRounds.remove(deviceId);
      return true;
    }

    if (pollType == PollType.AfterAlarmPoll) return true;

    if (!_hasOneMorePollPackage(pollType)) _pollFinished(pollType);

    return true;
  }

  // Returns true if pollPackage is a poll package
  bool packageNotSent(BasePackage pollPackage, int pollId) {
    var pollType = pollIds[pollId];

    if (pollType == null) return false;

    var deviceId = pollPackage.getPartner();

    pollIds.remove(pollId);

    var device = global.itemsMan.get<NetDevice>(deviceId);
    if (device == null) return true;

    if (pollType == PollType.StdPoll) {
      if (stdPollRounds[deviceId]! < stdPollRoundsNumber) {
        _checkAndRebootStd(deviceId);
        _sendPackagesToStd(deviceId);
      } else {
        stdPollRounds.remove(deviceId);
        if (device.isOnline) {
          _deviceStatusChanged(deviceId, false);
        }
      }

      return true;
    }

    if (pollType == PollType.AfterAlarmPoll) {
      // if was online, but now not responding
      if (device.isOnline) {
        _deviceStatusChanged(device.id, false);
      }

      return true;
    }

    var isOnline = device.wasActiveDuringMs(deviceInactivityIntervalMs);

    if (!isOnline) {
      if (device.isOnline) {
        _deviceStatusChanged(device.id, false);
      }

      if(_offlineDevicesPollTimer != null){
        _offlineDevicesPollTimer!.cancel();
      }

      _offlineDevicesPollTimer = Timer(const Duration(milliseconds: offlineDevicesPollIntervalMs), _runOfflineDevicesPoll);
    }

    if (!_hasOneMorePollPackage(pollType)) _pollFinished(pollType);

    return true;
  }

  void _pollStarted(PollType pollType) {
    global.deviceParametersPage.addProtocolLine('Poll started: ${pollTypeToName(pollType)}');

  }

  void _pollFinished(PollType pollType) {
    global.deviceParametersPage.addProtocolLine('Poll finished: ${pollTypeToName(pollType)}');
  }

  void _deviceStatusChanged(int deviceId, bool isOnline) {
    var device = global.itemsMan.get<NetDevice>(deviceId);
    if (device == null) return;

    if (isOnline){
      device.state = NDState.Online;
      global.pageWithMap.activateMapMarker(deviceId);
      global.deviceParametersPage.addProtocolLine('Device #$deviceId online');

    } else {
      device.state = NDState.Offline;
      global.pageWithMap.deactivateMapMarker(deviceId);
      global.deviceParametersPage.addProtocolLine('Device #$deviceId offline');

    }
  }

  void _checkAndRebootStd(int stdId) {
    //todo call connectionmanger check and reboot std
  }

  void _runInitPoll() {
    var devices = getDevicesList();
    var pollType = PollType.InitPoll;

    _removePollPackages(pollType);
    _pollStarted(pollType);

    for (var device in devices) {
      var timePackage = _makeTimePackage(device.id);
      var tid = global.postManager.sendPackage(timePackage, PostType.Poll, _InitPollAttemptsNumber);

      if (tid == -1) {
        continue;
      }

      pollIds[tid] = pollType;
    }
  }

  void _runRegularPoll() {
    _offlineDevicesPollTimer?.cancel();
    _removePollPackages(PollType.OfflineDevicesPoll);

    var devices = getDevicesList();
    var pollType = PollType.RegualrPoll;

    _removePollPackages(pollType);
    _pollStarted(pollType);

    for (var device in devices) {
      if (device is MCD) continue;

      if (!device.wasActiveDuringMs(deviceInactivityIntervalMs)) {
        var timePackage = _makeTimePackage(device.id);
        var tid = global.postManager.sendPackage(timePackage, PostType.Poll, _RegularPollAttemptsNumber);

        if (tid == -1) {
          continue;
        }

        pollIds[tid] = pollType;
      }
    }
    _regularPollTimer = Timer(const Duration(milliseconds: regularPollIntervalMs), _runRegularPoll);
  }

  void _runOfflineDevicesPoll() {
    var devices = getDevicesList();
    var pollType = PollType.OfflineDevicesPoll;

    _removePollPackages(pollType);
    _pollStarted(pollType);

    bool anyPackageSended = false;
    for (var device in devices) {
      if (device is MCD) continue;

      if (device.isOnline) continue;

      var timePackage = _makeTimePackage(device.id);
      var tid = global.postManager.sendPackage(timePackage, PostType.Poll, _OfflineDevicesPollAttemptsNumber);

      if (tid == -1) {
        continue;
      }

      pollIds[tid] = pollType;
      anyPackageSended = true;
    }

    if (anyPackageSended) {
      _offlineDevicesPollTimer = Timer(const Duration(milliseconds: offlineDevicesPollIntervalMs), _runOfflineDevicesPoll);
    }
  }

  void _runStdPoll() {
    _stdPollTimer = Timer(const Duration(milliseconds: stdPollIntervalMs), _runStdPoll);

    if (global.std == null) return;

    var id = global.std!.stdId;

    // TODO: uncomment when stdConnectionManager added
    /* var hasStd = STDConnectionManager().hasStd(id);
      if (!hasStd) continue;*/

    var lastTime = global.std!.lastActiveTime;
    var diff = lastTime.difference(DateTime.now());
    if (diff.inMilliseconds < stdPollIntervalMs) return;

    // check if previous algorithm has finished, otherwise skip
    if (stdPollRounds.containsKey(id)) return;

    stdPollRounds[id] = 0;
    _sendPackagesToStd(id);

  }

  TimePackage _makeTimePackage(int receiver) {
    var timePackage = TimePackage();
    timePackage.setTime(DateTime.now());
    timePackage.setSender(RoutesManager.getLaptopAddress());
    timePackage.setReceiver(receiver);
    return timePackage;
  }

  void _deviceOnlineConfirmed(int deviceId) {
    var device = global.itemsMan.get<NetDevice>(deviceId);
    if (device == null) return;

    device.confirmIsActiveNow();

    if (!device.isOnline) {
      _deviceStatusChanged(device.id, true);
    }
  }

  bool _hasOneMorePollPackage(PollType pollType) {
    return pollIds.containsValue(pollType);
  }

  void _removePollPackages(PollType pollType) {
    pollIds.removeWhere((key, value) => value == pollType);
  }

  void _sendPackagesToStd(int stdId) {
    if (stdId == 0) return;

    var req = BasePackage.makeBaseRequest(stdId, PackageType.GET_MODEM_FREQUENCY);
    var tid = global.postManager.sendPackage(req, PostType.Poll, _StdPollAttemptsNumber);

    if (tid == -1) {
    return;
    }

    var round = stdPollRounds[stdId] ?? 0;
    stdPollRounds[stdId] = round + 1;
    pollIds[tid] = PollType.StdPoll;
  }

  static const int _InitPollAttemptsNumber = 6,
      _SavePollAttemptsNumber = 12,
      _RegularPollAttemptsNumber = 12,
      _OfflineDevicesPollAttemptsNumber = 4,
      _AfterAlarmPollAttemptsNumber = 12,
      _StdPollAttemptsNumber = 4;

  Map<int, PollType> pollIds = {};

  Map<int, int> stdPollRounds = {};
  static const int stdPollRoundsNumber = 3;

  bool routinesStarted = false;

  Timer? _stdPollTimer;
  Timer? _regularPollTimer;
  Timer? _offlineDevicesPollTimer;

  static const int deviceInactivityIntervalMs = 25 * 60 * 1000; // 25 minutes

  static const int stdPollIntervalMs = 30700; // 30.7 seconds
  static const int regularPollIntervalMs = 2 * 60 * 60 * 1000; // 2 hours
  static const int offlineDevicesPollIntervalMs = 20 * 60 * 1000; // 20 minutes

  List<NetDevice> getDevicesList() {
    var devices = global.itemsMan.getAll<NetDevice>();
    devices.sort((var lhs, var rhs) => lhs.id.compareTo(rhs.id));
    return devices;
  }
}

enum PollType {
  InitPoll,
  SavePoll,
  RegualrPoll,
  OfflineDevicesPoll,
  AfterAlarmPoll,
  StdPoll;
}

String pollTypeToName(PollType pollType) {
  switch (pollType) {
    case PollType.RegualrPoll:
      return "Regular poll";
    case PollType.InitPoll:
      return "Init poll";
    case PollType.SavePoll:
      return "Save poll";
    case PollType.AfterAlarmPoll:
      return "Alarm poll";
    case PollType.OfflineDevicesPoll:
      return "Offline poll";
    case PollType.StdPoll:
      return "STD poll";
    default:
      return "";
  }
}
