import 'dart:typed_data';
import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'ISTD.dart';

class BTSTD extends ISTD {
  BluetoothConnection? _connection;
  String _macAddress = '';

  BTSTD(int stdId, String btAddress, BluetoothConnection? connection) {
    super.stdId = stdId;
    _connection = connection;
    _macAddress = btAddress;
  }

  void setBTHost(String deviceAddress) {
    _macAddress = deviceAddress;
  }

  @override
  Future<bool> connect() async {
    if (_connection != null) {
       if (!_connection!.isConnected) {
         _connection!.input!.listen(onReadyRead);
       }

      Timer.run(onConnected);
      return true;
    }

    if (_macAddress.isEmpty) return false;

    return BluetoothConnection.toAddress(_macAddress).then((value) {
      _connection = value;
      _connection!.input?.listen(onReadyRead);

      Timer.run(onConnected);
      return true;
    }).catchError((err) {
      _connection = null;
      Timer.run(onDisconnected);
      return false;
    });
  }

  @override
  Future disconnect() async {
    if (_connection != null) {
      await _connection!.finish();
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
    if (!isValid()) return;

    _connection!.output.add(Uint8List(50));
    _connection!.output.allSent;
  }

  @override
  int write(Uint8List data) {
    if (!isValid()) return 0;

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

  void onDone() {
    print('BT connection done');
    disconnect();
  }

  void onError(err) {
    print("BT error occurred: $err");
    disconnect();
  }
}
