import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../global.dart' as global;

class SettingsPage extends StatefulWidget {
  final bool start;

  SettingsPage({super.key, this.start = true});

  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> with TickerProviderStateMixin {
  bool get wantKeepAlive => true;
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results = [];
  bool isDiscovering = false;
  List<DropdownMenuItem<String>> dropdownItems = [];
  String dropdownValue = '';
  String bluetoothMAC = '';
  String selectedBluetoothMacFromFile = '';
  bool btState = false;

  @override
  void initState() {
    //todo read settings file and init name and mac from file
    super.initState();
    Timer.periodic(const Duration(milliseconds: 200), (timer) => setState(() {}));
  }

  void addBluetoothInDropdown(String name, String mac) {
    dropdownValue = mac;
    var newItem = DropdownMenuItem(
      value: dropdownValue,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          flex: selectedBluetoothMacFromFile == mac ? 1 : 0,
          child: selectedBluetoothMacFromFile == mac ? const Icon(Icons.check) : Container(),
        ),
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                textScaleFactor: 1.2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                mac,
                textScaleFactor: 0.8,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ]),
    );
    bluetoothMAC = mac;
    dropdownItems.add(newItem);
  }

  void refillDropdownMenuItems() {
    dropdownItems = [];
    for (int i = 0; i < results.length; i++) {
      addBluetoothInDropdown(results[i].device.name!, results[i].device.address);
    }
    dropdownValue = selectedBluetoothMacFromFile;
    bluetoothMAC = selectedBluetoothMacFromFile;
  }

  void stopDiscovery() {
    setState(() {
      isDiscovering = false;
      _streamSubscription!.cancel();
    });
  }

  void repeatDiscovery() {
    dropdownItems = [];
    results = [];

    isDiscovering = true;

    FlutterBluetoothSerial.instance.isEnabled.then((value) {
      if (value == false) {
        FlutterBluetoothSerial.instance.requestEnable();
        isDiscovering = false;
        return;
      }

      _streamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
        final existingIndex = results.indexWhere((element) => element.device.address == r.device.address);
        if (existingIndex >= 0) {
          results[existingIndex] = r;
        } else if (r.device.name != null) {
          results.add(r);
          addBluetoothInDropdown(r.device.name!, r.device.address);
        }

        setState(() {});
      });

      _streamSubscription!.onDone(() {
        isDiscovering = false;
        _streamSubscription = null;

        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const double headingTextSize = 20;
    const double commonTextSize = 16;

    var btSettingsCheckBox = CheckboxListTile(
        title: const Text(
          "BT STD",
          style: TextStyle(fontSize: headingTextSize),
        ),
        value: global.stdConnectionManager.isUseBT,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (bool? value) {
          setState(() {
            global.stdConnectionManager.isUseBT = value!;
          });
        });

    var btStateCheckBox = FutureBuilder<bool?>(
      future: FlutterBluetoothSerial.instance.isEnabled,
      builder: (BuildContext context, AsyncSnapshot<bool?> snapshot) {
        if (snapshot.hasData) {
          btState = snapshot.data ?? false;
        }

        return SwitchListTile(
          title: const Text(
            'Bluetooth',
            style: TextStyle(fontSize: commonTextSize),
          ),
          value: btState,
          onChanged: (isTurnOff) {
            if (isTurnOff) {
              FlutterBluetoothSerial.instance.requestEnable();
            } else {
              FlutterBluetoothSerial.instance.requestDisable();
            }
          },
        );
      },
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: btSettingsCheckBox,
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                )
              ],
            ),
            btStateCheckBox,
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 10),
                  child: Text('Remote BT devices:', style: TextStyle(fontSize: commonTextSize)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: btState
                          ? isDiscovering
                              ? stopDiscovery
                              : repeatDiscovery
                          : null,
                      child: Icon(isDiscovering ? Icons.cancel_outlined : Icons.replay),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: DropdownButton<String>(
                      icon: const Icon(Icons.keyboard_double_arrow_down),
                      isExpanded: true,
                      value: dropdownValue,
                      items: dropdownItems,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      hint: const Text('Select device'),
                      onChanged: btState
                          ? (String? value) {
                              setState(() {
                                dropdownValue = value!;
                                bluetoothMAC = value;
                              });
                            }
                          : null,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: btState
                          ? () {
                              //todo save in file bluetooth mac
                              selectedBluetoothMacFromFile = bluetoothMAC;
                              global.stdConnectionManager.btMacAddress = bluetoothMAC;
                              refillDropdownMenuItems();
                            }
                          : null,
                      child: const Icon(Icons.save),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
