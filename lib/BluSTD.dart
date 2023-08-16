import 'dart:typed_data';
import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projects/ISTD.dart';


class BluSTD extends ISTD {
  BluetoothConnection? _connection;
  String? _deviceAddress;

  BluSTD(int stdId, void Function(Uint8List) onData) {
    super.stdId = stdId;
    super.onData = onData;
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

        _connection!.input?.listen(onData);

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
  void disconnect() {
    if (_connection != null) {
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
