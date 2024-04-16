import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:io';

import 'ISTD.dart';

class TCPSTD extends ISTD {
  Socket? _socket;

  TCPSTD(int stdId, Socket? socket) {
    super.stdId = stdId;
    _socket = socket;
  }

  @override
  Future<bool> connect() async {
    if (_socket == null) return false;

    Timer.run(onConnected);
    return true;
  }

  @override
  Future disconnect() async {
    Timer.run(onDisconnected);
  }

  @override
  bool isValid() {
    if (_socket == null) return false;
    return true; // todo possible error
  }

  @override
  void awake() {
    if (!isValid()) return;
    _socket!.add(Uint8List(50));
  }

  @override
  int write(Uint8List data) {
    if (!isValid()) return 0;

    awake();
    _socket!.add(data);

    return data.length;
  }

  @override
  void reboot() {
    if (isValid()) {
      _socket!.close();
    }

    connect();
  }

  @override
  void onDone() {
    print('TCP connection done');
    disconnect();
  }

  @override
  void onError(err) {
    print("TCP error occurred: $err");
    disconnect();
  }
}
