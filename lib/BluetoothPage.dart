import 'dart:async';

import 'package:flutter/material.dart';
import 'package:projects/Application.dart';
import 'package:projects/BasePackage.dart';
import 'package:projects/NetCommonPackages.dart';

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
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceVersion =
              package.getVersion();
        }
      }
      array.add('dataReceived: ${package.getVersion()}');
    }

    if (basePackage.getType() == PacketTypeEnum.TIME) {
      var package = basePackage as TimePackage;
      print('dataReceived: ${package.getTime()}');
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceTime = package.getTime();
        }
      }
      array.add('dataReceived: ${package.getTime()}');
    }

    if (basePackage.getType() == PacketTypeEnum.ALL_INFORMATION) {
      var package = basePackage as AllInformationPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceCord!.longitude =
              package.getLongitude();
          global.globalMapMarker[i].markerData.deviceCord!.latitude =
              package.getLatitude();
          global.globalMapMarker[i].markerData.deviceTime = package.getTime();
          global.globalMapMarker[i].markerData.deviceLastAlarmType =
              package.getLastAlarmType();
          global.globalMapMarker[i].markerData.deviceLastAlarmReason =
              package.getLastAlarmReason();
          global.globalMapMarker[i].markerData.deviceLastAlarmTime =
              package.getLastAlarmTime();
          global.globalMapMarker[i].markerData.deviceStateMask =
              package.getStateMask();
          global.globalMapMarker[i].markerData.deviceBattery =
              package.getBattery();

          print(
              'dataReceived: ${global.globalMapMarker[i].markerData.deviceCord}');
          print(
              'dataReceived: ${global.globalMapMarker[i].markerData.deviceTime}');
          print(
              'dataReceived: ${global.globalMapMarker[i].markerData.deviceLastAlarmType}');
          print(
              'dataReceived: ${global.globalMapMarker[i].markerData.deviceLastAlarmReason}');
          print(
              'dataReceived: ${global.globalMapMarker[i].markerData.deviceLastAlarmTime}');
          print(
              'dataReceived: ${global.globalMapMarker[i].markerData.deviceStateMask}');
          print(
              'dataReceived: ${global.globalMapMarker[i].markerData.deviceBattery}');

          array.add(
              'dataReceived: ${global.globalMapMarker[i].markerData.deviceCord}');
          array.add(
              'dataReceived: ${global.globalMapMarker[i].markerData.deviceTime}');
          array.add(
              'dataReceived: ${global.globalMapMarker[i].markerData.deviceLastAlarmType}');
          array.add(
              'dataReceived: ${global.globalMapMarker[i].markerData.deviceLastAlarmReason}');
          array.add(
              'dataReceived: ${global.globalMapMarker[i].markerData.deviceLastAlarmTime}');
          array.add(
              'dataReceived: ${global.globalMapMarker[i].markerData.deviceStateMask}');
          array.add(
              'dataReceived: ${global.globalMapMarker[i].markerData.deviceBattery}');
        }
      }
      /*print('dataReceived: ${package.getLatitude()}');
      array.add('dataReceived: ${package.getLatitude()}');
      print('dataReceived: ${package.getLongitude()}');
      array.add('dataReceived: ${package.getLongitude()}');*/
    }

    if (basePackage.getType() == PacketTypeEnum.COORDINATE) {
      var package = basePackage as CoordinatesPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceCord!.longitude =
              package.getLongitude();
          global.globalMapMarker[i].markerData.deviceCord!.latitude =
              package.getLatitude();
        }
      }

      print('dataReceived: ${package.getLatitude()}');
      array.add('dataReceived: ${package.getLatitude()}');
      print('dataReceived: ${package.getLongitude()}');
      array.add('dataReceived: ${package.getLongitude()}');
    }

    if (basePackage.getType() == PacketTypeEnum.INFORMATION) {
      var package = basePackage as InformationPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceState = package.getState();
          global.globalMapMarker[i].markerData.deviceBattery =
              package.getBattery();
          global.globalMapMarker[i].markerData.deviceRssi = package.getRssi();
        }
      }

      print('dataReceived: ${package.getState()}');
      array.add('dataReceived: ${package.getState()}');
      print('dataReceived: ${package.getBattery()}');
      array.add('dataReceived: ${package.getBattery()}');
      print('dataReceived: ${package.getRssi()}');
      array.add('dataReceived: ${package.getRssi()}');
    }

    if (basePackage.getType() == PacketTypeEnum.ALLOWED_HOPS) {
      var package = basePackage as HopsPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceAllowedHops =
              package.getHops();
        }
      }

      print('dataReceived: ${package.getHops()}');
      array.add('dataReceived: ${package.getHops()}');
    }

    if (basePackage.getType() == PacketTypeEnum.UNALLOWED_HOPS) {
      var package = basePackage as HopsPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceAllowedHops =
              package.getHops();
        }

        print('dataReceived: ${package.getHops()}');
        array.add('dataReceived: ${package.getHops()}');
      }
    }

    //todo
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
          } else {
            return new Text('');
          }
        });
      });
    });
  }

  void checkNewIdDevice() {
    if (dropdownItems.length != global.globalDevicesListFromMap.length) {
      dropdownValue = global.globalDevicesListFromMap.last;
      if (deviceId == null) {
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

// Button's click
  void SetIdClick(int devId, int newId) {
    setState(() {
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == devId) {
          global.globalMapMarker[i].markerData.deviceId = newId;
        }
      }
    });
  }

  //TODO type device click

  void TakeTimeClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_TIME);
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

  void TakeVersionClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_VERSION);
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

  void SetCoordClick(int devId, double latitude, double longitude) {
    setState(() {
      CoordinatesPackage coordinatesPackage = CoordinatesPackage();
      coordinatesPackage.setReceiver(devId);
      coordinatesPackage.setSender(RoutesManager.getLaptopAddress());
      coordinatesPackage.setLatitude(latitude);
      coordinatesPackage.setLatitude(longitude);
      var tid = global.postManager.sendPackage(coordinatesPackage);
      widget.tits.add(tid);
    });
  }

  void TakeSignalStrengthClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_INFORMATION);
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

  void TakeStrengthSignalClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_INFORMATION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeAllowedHopsClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_ALLOWED_HOPS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeUnallowedHopsClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_UNALLOWED_HOPS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  //todo tid
  void TakeRetransmissionAllClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_ALLOWED_HOPS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }



  void SetRetransmissionAllClick(int devId, bool checked) {
    setState(() {
      HopsPackage hopsPackage = HopsPackage();
      hopsPackage.setReceiver(devId);
      hopsPackage.setSender(RoutesManager.getLaptopAddress());
      hopsPackage
          .addHop(checked ? RoutesManager.getRetransmissionAllAddress() : 0);
      var tid = global.postManager.sendPackage(hopsPackage);
      widget.tits.add(tid);
    });
  }

  void ButtonResetRetransmissionClick(int devId) {
    setState(() {
      BasePackage getInfo =
      BasePackage.makeBaseRequest(devId, PacketTypeEnum.SET_DEFAULT_NETWORK);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }




  /*void TakeRetransmissionAll(int devId){
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(
          devId, PacketTypeEnum.);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }*/

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
              ? Text(global.deviceName)
              : Text('None device'),
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
