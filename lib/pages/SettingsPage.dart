import 'dart:async';
import 'dart:io';
import 'dart:convert';
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

  String ipv4Address = global.stdConnectionManager.IPAddress;
  String port = global.stdConnectionManager.IPPort.toString();

  TextEditingController _controllerIP = TextEditingController();
  TextEditingController _controllerPort = TextEditingController();

  @override
  void initState() {
    //todo read settings file and init name and mac from file
    super.initState();
    global.stdConnectionManager.loadSettingsFromFile().then((_) => initAfterLoad());
    global.stdConnectionManager.initSaveSettings();
    Timer.periodic(const Duration(milliseconds: 200), (timer) => setState(() {}));
  }

  void initAfterLoad(){
    print('11111111111111111111111111111111');
    bluetoothMAC = global.stdConnectionManager.btMacAddress;
    selectedSerialManNameFromFile = global.stdConnectionManager.serialManName;
    selectedSerialVIDFromFile = global.stdConnectionManager.serialVID;
    ipv4Address = global.stdConnectionManager.IPAddress;
    port = global.stdConnectionManager.IPPort.toString();
    _controllerIP.text = ipv4Address;
    _controllerIP.addListener(_changeIP);
    _controllerPort.text = port;
    _controllerPort.addListener(_changePort);
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
  }

  _changeIP() {
    setState(() => ipv4Address = _controllerIP.text);
  }

  _changePort() {
    setState(() => port = _controllerPort.text);
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
            global.stdConnectionManager.saveSettingsInFile();
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
          onChanged: global.stdConnectionManager.isUseBT
              ? (isTurnOff) {
                  if (isTurnOff) {
                    FlutterBluetoothSerial.instance.requestEnable();
                  } else {
                    FlutterBluetoothSerial.instance.requestDisable();
                  }
                }
              : null,
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
            global.stdConnectionManager.saveSettingsInFile();
          });
        });

    var tcpStateCheckBox = CheckboxListTile(
        title: const Text(
          "TCP STD",
          style: TextStyle(fontSize: headingTextSize),
        ),
        value: global.stdConnectionManager.isUseTCP,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (bool? value) {
          setState(() {
            global.stdConnectionManager.isUseTCP = value!;
            global.stdConnectionManager.saveSettingsInFile();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 10),
                  child: Text(
                    'Remote BT devices:',
                    style: TextStyle(
                      fontSize: commonTextSize,
                      color: btState && global.stdConnectionManager.isUseBT ? null : Theme.of(context).disabledColor,
                    ),
                  ),
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
                      onPressed: btState && global.stdConnectionManager.isUseBT
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
                      onPressed: btState && global.stdConnectionManager.isUseBT
                          ? () {
                              //todo save in file bluetooth mac
                              selectedBluetoothMacFromFile = bluetoothMAC;
                              global.stdConnectionManager.btMacAddress = bluetoothMAC;
                              refillDropdownMenuItems();

                              global.stdConnectionManager.saveSettingsInFile();

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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 10),
                  child: Text(
                    'Available COM devices:',
                    style: TextStyle(
                      fontSize: commonTextSize,
                      color: global.stdConnectionManager.isUseSerial ? null : Theme.of(context).disabledColor,
                    ),
                  ),
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
                      onPressed: global.stdConnectionManager.isUseSerial ? serialDiscovery : null,
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
                      onChanged: global.stdConnectionManager.isUseSerial
                          ? (UsbDevice? value) {
                              setState(() {
                                usbDevice = value!;
                              });
                            }
                          : null,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: global.stdConnectionManager.isUseSerial
                          ? () {
                              if (usbDevice == null) return;
                              selectedSerialManNameFromFile = usbDevice!.manufacturerName ?? '';
                              selectedSerialVIDFromFile = usbDevice!.vid ?? 0;

                              global.stdConnectionManager.serialManName = selectedSerialManNameFromFile;
                              global.stdConnectionManager.serialVID = selectedSerialVIDFromFile;

                              refillSerialInDropdown(listUsbDevices);

                              global.stdConnectionManager.saveSettingsInFile();

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
                  child: tcpStateCheckBox,
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 10),
                  child: Text(
                    'Enter IPv4 address and port:',
                    style: TextStyle(
                      fontSize: commonTextSize,
                      color: global.stdConnectionManager.isUseTCP ? null : Theme.of(context).disabledColor,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: TextFormField(
                        controller: _controllerIP,
                        enabled: global.stdConnectionManager.isUseTCP,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          labelText: 'IPv4',
                          hintText: '192.168.1.252',
                        ),
                        validator: (value) {
                          if (value == null) return null;
                          if (value.isEmpty) return "IPv4 address can't be empty";

                          var match = RegExp(r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$').hasMatch(value);

                          if (!match) return "Enter correct IPv4 address";

                          return null;
                        },
                        keyboardType: TextInputType.number,
                        maxLength: 15,
                        onChanged: (value) => ipv4Address = value,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: TextFormField(
                          enabled: global.stdConnectionManager.isUseTCP,
                          controller: _controllerPort,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Port',
                            hintText: '20108',
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          validator: (value) {
                            if (value == null) return null;
                            if (value.isEmpty) return "Port value can't be empty";

                            var portCheck = int.parse(value);

                            if (0 < portCheck && portCheck < 65535) return null;

                            return "Enter correct IP port";
                          },
                          onChanged: (value) => port = value,
                        ),
                      )),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: global.stdConnectionManager.isUseTCP
                          ? () {
                              global.stdConnectionManager.IPAddress = ipv4Address;
                              global.stdConnectionManager.IPPort = int.parse(port);

                              global.stdConnectionManager.saveSettingsInFile();

                              global.stdConnectionManager.startConnectRoutine();
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
