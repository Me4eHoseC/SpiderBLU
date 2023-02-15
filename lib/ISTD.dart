import 'dart:typed_data';

abstract class ISTD {
  int stdId = -1;

  int getStdId() {
    return stdId;
  }

  void connect();
  void disconnect();

  bool isValid();
  void reboot();

  void awake();

  int write(Uint8List data);

  late void Function(Uint8List data) onData;
  late void Function() onConnected;
  late void Function() onDisconnected;
}
