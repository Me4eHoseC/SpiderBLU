import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:usb_serial/usb_serial.dart';

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
  List<DropdownMenuItem<String>> dropdownBTItems = [];
  String dropdownBTValue = '';
  String bluetoothMAC = '';
  String selectedBluetoothMacFromFile = '';
  bool btState = false;

  List<DropdownMenuItem<UsbDevice>> dropdownSerialItems = [];
  String selectedSerialManNameFromFile = ''; // todo remove when file
  int selectedSerialVIDFromFile = 0; // todo remove when file
  UsbDevice? usbDevice;
  List<UsbDevice> listUsbDevices = [];

  @override
  void initState() {
    //todo read settings file and init name and mac from file
    super.initState();
    Timer.periodic(const Duration(milliseconds: 200), (timer) => setState(() {}));
  }

  void refillSerialInDropdown(List<UsbDevice> devices) {
    dropdownSerialItems = [];
    for (var device in devices) {
      usbDevice = device;
      var newItem = DropdownMenuItem(
        value: usbDevice,
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            flex: (selectedSerialManNameFromFile == usbDevice!.manufacturerName && selectedSerialVIDFromFile == usbDevice!.vid) ? 1 : 0,
            child: selectedSerialManNameFromFile == usbDevice!.manufacturerName && selectedSerialVIDFromFile == usbDevice!.vid
                ? const Icon(Icons.check)
                : Container(),
          ),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.manufacturerName!,
                  textScaleFactor: 1.2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  device.vid!.toString(),
                  textScaleFactor: 0.8,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ]),
      );
      dropdownSerialItems.add(newItem);
    }
  }

  void serialDiscovery() async {
    UsbSerial.listDevices().then((value) {
      listUsbDevices = value;
      refillSerialInDropdown(value);
    });

    /* UsbPort? port;
    port = await devices[0].create();

    bool openResult = await port!.open();
    if (!openResult) {
      print('Failed to open');
      return;
    }

    await port.setDTR(true);
    await port.setRTS(true);

    port.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    port.inputStream?.listen((Uint8List event) {
      print(event);
    });*/
  }

  void addBluetoothInDropdown(String name, String mac) {
    dropdownBTValue = mac;
    var newItem = DropdownMenuItem(
      value: dropdownBTValue,
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
    dropdownBTItems.add(newItem);
  }

  void refillDropdownMenuItems() {
    dropdownBTItems = [];
    for (int i = 0; i < results.length; i++) {
      addBluetoothInDropdown(results[i].device.name!, results[i].device.address);
    }
    dropdownBTValue = selectedBluetoothMacFromFile;
    bluetoothMAC = selectedBluetoothMacFromFile;
  }

  void stopDiscovery() {
    setState(() {
      isDiscovering = false;
      _streamSubscription!.cancel();
    });
  }

  void repeatDiscovery() {
    dropdownBTItems = [];
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

    var serialStateCheckBox = CheckboxListTile(
        title: const Text(
          "COM STD",
          style: TextStyle(fontSize: headingTextSize),
        ),
        value: global.stdConnectionManager.isUseSerial,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (bool? value) {
          setState(() {
            global.stdConnectionManager.isUseSerial = value!;
          });
        });

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
                      value: dropdownBTValue,
                      items: dropdownBTItems,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      hint: const Text('Select device'),
                      onChanged: btState
                          ? (String? value) {
                              setState(() {
                                dropdownBTValue = value!;
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

                              global.stdConnectionManager.startConnectRoutine();
                            }
                          : null,
                      child: const Icon(Icons.save),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 3,
                  child: serialStateCheckBox,
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                )
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
                      onPressed: serialDiscovery,
                      child: const Icon(Icons.replay),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: DropdownButton<UsbDevice>(
                      icon: const Icon(Icons.keyboard_double_arrow_down),
                      isExpanded: true,
                      value: usbDevice,
                      items: dropdownSerialItems,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      hint: const Text('Select device'),
                      onChanged: (UsbDevice? value) {
                        setState(() {
                          usbDevice = value!;
                          print(usbDevice?.vid);
                          print(usbDevice?.manufacturerName);
                        });
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () {
                        if (usbDevice == null) return;
                        selectedSerialManNameFromFile = usbDevice!.manufacturerName ?? '';
                        selectedSerialVIDFromFile = usbDevice!.vid ?? 0;

                        global.stdConnectionManager.serialManName = selectedSerialManNameFromFile;
                        global.stdConnectionManager.serialVID = selectedSerialVIDFromFile;

                        refillSerialInDropdown(listUsbDevices);
                        global.stdConnectionManager.startConnectRoutine();
                      },
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
