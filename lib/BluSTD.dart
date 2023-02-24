import 'dart:typed_data';
import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projects/ISTD.dart';

class BluSTD extends ISTD {
  BluetoothConnection? _connection;
  String? _deviceAddress, _deviceName;

  BluSTD(int stdId, void Function(Uint8List) onData) {
    super.stdId = stdId;
    super.onData = onData;
  }

  void setBTHost(String deviceAddress, String deviceName) {
    _deviceAddress = deviceAddress;
    _deviceName = deviceName;
  }

  @override
  Future<bool> connect() async {
    if (_connection != null) {
      return _connection!.isConnected;
    }

    _connection = await BluetoothConnection.toAddress(_deviceAddress);

    if (_connection == null) {
      return connect();
    }

    _connection!.input?.listen(onData);
    Timer(Duration.zero, onConnected);
    return true;
  }

  @override
  void disconnect() {
    _connection!.close();
    Timer(Duration.zero, onDisconnected);
  }

  @override
  bool isValid() {
    if (_connection == null) return false;
    return _connection!.isConnected;
  }

  @override
  void awake() {
    if (!isValid()) {
      return;
    }

    _connection!.output.add(Uint8List(50));
    _connection!.output.allSent;
  }

  @override
  int write(Uint8List data) {
    if (!isValid()) {
      return 0;
    }

    awake();

    _connection!.output.add(data);
    _connection!.output.allSent;

    return data.length;
  }

  @override
  void reboot() {
    if (isValid()) {
      _connection!.close();
    }
    connect();
  }
}
