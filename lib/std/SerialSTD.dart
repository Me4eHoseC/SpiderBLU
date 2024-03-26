import 'dart:typed_data';
import 'dart:async';

import 'package:usb_serial/usb_serial.dart';

import 'ISTD.dart';

class SerialSTD extends ISTD {
  UsbPort? _port;
  StreamSubscription<UsbEvent?>? eventStreamListener;

  SerialSTD(int stdId, UsbPort? port) {
    super.stdId = stdId;
    _port = port;

    eventStreamListener = UsbSerial.usbEventStream?.listen((UsbEvent msg) {
      print(msg);
      if (msg.event == UsbEvent.ACTION_USB_DETACHED) {
        disconnect();
        eventStreamListener?.cancel();
      }
    });
  }

  @override
  Future<bool> connect() async {
    if (_port == null) return false;
    bool openResult = await _port!.open();

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    _port!.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    if (openResult) {
      Timer.run(onConnected);
    }

    return openResult;
  }

  @override
  Future disconnect() async {
    if (_port != null) {
      await _port!.close();
      _port = null;
    }

    Timer.run(onDisconnected);
  }

  @override
  bool isValid() {
    if (_port == null) return false;
    return true; // todo possible error
  }

  @override
  void awake() {
    if (!isValid()) return;
    _port!.write(Uint8List(50));
  }

  @override
  int write(Uint8List data) {
    if (!isValid()) return 0;

    awake();
    _port!.write(data);

    return data.length;
  }

  @override
  void reboot() {
    if (isValid()) {
      _port!.close();
    }

    connect();
  }

  @override
  void onDone() {
    print('Serial connection done');
    disconnect();
  }

  @override
  void onError(err) {
    print("Serial error occurred: $err");
    disconnect();
  }
}
