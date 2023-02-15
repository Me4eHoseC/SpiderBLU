import 'dart:async';

import 'package:flutter/material.dart';
import 'package:projects/Application.dart';
import 'package:projects/BasePackage.dart';
import 'package:projects/BluSTD.dart';
import 'package:projects/NetCommonPackages.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:projects/RoutesManager.dart';

import './AllEnum.dart';
import 'NetNetworkPackages.dart';
import 'global.dart' as global;

class BluetoothPage extends StatefulWidget with TIDManagement {
  final bool start;
  BluetoothPage({super.key, this.start = true});

  List<String> array = [];

  @override
  _BluetoothPage createState() => new _BluetoothPage();

  @override
  void acknowledgeReceived(int tid, BasePackage basePackage) {
    tits.remove(tid);
    array.add('acknowledgeReceived');
  }

  @override
  void dataReceived(int tid, BasePackage basePackage) {
    tits.remove(tid);
    if (basePackage.getType() == PacketTypeEnum.VERSION) {
      var package = basePackage as VersionPackage;
      print('dataReceived: ${package.getVersion()}');
      array.add('dataReceived: ${package.getVersion()}');
    }

    if (basePackage.getType() == PacketTypeEnum.TIME) {
      var package = basePackage as TimePackage;
      print('dataReceived: ${package.getTime()}');
      for (int i = 0; i < global.globalMapMarker.length; i++ ){
        if(global.globalMapMarker[i].markerData.deviceId == package.getSender()){
          global.globalMapMarker[i].markerData.deviceTime = package.getTime();
        }
      }
      array.add('dataReceived: ${package.getTime()}');
    }

    if (basePackage.getType() == PacketTypeEnum.ALL_INFORMATION) {
      print('object');
      var package = basePackage as AllInformationPackage;
      print('dataReceived: ${package.getLatitude()}');
      array.add('dataReceived: ${package.getLatitude()}');
      print('dataReceived: ${package.getLongitude()}');
      array.add('dataReceived: ${package.getLongitude()}');
    }

    if (basePackage.getType() == PacketTypeEnum.COORDINATE) {
      var package = basePackage as CoordinatesPackage;
      print('dataReceived: ${package.getLatitude()}');
      array.add('dataReceived: ${package.getLatitude()}');
      print('dataReceived: ${package.getLongitude()}');
      array.add('dataReceived: ${package.getLongitude()}');
    }

    if (basePackage.getType() == PacketTypeEnum.ALLOWED_HOPS) {
      var package = basePackage as HopsPackage;
      print('dataReceived: ${package.getHops()}');
      array.add('dataReceived: ${package.getHops()}');
    }
  }

  @override
  void ranOutOfSendAttempts(int tid, BasePackage? pb) {
    tits.remove(tid);
    array.add('RanOutOfSendAttempts');
  }
}

class _BluetoothPage extends State<BluetoothPage>
    with AutomaticKeepAliveClientMixin<BluetoothPage> {
  @override
  bool get wantKeepAlive => true;
  int? deviceId;
  Widget list = Container();
  String dropdownValue = '';
  List<DropdownMenuItem<String>> dropdownItems = [];

  @override
  void initState() {
    super.initState();
    Application.init();
    _startDiscovery();
    Timer.periodic(Duration.zero, (_) {
      setState(() {
        checkNewIdDevice();
        list = ListView.builder(itemBuilder: (context, i) {
          if (i < widget.array.length) {
            return new Text(widget.array[i]);
          } else
            return new Text('');
        });
      });
    });
  }

  void checkNewIdDevice() {
    if (dropdownItems.length != global.globalDevicesListFromMap.length) {
      dropdownValue = global.globalDevicesListFromMap.last;
      if (deviceId == null){
        setDevId(dropdownValue);
      }
      var newItem = DropdownMenuItem(
        child: Text(global.globalDevicesListFromMap.last),
        value: dropdownValue,
      );
      dropdownItems.add(newItem);
    }
  }

  void _startDiscovery() {
    global.stdConnectionManager.setStateOnDone = () {
      setState(() {});
    };
    setState(() {
      global.stdConnectionManager.searchAndConnect();
    });
  }

  void setDevId(String string) {
    deviceId = int.parse(string);
  }

  void TakeVersionClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_VERSION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeTimeClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_TIME);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeAllInfoClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(
          devId, PacketTypeEnum.GET_ALL_INFORMATION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeCordClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_COORDINATE);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void SetTimeClick(int devId) {
    setState(() {
      TimePackage timePackage = TimePackage();
      timePackage.setReceiver(devId);
      timePackage.setSender(RoutesManager.getLaptopAddress());
      var tid = global.postManager.sendPackage(timePackage);
      widget.tits.add(tid);
    });
  }

  void Disconnect() {
    setState(() {
      global.stdConnectionManager.Disconnect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: global.flagConnect
          ? Text (global.deviceName)
          : Text ('None device'),
          actions: <Widget>[
            DropdownButton<String>(
              icon: const Icon(Icons.keyboard_double_arrow_down),
              value: dropdownValue,
              items: dropdownItems,
              onChanged: (String? value) {
                setState(() {
                  dropdownValue = value!;
                  setDevId(dropdownValue);
                });
              },
            ),
            global.flagConnect
                ? IconButton(
                    onPressed: Disconnect,
                    icon: const Icon(Icons.cancel),
                  )
                : (global.stdConnectionManager.isDiscovering
                    ? FittedBox(
                        child: Container(
                          margin: const EdgeInsets.all(16.0),
                          child: const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: _startDiscovery,
                        icon: const Icon(Icons.replay),
                      )),
          ],
        ),
        body: Visibility(
            visible: global.std != null,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () => TakeVersionClick(deviceId!),
                        child: const Text('Take version'),
                      ),
                      ElevatedButton(
                        onPressed: () => TakeTimeClick(deviceId!),
                        child: const Text('Take time'),
                      ),
                      ElevatedButton(
                        onPressed: () => TakeAllInfoClick(deviceId!),
                        child: const Text('Take all info'),
                      ),
                      ElevatedButton(
                        onPressed: () => TakeCordClick(deviceId!),
                        child: const Text('Take cord'),
                      ),
                      ElevatedButton(
                        onPressed: () => SetTimeClick(deviceId!),
                        child: const Text('Set time'),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [],
                  ),
                  Container(width: 200, height: 500, child: list),
                ])));
  }
}