import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
import 'TCPSTD.dart';

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

  bool connectRoutineIsRunning = false;

  // BT STD parameters
  bool isUseBT = true;
  String btMacAddress = '';

  int _btSTDId = -1;
  Timer? _btReadTimer;
  Uint8List _btBuffer = Uint8List(0);
  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _btSubscription;

  bool isUseSerial = true;
  String serialManName = '';
  int serialVID = 0;
  int _serialSTDId = -1;
  Timer? _serialReadTimer;
  Uint8List _serialBuffer = Uint8List(0);
  StreamSubscription<Uint8List>? _serialSubscription;
  UsbPort? _serialPort;

  bool isUseTCP = true;

  String IPAddress = '';
  int IPPort = 0;
  int _tcpSTDId = -1;
  Timer? _tcpReadTimer;
  Uint8List _tcpBuffer = Uint8List(0);
  StreamSubscription<Uint8List>? _tcpSubscription;
  Socket? _tcpSocket;

  global.SettingsForSave? settingsForSave;

  void initSaveSettings() {
    settingsForSave = global.SettingsForSave(isUseBT, btMacAddress, isUseSerial, serialManName, serialVID, isUseTCP, IPAddress, IPPort);
  }

  Future<void> loadSettingsFromFile() async {
    global.getPermission();
    var dir = global.pathToProject;
    File file = File('${dir.path}/settings.json');
    if (!await file.exists()) {
      await file.create(recursive: true);
      return;
    }
    final data = await file.readAsString();
    final decoded = json.decode(data);
    for (final item in decoded) {
      isUseBT = global.SettingsForSave.fromJson(item).btFlag;
      if (global.SettingsForSave.fromJson(item).btMacAddressSave != ''){
        btMacAddress = global.SettingsForSave.fromJson(item).btMacAddressSave!;
      }

      isUseSerial = global.SettingsForSave.fromJson(item).serialFlag;
      if (global.SettingsForSave.fromJson(item).serialManNameSave != ''){
        serialManName = global.SettingsForSave.fromJson(item).serialManNameSave!;
      }
      if (global.SettingsForSave.fromJson(item).serialVIDSave != null){
        serialVID = global.SettingsForSave.fromJson(item).serialVIDSave!;
      }

      isUseTCP = global.SettingsForSave.fromJson(item).tcpFlag;
      if (global.SettingsForSave.fromJson(item).IPAddressSave != ''){
        IPAddress = global.SettingsForSave.fromJson(item).IPAddressSave!;
      }
      if (global.SettingsForSave.fromJson(item).IPPortSave != null){
        IPPort = global.SettingsForSave.fromJson(item).IPPortSave!;
      }
    }
  }

  void saveSettingsInFile() async {
    initSaveSettings();
    global.getPermission();
    var dir = global.pathToProject;
    File file = File('${dir.path}/settings.json');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    var bufJson = '[';
    bufJson += json.encode(settingsForSave);
    bufJson += ']';
    print (bufJson);
    await file.writeAsString(bufJson);
  }

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

  void _freeTCPConnectionResources() {
    _tcpSTDId = -1;
    _tcpReadTimer?.cancel();
    _tcpReadTimer = null;
    _tcpBuffer = Uint8List(0);
    _tcpSubscription = null;
    _tcpSocket = null;
  }

  Timer? _connectRoutineTimer;

  void setSTDId(int stdID) {
    _stdId = stdID;
  }

  void startConnectRoutine() {
    if (connectRoutineIsRunning) return;

    connectRoutineIsRunning = true;

    _restartConnectRoutineTimer(0);
  }

  void _restartConnectRoutineTimer([int seconds = 15]) {
    if (_connection != null || _tcpSocket != null || _serialPort != null) return;
    _connectRoutineTimer?.cancel();
    _connectRoutineTimer = Timer(Duration(seconds: seconds), _connectRoutine);
  }

  void stopConnectRoutine() {
    connectRoutineIsRunning = false;
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
    bool nothingExecuted = true;

    if (_connection == null && isUseBT && btMacAddress != '') {
      nothingExecuted = false;

      print('Connecting to BT service...');

      _btSTDId = id;

      BluetoothConnection.toAddress(btMacAddress).then(_onBTConnected).catchError((err) {
        print(err);
        _freeBtConnectionResources();
        _restartConnectRoutineTimer();
      });
    }

    if (_serialPort == null && isUseSerial && serialManName != '' && serialVID != 0) {
      nothingExecuted = false;

      print('Connecting to serial port...');

      _serialSTDId = id;

      _getSerialPort(serialManName, serialVID).then(_onSerialPortFound);
    }

    if (_tcpSocket == null && isUseTCP && IPAddress != '' && IPPort != -1) {
      nothingExecuted = false;

      _tcpSTDId = id;

      Socket.connect(IPAddress, IPPort).then(_onTCPConnected).catchError((err) {
        print(err);
        _freeTCPConnectionResources();
        _restartConnectRoutineTimer();
      });
    }

    if (nothingExecuted) {
      print('NOTHING');
      stopConnectRoutine(); // all settings are empty
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
      _freeSerialConnectionResources();
    } else {
      print("Wrong Serial STD ID");

      _freeSerialConnectionResources();
      _restartConnectRoutineTimer();
    }
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

      _freeBtConnectionResources();
    } else {
      print("Wrong BT STD ID");

      _freeBtConnectionResources();
      _restartConnectRoutineTimer();

      _connection?.close();
    }
  }

  void _onBTReadTimerTimeout() {
    print('No package received from BT connection');

    _connection?.close();

    _freeBtConnectionResources();
    _restartConnectRoutineTimer();
  }

  void _onTCPConnected(Socket socket) {
    _tcpSocket = socket;
    _tcpSubscription = _tcpSocket!.listen(_onTCPReadyRead);

    print("Sending request...");

    // send test package
    var package = BasePackage.makeBaseRequest(_tcpSTDId, PackageType.GET_VERSION);
    var bytes = package.toBytesArray();

    // Add some bytes to wake up STD
    // the amount of bytes should be more than 22
    // otherwise TCP STD may not wake up

    Uint8List trash = Uint8List(50);
    Uint8List req = Uint8List(trash.length + bytes.length);

    req.setAll(0, trash);
    req.setAll(trash.length, bytes);

    _tcpSocket!.add(req);
    _tcpSocket!.flush();

    // wait for ready read
    _tcpReadTimer?.cancel();
    _tcpReadTimer = Timer(const Duration(seconds: 10), _onTCPReadTimerTimeout);
  }

  void _onTCPReadyRead(Uint8List data) {
    print("Reading TCP data...");

    _tcpReadTimer?.cancel();

    Uint8List tmp = Uint8List(_tcpBuffer.length + data.length);
    tmp.setAll(0, _tcpBuffer);
    tmp.setAll(_tcpBuffer.length, data);
    _tcpBuffer = tmp;

    BasePackage? receivedPackage;
    bool mayHaveOneMorePackage = true;
    while (mayHaveOneMorePackage) {
      var ref = Reference<Uint8List>(_tcpBuffer);
      var pair = PackagesParser.tryFindAndParsePackage(ref);

      receivedPackage = pair.first;
      mayHaveOneMorePackage = pair.second;

      _tcpBuffer = ref.value;

      if (receivedPackage != null) break;
    }

    if (receivedPackage == null) {
      _tcpReadTimer = Timer(const Duration(seconds: 10), _onTCPReadTimerTimeout);
      return;
    }

    var isSTD = _checkStdPackage(_tcpSTDId, receivedPackage);
    if (isSTD) {
      print("TCP STD connected");

      StdInfo info = StdInfo();
      info.std = TCPSTD(_tcpSTDId, _tcpSocket);
      info.type = StdConnectionType.TCPSTD;

      _newSTDConnected(info);
      _freeTCPConnectionResources();
    } else {
      print("Wrong TCP STD ID");

      _freeTCPConnectionResources();
      _restartConnectRoutineTimer();

      _tcpSocket?.close();
    }
  }

  void _onTCPReadTimerTimeout() {
    print('No package received from TCP connection');

    _tcpSocket?.close();

    _freeTCPConnectionResources();
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

      global.stdConnectionManager.stopConnectRoutine();
    };

    std.onDisconnected = () {
      var stdId = global.std?.stdId;

      if (global.std != null) {
        global.std!.onReadyRead = (_) {};
        global.std!.onConnected = () {};
        global.std!.onDisconnected = () {};
      }

      global.std = null;
      global.stdInfo = StdInfo();

      var device = global.itemsMan.get<NetDevice>(stdId ?? 0);
      if (device != null) {
        device.state = NDState.Offline;
        global.pageWithMap.deactivateMapMarker(stdId!);
        global.deviceParametersPage.addProtocolLine('Device #$stdId offline');
      }

      global.stdConnectionManager.startConnectRoutine();
    };

    std.onReadyRead = (Uint8List data) {
      global.std?.lastActiveTime = DateTime.now();
      global.packagesParser.addData(data);
    };

    var subscription = _btSubscription;
    if (std is SerialSTD) subscription = _serialSubscription;
    if (std is TCPSTD) subscription = _tcpSubscription;

    subscription?.onData(std.onReadyRead);
    subscription?.onDone(std.onDone);
    subscription?.onError(std.onError);

    std.connect();
  }
}
