import 'dart:typed_data';
import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'ISTD.dart';

class BluSTD extends ISTD {
  BluetoothConnection? _connection;
  String? _deviceAddress;

  BluSTD(int stdId, void Function(Uint8List) onData) {
    super.stdId = stdId;
    super.onReadyRead = onData;
  }

  void setBTHost(String deviceAddress) {
    _deviceAddress = deviceAddress;
  }

  @override
  Future<bool> connect() async {
    if (_connection != null) {
      return _connection!.isConnected;
    }

    return BluetoothConnection.toAddress(_deviceAddress)
        .then((value) {
        _connection = value;

        _connection!.input?.listen(onReadyRead);

        Timer.run(onConnected);
        return true;
    })
        .catchError((err) {
          _connection = null;
          Timer.run(onDisconnected);
          //return false;
    });
  }

  @override
  Future disconnect() async {
    if (_connection != null) {
      await _connection!.finish();
      _connection!.close();
      _connection = null;
    }

    Timer.run(onDisconnected);
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
