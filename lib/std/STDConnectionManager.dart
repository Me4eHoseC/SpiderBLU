import 'dart:async';

import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:usb_serial/usb_serial.dart';

import '../core/NetDevice.dart';
import '../global.dart' as global;

import '../radionet/BasePackage.dart';
import '../radionet/PackageTypes.dart';
import '../radionet/PackagesParser.dart';
import 'BTSTD.dart';
import 'ISTD.dart';
import 'SerialSTD.dart';

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

  String getConnectionType() {
    switch (type) {
      case StdConnectionType.TCPSTD:
        return "TCP";
      case StdConnectionType.SERIALSTD:
        return "COM";
      case StdConnectionType.BTSTD:
        return "BT";

      case StdConnectionType.UNDEFINED:
        return "";
    }
  }
}

class STDConnectionManager {
  int _stdId = 0;

  late void Function(int) stdConnected;

  // BT STD parameters
  bool isUseBT = true;
  String btMacAddress = '00:21:07:00:21:4F'; //todo remove when setting storage implemented

  int _btSTDId = -1;
  Timer? _btReadTimer;
  Uint8List _btBuffer = Uint8List(0);
  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _btSubscription;

  bool isUseSerial = true;
  String serialManName = 'FTDI';
  int serialVID = 1027;
  int _serialSTDId = -1;
  Timer? _serialReadTimer;
  Uint8List _serialBuffer = Uint8List(0);
  StreamSubscription<Uint8List>? _serialSubscription;
  UsbPort? _serialPort;

  void _freeBtConnectionResources() {
    _btSTDId = -1;
    _btReadTimer?.cancel();
    _btReadTimer = null;
    _btBuffer = Uint8List(0);
    _connection = null;
    _btSubscription = null;
  }

  void _freeSerialConnectionResources() {
    _serialSTDId = -1;
    _serialReadTimer?.cancel();
    _serialReadTimer = null;
    _serialBuffer = Uint8List(0);
    _serialSubscription = null;
    _serialPort = null;
  }

  Timer? _connectRoutineTimer;

  void setSTDId(int stdID) {
    _stdId = stdID;
  }

  void startConnectRoutine() {
    _restartConnectRoutineTimer(0);
  }

  void _restartConnectRoutineTimer([int seconds = 15]) {
    _connectRoutineTimer?.cancel();
    _connectRoutineTimer = Timer(Duration(seconds: seconds), _connectRoutine);
  }

  void stopConnectRoutine() {
    _connectRoutineTimer?.cancel();
  }

  void _connectRoutine() {
    if (_stdId == 0) {
      print("STD ID is set to 0");

      _restartConnectRoutineTimer();
      return;
    }

    if (global.std?.stdId == _stdId) {
      print("STD $_stdId is already connected");

      stopConnectRoutine();
      return;
    }

    _tryConnectSTD(_stdId);
  }

  void _tryConnectSTD(int id) {
    ISTD? std;

    if (std == null && _connection == null && isUseBT && btMacAddress != '') {
      print('Connecting to BT service...');

      _btSTDId = id;

      BluetoothConnection.toAddress(btMacAddress).then(_onBTConnected).catchError((err) {
        print(err);
        _freeBtConnectionResources();
        _restartConnectRoutineTimer();
      });
    }

    if (std == null && _serialPort == null && isUseSerial && serialManName != '' && serialVID != 0) {
      print('Connecting to serial port...');

      _serialSTDId = id;

      _getSerialPort(serialManName, serialVID).then(_onSerialPortFound);
    }
  }

  Future<UsbPort?> _getSerialPort(String portManName, int portVID) async {
    var devices = await UsbSerial.listDevices();
    if (devices.isEmpty) return null;

    UsbDevice? usbDevice;
    for (var device in devices) {
      if (device.manufacturerName == portManName && device.vid == portVID) {
        usbDevice = device;
      }
    }

    if (usbDevice == null) return null;

    var port = await usbDevice.create();
    if (port == null) return null;

    bool openResult = await port.open();
    if (!openResult) {
      print("Failed to open serial port");
      return null;
    }

    await port.setDTR(true);
    await port.setRTS(true);

    port.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    return port;
  }

  void _onSerialPortFound(UsbPort? port) {
    if (port == null) {
      _restartConnectRoutineTimer();
      return;
    }

    _serialPort = port;

    _serialSubscription = port.inputStream!.listen(_onSerialReadyRead);

    print("Sending request...");

    // send test package
    var package = BasePackage.makeBaseRequest(_serialSTDId, PackageType.GET_VERSION);
    var bytes = package.toBytesArray();

    // Add some bytes to wake up STD
    // the amount of bytes should be more than 22
    // otherwise BT STD may not wake up

    Uint8List trash = Uint8List(50);
    Uint8List req = Uint8List(trash.length + bytes.length);

    req.setAll(0, trash);
    req.setAll(trash.length, bytes);

    port.write(req);
    // wait for ready read
    _serialReadTimer?.cancel();
    _serialReadTimer = Timer(const Duration(seconds: 10), _onSerialReadTimerTimeout);
  }

  void _onSerialReadyRead(Uint8List data) {
    print("Reading Serial data...");

    _serialReadTimer?.cancel();

    Uint8List tmp = Uint8List(_serialBuffer.length + data.length);
    tmp.setAll(0, _serialBuffer);
    tmp.setAll(_serialBuffer.length, data);
    _serialBuffer = tmp;

    BasePackage? receivedPackage;
    bool mayHaveOneMorePackage = true;
    while (mayHaveOneMorePackage) {
      var ref = Reference<Uint8List>(_serialBuffer);
      var pair = PackagesParser.tryFindAndParsePackage(ref);

      receivedPackage = pair.first;
      mayHaveOneMorePackage = pair.second;

      _serialBuffer = ref.value;

      if (receivedPackage != null) break;
    }

    if (receivedPackage == null) {
      _serialReadTimer = Timer(const Duration(seconds: 10), _onSerialReadTimerTimeout);
      return;
    }

    var isSTD = _checkStdPackage(_serialSTDId, receivedPackage);
    if (isSTD) {
      print("Serial STD connected");

      StdInfo info = StdInfo();
      info.std = SerialSTD(_serialSTDId, _serialPort);
      info.type = StdConnectionType.SERIALSTD;

      _newSTDConnected(info);
    } else {
      print("Wrong Serial STD ID");

      _restartConnectRoutineTimer();
    }

    _freeSerialConnectionResources();
  }

  void _onSerialReadTimerTimeout() {
    print('No package received from serial connection');
    _freeSerialConnectionResources();
    _restartConnectRoutineTimer();
  }

  void _onBTConnected(BluetoothConnection value) {
    _connection = value;
    _btSubscription = _connection!.input?.listen(_onBTReadyRead);

    print("Sending request...");

    // send test package
    var package = BasePackage.makeBaseRequest(_btSTDId, PackageType.GET_VERSION);
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
    _btReadTimer?.cancel();
    _btReadTimer = Timer(const Duration(seconds: 10), _onBTReadTimerTimeout);
  }

  void _onBTReadyRead(Uint8List data) {
    print("Reading BT data...");

    _btReadTimer?.cancel();

    Uint8List tmp = Uint8List(_btBuffer.length + data.length);
    tmp.setAll(0, _btBuffer);
    tmp.setAll(_btBuffer.length, data);
    _btBuffer = tmp;

    BasePackage? receivedPackage;
    bool mayHaveOneMorePackage = true;
    while (mayHaveOneMorePackage) {
      var ref = Reference<Uint8List>(_btBuffer);
      var pair = PackagesParser.tryFindAndParsePackage(ref);

      receivedPackage = pair.first;
      mayHaveOneMorePackage = pair.second;

      _btBuffer = ref.value;

      if (receivedPackage != null) break;
    }

    if (receivedPackage == null) {
      _btReadTimer = Timer(const Duration(seconds: 10), _onBTReadTimerTimeout);
      return;
    }

    var isSTD = _checkStdPackage(_btSTDId, receivedPackage);
    if (isSTD) {
      print("BT STD connected");

      StdInfo info = StdInfo();
      info.std = BTSTD(_btSTDId, btMacAddress, _connection);
      info.type = StdConnectionType.BTSTD;

      _newSTDConnected(info);
    } else {
      print("Wrong BT STD ID");

      _restartConnectRoutineTimer();

      _connection?.close();
    }

    _freeBtConnectionResources();
  }

  void _onBTReadTimerTimeout() {
    print('No package received from BT connection');

    _connection?.close();

    _freeBtConnectionResources();
    _restartConnectRoutineTimer();
  }

  bool _checkStdPackage(int stdId, BasePackage? package) {
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

  void _newSTDConnected(StdInfo info) {
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

    var subscription = _btSubscription;
    if (std is SerialSTD) subscription = _serialSubscription;

    subscription?.onData(std.onReadyRead);
    subscription?.onDone(std.onDone);
    subscription?.onError(std.onError);

    std.connect();
  }
}
