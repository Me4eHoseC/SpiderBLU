import 'dart:async';

import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../core/NetDevice.dart';
import '../global.dart' as global;

import '../radionet/BasePackage.dart';
import '../radionet/PackageTypes.dart';
import '../radionet/PackagesParser.dart';
import 'BTSTD.dart';
import 'ISTD.dart';

enum StdConnectionType {
  TCPSTD,
  SERIALSTD,
  BTSTD,
  UNDEFINED;
}

class StdInfo {
  StdConnectionType type = StdConnectionType.UNDEFINED;
  ISTD? std;
  bool isConnected = false;
}

class STDConnectionManager {
  int _stdId = 195; // todo remove when correct STD map management implemented

  late void Function(int) stdConnected;

  // BT STD parameters
  bool isUseBT = true;
  String btMacAddress = '00:21:07:00:21:4F'; //todo remove when setting storage implemented

  int btSTDId = -1;
  Timer? btReadTimer;
  Uint8List btBuffer = Uint8List(0);
  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? btSubscription;

  void freeBtConnectionResources() {
    btSTDId = -1;
    btReadTimer?.cancel();
    btReadTimer = null;
    btBuffer = Uint8List(0);
    _connection = null;
    btSubscription = null;
  }

  Timer? connectRoutineTimer;

  void setSTDId(int stdID) {
    _stdId = stdID;
  }

  void startConnectRoutine() {
    restartConnectRoutineTimer(0);
  }

  void restartConnectRoutineTimer([int seconds = 15]){
    connectRoutineTimer?.cancel();
    connectRoutineTimer = Timer(Duration(seconds: seconds), connectRoutine);
  }

  void stopConnectRoutine() {
    connectRoutineTimer?.cancel();
  }

  void connectRoutine() {
    if (_stdId == 0) {
      print("STD ID is set to 0");

      restartConnectRoutineTimer();
      return;
    }

    if (global.std?.stdId == _stdId) {
      print("STD $_stdId is already connected");

      stopConnectRoutine();
      return;
    }

    tryConnectSTD(_stdId);
  }

  void tryConnectSTD(int id) {
    ISTD? std;

    if (std == null && isUseBT && btMacAddress != '') {
      print('Connecting to BT service...');

      btSTDId = id;

      BluetoothConnection.toAddress(btMacAddress).then(onBTConnected).catchError((err) {
        freeBtConnectionResources();
        restartConnectRoutineTimer();
      });
    }
  }

  void onBTConnected(BluetoothConnection value) {
    _connection = value;
    btSubscription = _connection!.input?.listen(onBTReadyRead);

    print("Sending request...");

    // send test package
    var package = BasePackage.makeBaseRequest(btSTDId, PackageType.GET_VERSION);
    var bytes = package.toBytesArray();

    // Add some bytes to wake up STD
    // the amount of bytes should be more than 22
    // otherwise BT STD may not wake up

    Uint8List trash = Uint8List(50);
    Uint8List req = Uint8List(trash.length + bytes.length);

    req.setAll(0, trash);
    req.setAll(trash.length, bytes);

    _connection!.output.add(req);
    _connection!.output.allSent;

    // wait for ready read
    btReadTimer?.cancel();
    btReadTimer = Timer(const Duration(seconds: 10), onBTReadTimerTimeout);
  }

  void onBTReadyRead(Uint8List data) {
    print("Reading BT data...");

    btReadTimer?.cancel();

    Uint8List tmp = Uint8List(btBuffer.length + data.length);
    tmp.setAll(0, btBuffer);
    tmp.setAll(btBuffer.length, data);
    btBuffer = tmp;

    BasePackage? receivedPackage;
    bool mayHaveOneMorePackage = true;
    while (mayHaveOneMorePackage) {
      var ref = Reference<Uint8List>(btBuffer);
      var pair = PackagesParser.tryFindAndParsePackage(ref);

      receivedPackage = pair.first;
      mayHaveOneMorePackage = pair.second;

      btBuffer = ref.value;

      if (receivedPackage != null) break;
    }

    if (receivedPackage == null) {
      btReadTimer = Timer(const Duration(seconds: 10), onBTReadTimerTimeout);
      return;
    }

    var isSTD = checkStdPackage(btSTDId, receivedPackage);
    if (isSTD) {
      print("BT STD connected");

      StdInfo info = StdInfo();
      info.std = BTSTD(btSTDId, btMacAddress, _connection);
      info.type = StdConnectionType.BTSTD;

      newSTDConnected(info);
    } else {
      print("Wrong BT STD ID");

      restartConnectRoutineTimer();
    }

    freeBtConnectionResources();
  }

  void onBTReadTimerTimeout() {
    print('No package received from BT connection');

    freeBtConnectionResources();
    restartConnectRoutineTimer();
  }

  bool checkStdPackage(int stdId, BasePackage? package) {
    if (package == null) return false;

    print("Checking hops");

    // if id presents in hops and it is last
    int stdIndex = -1;
    bool isHopsZeros = true;
    for (int i = 0; i < package.getHopsSize(); ++i) {
      var hop = package.getHop(i);
      if (hop == stdId) stdIndex = i;
      if (hop != 0) isHopsZeros = false;
    }

    // the last one in hops is connected to PC via cable
    if (stdIndex != -1) {
      for (int i = stdIndex + 1; i < package.getHopsSize(); ++i) {
        var hop = package.getHop(i);
        if (hop != 0) return false; // std is NOT the last in hops
      }

      return true; // std is the last in hops
    }

    // check whether device with id is connected directly via cable
    if (isHopsZeros && package.getSender() == stdId) {
      print("STD confirmed via sender ID");
      return true;
    }

    return false;
  }

  void newSTDConnected(StdInfo info) {
    var std = info.std;

    if (std == null) return;
    if (global.std != null) return;

    global.std = std;
    global.stdInfo = info;

    std.onConnected = () {
      stdConnected(global.std!.stdId);

      // todo implement emit stdStateChanged(device->getStdId(), device->isValid());

      global.stdConnectionManager.stopConnectRoutine();
    };

    std.onDisconnected = () {
      var stdId = global.std?.stdId;

      global.std = null;
      global.stdInfo = StdInfo();

      var device = global.itemsMan.get<NetDevice>(stdId ?? 0);
      if (device != null) {
        device.state = NDState.Offline;
        global.pageWithMap.deactivateMapMarker(stdId!);
        global.deviceParametersPage.addProtocolLine('Device #$stdId offline');
      }

      // todo implement emit stdStateChanged(device->getStdId(), device->isValid());

      global.stdConnectionManager.startConnectRoutine();
    };

    std.onReadyRead = (Uint8List data) {
      global.std?.lastActiveTime = DateTime.now();
      global.packagesParser.addData(data);
    };

    if (std is BTSTD) {
      btSubscription?.onData(std.onReadyRead);
      btSubscription?.onDone(std.onDone);
      btSubscription?.onError(std.onError);
    }

    std.connect();
  }
}
