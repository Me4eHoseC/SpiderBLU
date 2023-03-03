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
  void Function()? setStateOnDone;
  Timer? timer;

  void searchAndConnect() {
    isDiscovering = true;
    timer = Timer(Duration(seconds: 14), () {isDiscovering = false;});
    FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      if (r.device.name == _stdName) {
        _stdAddress = r.device.address.toString();

        global.std = BluSTD(_stdId, (Uint8List? data) {
          global.packagesParser.addData(data!);
        });
        global.std!.onConnected = onConnected;
        global.std!.onDisconnected = onDisconnected;

        (global.std! as BluSTD).setBTHost(_stdAddress, _stdName);

        global.std!.connect();
        isDiscovering = false;
      }
    });

  }

  void Disconnect(){
    print("dis");
    global.std!.disconnect();
  }

  void setSTDId(int stdID) {
    _stdId = stdID;
  }

  void onConnected() {
    Timer(Duration.zero, setStateOnDone!);
    print('Connected');
    /*if (global.std == null){
      print('notConnect');
    }*/
    global.flagConnect = true;
  }

  void onDisconnected() {
    print('Disconnected');
    global.std = null;
    global.flagConnect = false;
  }
}
