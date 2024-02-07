import 'dart:async';

import 'global.dart' as global;
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'BluSTD.dart';

class STDConnectionManager {
  int _stdId = 195;
  final String _stdName = global.deviceName;
  String _stdAddress = '';
  bool isDiscovering = true;

  late void Function() setStateOnDone;
  late void Function(int) stdConnected;

  Timer? timer;

  void searchAndConnect() {
    isDiscovering = true;
    print(FlutterBluetoothSerial.instance.isDiscovering);

    FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      if (r.device.name == _stdName && global.std == null) {
        _stdAddress = r.device.address.toString();

        var std = BluSTD(_stdId, (Uint8List? data) {
          if (global.std != null) global.std!.lastActiveTime = DateTime.now();
          global.packagesParser.addData(data!);
        });

        std.onConnected = onConnected;
        std.onDisconnected = onDisconnected;

        std.setBTHost(_stdAddress);
        std.connect();

        global.std = std;

        isDiscovering = false;
      }
    });

    timer = Timer(const Duration(seconds: 10), () {
      isDiscovering = false;
      setStateOnDone();
    });
  }

  void disconnect() {
    global.std!.disconnect();
  }

  void setSTDId(int stdID) {
    _stdId = stdID;
  }

  void onConnected() {
    global.flagConnect = true;
    Timer.run(setStateOnDone);
    Timer.run(() => stdConnected(global.std!.stdId));
  }

  void onDisconnected() {
    global.std = null;
    global.flagConnect = false;
    isDiscovering = false;
    Timer.run(setStateOnDone);
  }
}
