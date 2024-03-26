import 'dart:typed_data';

abstract class ISTD {
  int stdId = -1;
  DateTime lastActiveTime = DateTime.now();

  int getStdId() {
    return stdId;
  }

  void connect();

  void disconnect();

  bool isValid();

  void reboot();

  void awake();

  int write(Uint8List data);

  late void Function(Uint8List data) onReadyRead;
  late void Function() onConnected;
  late void Function() onDisconnected;

  void onDone();

  void onError(err);
}
