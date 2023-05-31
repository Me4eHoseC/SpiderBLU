import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/Application.dart';
import 'package:projects/BasePackage.dart';
import 'package:projects/NetCommonPackages.dart';
import 'package:projects/NetPackagesDataTypes.dart';
import 'package:flutter/services.dart';

import 'AllEnum.dart';
import 'NetNetworkPackages.dart';
import 'RoutesManager.dart';
import 'global.dart' as global;

class TestPage extends StatefulWidget with TIDManagement {
  List<String> array = [];

  @override
  _TestPage createState() => new _TestPage();

  @override
  void acknowledgeReceived(int tid, BasePackage basePackage) {
    tits.remove(tid);
    array.add('acknowledgeReceived');
  }

  @override
  void dataReceived(int tid, BasePackage basePackage) {
    global.dataComeFlag = true;
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
          global.globalMapMarker[i].markerData.deviceAvailable = true;
          global.globalMapMarker[i].markerData.deviceReturnCheck = true;
        }
      }
      array.add('dataReceived: ${package.getTime()}');
    }

    if (basePackage.getType() == PacketTypeEnum.ALL_INFORMATION) {
      var package = basePackage as AllInformationPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceAvailable = true;
          global.globalMapMarker[i].markerData.deviceReturnCheck = true;
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
          global.globalMapMarker[i].markerData.deviceAvailable = true;
          global.globalMapMarker[i].markerData.deviceReturnCheck = true;
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

    if (basePackage.getType() == PacketTypeEnum.ALLOWED_HOPS &&
        !global.retransmissionRequests.contains(tid)) {
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
      global.allowedHopsCame = true;
    }

    if (basePackage.getType() == PacketTypeEnum.ALLOWED_HOPS &&
        global.retransmissionRequests.contains(tid)) {
      global.retransmissionRequests.remove(tid);
      var package = basePackage as HopsPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceRetransmissionToAll =
              package.getHops();
        }
      }
      print('dataReceived: ${package.getHops()}');
      array.add('dataReceived: ${package.getHops()}');
      //global.allowedHopsCame = true;
    }

    if (basePackage.getType() == PacketTypeEnum.UNALLOWED_HOPS) {
      var package = basePackage as HopsPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceUnallowedHops =
              package.getHops();
        }

        print('dataReceived: ${package.getHops()}');
        array.add('dataReceived: ${package.getHops()}');
      }
    }

    if (basePackage.getType() == PacketTypeEnum.STATE) {
      var package = basePackage as StatePackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceMaskExtDevice =
              package.getStateMask();
          global.globalMapMarker[i].markerData.extDevice1 =
              ((global.globalMapMarker[i].markerData.deviceMaskExtDevice! &
                      DeviceState.MONITORING_LINE1) !=
                  0);
          global.globalMapMarker[i].markerData.extDevice2 =
              ((global.globalMapMarker[i].markerData.deviceMaskExtDevice! &
                      DeviceState.MONITORING_LINE2) !=
                  0);
          global.globalMapMarker[i].markerData.devicePhototrap =
              ((global.globalMapMarker[i].markerData.deviceMaskExtDevice! &
                      DeviceState.LINES_CAMERA_TRAP) !=
                  0);
          global.globalMapMarker[i].markerData.deviceGeophone =
              ((global.globalMapMarker[i].markerData.deviceMaskExtDevice! &
                      DeviceState.MONITOR_SEISMIC) !=
                  0);
        }
      }

      print('dataReceived: ${package.getStateMask()}');
      array.add('dataReceived: ${package.getStateMask()}');
    }

    if (basePackage.getType() == PacketTypeEnum.PERIPHERY) {
      var package = basePackage as PeripheryMaskPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceMaskPeriphery =
              package.getPeripheryMask();

          global.globalMapMarker[i].markerData.deviceExtDev1State =
              ((global.globalMapMarker[i].markerData.deviceMaskPeriphery! &
                      PeripheryMask.LINE1) !=
                  0);
          global.globalMapMarker[i].markerData.deviceExtDev2State =
              ((global.globalMapMarker[i].markerData.deviceMaskPeriphery! &
                      PeripheryMask.LINE2) !=
                  0);
          global.globalMapMarker[i].markerData.deviceExtPhototrapState =
              ((global.globalMapMarker[i].markerData.deviceMaskPeriphery! &
                      PeripheryMask.CAMERA) !=
                  0);
        }
      }
      print('dataReceived: ${package.getPeripheryMask()}');
      array.add('dataReceived: ${package.getPeripheryMask()}');
    }

    if (basePackage.getType() == PacketTypeEnum.EXTERNAL_POWER) {
      var package = basePackage as ExternalPowerPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceExternalPower =
              package.getExternalPowerState().index;
        }
      }
      print('dataReceived: ${package.getExternalPowerState()}');
      array.add('dataReceived: ${package.getExternalPowerState()}');
    }

    if (basePackage.getType() == PacketTypeEnum.BATTERY_MONITOR) {
      var package = basePackage as BatteryMonitorPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceVoltage =
              package.getVoltage();
          global.globalMapMarker[i].markerData.deviceTemperature =
              package.getTemperature();
        }
      }
      print('dataReceived: ${package.getTemperature()}');
      array.add('dataReceived: ${package.getTemperature()}');
      print('dataReceived: ${package.getVoltage()}');
      array.add('dataReceived: ${package.getVoltage()}');
    }

    //todo
  }

  Future<void> dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Разрешенные хопы'),
          content: global.globalMapMarker[global.selectedDeviceID].markerData
              .deviceAllowedHops ==
              null
              ? Text(
              global.globalMapMarker[global.selectedDeviceID].markerData
                  .deviceVersion
                  .toString(),
              textAlign: TextAlign.center)
              : Text(
            'null',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'))
          ],
        );
      },
    );
  }

  @override
  void alarmReceived(BasePackage basePackage) {
    if (basePackage.getType() == PacketTypeEnum.ALARM) {
      var package = basePackage as AlarmPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId ==
            package.getSender()) {
          global.globalMapMarker[i].markerData.deviceAlarm = true;
          print('dataReceived: ${package.getAlarmType()}');
        }
      }
    }
  }

  @override
  void ranOutOfSendAttempts(int tid, BasePackage? pb) {
    tits.remove(tid);
    array.add('RanOutOfSendAttempts');
    for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (global.globalMapMarker[i].markerData.deviceId == pb!.getReceiver()) {
        global.globalMapMarker[i].markerData.backColor = Colors.blue;
        global.globalMapMarker[i].markerData.deviceAvailable = false;
        global.globalMapMarker[i].markerData.deviceReturnCheck = false;
        global.globalMapMarker[i].markerData.timer!.cancel();
      }
    }
  }
}

class _TestPage extends State<TestPage>
    with AutomaticKeepAliveClientMixin<TestPage> {
  bool get wantKeepAlive => true;
  bool checked = false;
  int? deviceId;
  String dropdownValue = '', bufferSelectedDevice = '';
  List<DropdownMenuItem<String>> dropdownItems = [];
  ScrollController _scrollController = ScrollController();

  String stringId = '';
  String? chooseDeviceType;
  String deviceLat = '',
      deviceLon = '',
      bufferDeviceLon = '',
      bufferDeviceLat = '';

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration.zero, (_) {
      setState(() {
        checkNewIdDevice();
      });
    });
  }

  void setDevId(String string) {
    deviceId = int.parse(string);
  }

  void checkNewIdDevice() {
    if (dropdownItems.length < global.globalDevicesListFromMap.length) {
      dropdownValue =
          global.globalMapMarker.last.markerData.deviceId.toString();
      if (deviceId == null) {
        setDevId(dropdownValue);
      }
      var newItem = DropdownMenuItem(
        value: dropdownValue,
        child: Text('${global.globalMapMarker.last.markerData.deviceType} '
            '#${global.globalMapMarker.last.markerData.deviceId}'),
      );
      dropdownItems.add(newItem);
    }
    if (global.dataComeFlag) {
      global.list = ListView.builder(
          reverse: true,
          controller: _scrollController,
          itemCount: widget.array.length,
          itemBuilder: (context, i) {
            return new Text(
              widget.array[i],
              textScaleFactor: 0.85,
            );
          });
      global.dataComeFlag = false;
    }

    if (global.selectedDevice != '') {
      dropdownValue = global.selectedDevice;
      global.selectedDevice = '';
    }
    if (global.allowedHopsCame == true){
      dialogBuilder();
      global.allowedHopsCame = false;
    }
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
      Timer? timer;
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_COORDINATE);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      timer = Timer.periodic(Duration(milliseconds: 50), (_) {
        if (!widget.tits.contains(tid)) {
          checkDevCord();
          timer!.cancel();
        }
      });
    });
  }

  void SetCoordClick(int devId, double latitude, double longitude) {
    setState(() {
      CoordinatesPackage coordinatesPackage = CoordinatesPackage();
      coordinatesPackage.setReceiver(devId);
      coordinatesPackage.setSender(RoutesManager.getLaptopAddress());
      coordinatesPackage.setLatitude(latitude);
      coordinatesPackage.setLongitude(longitude);
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

  void dialogBuilder(){
    print('object');
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text('Разрешенные хопы'),
            content: Text(global.globalMapMarker[global.selectedDeviceID].markerData.deviceAllowedHops.toString()),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'))
            ],
          );
        }
    );
  }

  void TakeUnallowedHopsClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_UNALLOWED_HOPS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeRetransmissionAllClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_ALLOWED_HOPS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.retransmissionRequests.add(tid);
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
      global.retransmissionRequests.add(tid);
    });
  }

  void ButtonResetRetransmissionClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(
          devId, PacketTypeEnum.SET_DEFAULT_NETWORK);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeInternalDeviceParamClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_STATE);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void SetInternalDeviceParamClick(
      int devId, bool dev1, bool dev2, bool dev3, bool dev4) {
    setState(() {
      int mask = 0;
      if (dev1) {
        mask |= DeviceState.MONITORING_LINE1;
      }
      if (dev2) {
        mask |= DeviceState.MONITORING_LINE2;
      }
      if (dev3) {
        mask |= DeviceState.MONITOR_SEISMIC;
      }
      if (dev4) {
        mask |= DeviceState.LINES_CAMERA_TRAP;
      }
      StatePackage statePackage = StatePackage();
      statePackage.setReceiver(devId);
      statePackage.setSender(RoutesManager.getLaptopAddress());
      statePackage.setStateMask(mask);
      var tid = global.postManager.sendPackage(statePackage);
      widget.tits.add(tid);
    });
  }

  void TakeInternalDeviceStateClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_PERIPHERY);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeExternalPowerClick(int devId) {
    setState(() {
      BasePackage getInfo =
          BasePackage.makeBaseRequest(devId, PacketTypeEnum.GET_EXTERNAL_POWER);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void SetExternalPowerClick(int devId, bool extFlag) {
    setState(() {
      int value = 0;
      if (extFlag) {
        value = ExternalPower.ON.index;
      } else {
        value = ExternalPower.OFF.index;
      }
      ExternalPowerPackage externalPowerPackage = ExternalPowerPackage();
      externalPowerPackage.setReceiver(devId);
      externalPowerPackage.setSender(RoutesManager.getLaptopAddress());
      externalPowerPackage.setExternalPowerState(ExternalPower.values[value]);
      var tid = global.postManager.sendPackage(externalPowerPackage);
      widget.tits.add(tid);
    });
  }

  void TakeBatteryMonitorClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(
          devId, PacketTypeEnum.GET_BATTERY_MONITOR);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  //todo tid

  /*void TakeRetransmissionAll(int devId){
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(
          devId, PacketTypeEnum.);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }*/

  void showError(String? string) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(string!),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'))
          ],
        );
      },
    );
  }

  void checkDevID(int markerIdForCheck) {
    setState(() {
      bool _flag = false;
      if (markerIdForCheck > 0 && markerIdForCheck < 256) {
        for (int i = 0; i < global.globalMapMarker.length; i++) {
          if (global.globalMapMarker[i].markerData.deviceId ==
              markerIdForCheck) {
            showError('Такой ИД уже существует');
            break;
          }
          if (i == global.globalMapMarker.length - 1) {
            _flag = true;
            if (_flag) {
              for (int j = 0; j < dropdownItems.length; j++) {
                if (dropdownItems[j].value ==
                    global.globalMapMarker[global.selectedDeviceID].markerData
                        .deviceId
                        .toString()) {
                  global.globalMapMarker[global.selectedDeviceID].markerData
                      .deviceId = markerIdForCheck;
                  dropdownItems.removeAt(j);
                  dropdownValue = markerIdForCheck.toString();
                  var newItem = DropdownMenuItem(
                    value: dropdownValue,
                    child: Text(
                        '${global.globalMapMarker[global.selectedDeviceID].markerData.deviceType} '
                        '#${global.globalMapMarker[global.selectedDeviceID].markerData.deviceId}'),
                  );
                  dropdownItems.add(newItem);

                  global.deviceIDChanged = global.selectedDeviceID;
                  break;
                }
              }
            }
          }
        }
      } else {
        showError("Неверный ИД \n"
            "ИД может быть от 1 до 255");
      }
    });
  }

  void checkDevType(String devType) {
    setState(() {
      bool _flag = false;
      if (global
              .globalMapMarker[global.selectedDeviceID].markerData.deviceType !=
          devType) {
        if (global.flagCheckSPPU &&
            global.globalMapMarker[global.selectedDeviceID].markerData
                    .deviceType ==
                global.deviceTypeList[0] &&
            devType != global.deviceTypeList[0]) {
          global.flagCheckSPPU = false;
          _flag = true;
        } else if (!global.flagCheckSPPU &&
            devType == global.deviceTypeList[0]) {
          global.flagCheckSPPU = true;
          _flag = true;
        } else if (global.globalMapMarker[global.selectedDeviceID].markerData
                    .deviceType !=
                global.deviceTypeList[0] &&
            devType != global.deviceTypeList[0]) {
          _flag = true;
        } else {
          showError('СППУ уже существует');
        }

        if (_flag) {
          for (int j = 0; j < dropdownItems.length; j++) {
            if (dropdownItems[j].value ==
                global.globalMapMarker[global.selectedDeviceID].markerData
                    .deviceId
                    .toString()) {
              global.globalMapMarker[global.selectedDeviceID].markerData
                  .deviceType = devType;
              dropdownItems.removeAt(j);

              dropdownValue = global
                  .globalMapMarker[global.selectedDeviceID].markerData.deviceId
                  .toString();
              var newItem = DropdownMenuItem(
                value: dropdownValue,
                child: Text(
                    '${global.globalMapMarker[global.selectedDeviceID].markerData.deviceType} '
                    '#${global.globalMapMarker[global.selectedDeviceID].markerData.deviceId}'),
              );
              dropdownItems.add(newItem);

              global.deviceIDChanged = global.selectedDeviceID;
              break;
            }
          }
        }
      }
    });
  }

  void checkDevCord() {
    setState(() {
      if (global.globalMapMarker[global.selectedDeviceID].markerData.deviceCord!
              .latitude
              .toString()
              .length >
          9) {
        deviceLat = global.globalMapMarker[global.selectedDeviceID].markerData
            .deviceCord!.latitude
            .toString()
            .substring(0, 9);
      } else {
        deviceLat = global.globalMapMarker[global.selectedDeviceID].markerData
            .deviceCord!.latitude
            .toString();
      }
      if (global.globalMapMarker[global.selectedDeviceID].markerData.deviceCord!
              .longitude
              .toString()
              .length >
          9) {
        deviceLon = global.globalMapMarker[global.selectedDeviceID].markerData
            .deviceCord!.longitude
            .toString()
            .substring(0, 9);
      } else {
        deviceLon = global.globalMapMarker[global.selectedDeviceID].markerData
            .deviceCord!.longitude
            .toString();
      }
    });
  }



  bool checkTypeForMainSet() {
    bool flag = false;
    if (global.selectedDeviceID > -1) {
      if (global.deviceTypeList.contains(global
          .globalMapMarker[global.selectedDeviceID].markerData.deviceType)) {
        flag = true;
      }
    }
    return flag;
  }

  Widget buildMainSettings(BuildContext context) {
    setState(() {
      if (global.selectedDeviceID > -1 &&
          bufferSelectedDevice != global.selectedDeviceID.toString()) {
        stringId = global
            .globalMapMarker[global.selectedDeviceID].markerData.deviceId!
            .toString();
        chooseDeviceType = global
            .globalMapMarker[global.selectedDeviceID].markerData.deviceType!
            .toString();
        deviceLat = global.globalMapMarker[global.selectedDeviceID].markerData
            .deviceCord!.latitude
            .toString()
            .substring(0, 9);
        bufferDeviceLat = deviceLat;
        deviceLon = global.globalMapMarker[global.selectedDeviceID].markerData
            .deviceCord!.longitude
            .toString()
            .substring(0, 9);
        bufferDeviceLon = deviceLon;
        bufferSelectedDevice = global.selectedDeviceID.toString();
      }
    });
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
                flex: 2,
                child: SizedBox(
                  width: 100,
                  child: Text('ИД:'),
                )),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: TextFormField(
                  key: Key(stringId),
                  textAlign: TextAlign.center,
                  initialValue: stringId,
                  decoration: InputDecoration(helperText: stringId),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  maxLength: 3,
                  onChanged: (string) => stringId = string,
                ),
              ),
            ),
            Flexible(
                flex: 1,
                child: SizedBox(
                  width: 100,
                  child: IconButton(
                    onPressed: () => checkDevID(int.parse(stringId)),
                    icon: Icon(Icons.check),
                  ),
                )),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
                flex: 2,
                child: SizedBox(
                  width: 100,
                  child: Text('Тип:'),
                )),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: DropdownButton<String>(
                  selectedItemBuilder: (BuildContext context) {
                    return global.deviceTypeList.map((String value) {
                      return Align(
                        alignment: Alignment.center,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList();
                  },
                  isExpanded: true,
                  items: global.deviceTypeList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    chooseDeviceType = value!;
                  },
                  value: chooseDeviceType,
                  icon: const Icon(Icons.keyboard_double_arrow_down),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: SizedBox(
                width: 100,
                child: IconButton(
                  onPressed: () => checkDevType(chooseDeviceType!),
                  icon: Icon(Icons.check),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
                flex: 2,
                child: SizedBox(
                  child: Text('Время дата:'),
                  width: 100,
                )),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: global.selectedDeviceID > -1 &&
                        global.globalMapMarker[global.selectedDeviceID]
                                .markerData.deviceTime !=
                            null
                    ? Text(
                        global.globalMapMarker[global.selectedDeviceID]
                            .markerData.deviceTime!
                            .toString()
                            .substring(0, 19),
                        textAlign: TextAlign.center)
                    : Text(
                        'null',
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
            Flexible(
                flex: 2,
                child: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => TakeTimeClick(global
                            .globalMapMarker[global.selectedDeviceID]
                            .markerData
                            .deviceId!),
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        onPressed: () => SetTimeClick(global
                            .globalMapMarker[global.selectedDeviceID]
                            .markerData
                            .deviceId!),
                        icon: Icon(
                          Icons.access_time,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text('Версия прошивки:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: global.selectedDeviceID > -1 &&
                        global.globalMapMarker[global.selectedDeviceID]
                                .markerData.deviceVersion !=
                            null
                    ? Text(
                        global.globalMapMarker[global.selectedDeviceID]
                            .markerData.deviceVersion!
                            .toString(),
                        textAlign: TextAlign.center)
                    : Text(
                        'null',
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => TakeVersionClick(global
                          .globalMapMarker[global.selectedDeviceID]
                          .markerData
                          .deviceId!),
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCoordSettings(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
                flex: 2,
                child: SizedBox(
                  width: 100,
                  child: Text('Широта:'),
                )),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: TextFormField(
                  //autocorrect: false,
                  key: Key(deviceLat),
                  textAlign: TextAlign.center,
                  initialValue: deviceLat,
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                  onChanged: (string) => {
                    bufferDeviceLat = string,
                  },
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
                flex: 2,
                child: SizedBox(
                  width: 100,
                  child: Text('Долгота:'),
                )),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: TextFormField(
                  key: Key(deviceLon),
                  textAlign: TextAlign.center,
                  initialValue: deviceLon,
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                  onChanged: (string) => {
                    bufferDeviceLon = string,
                  },
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => {
                        TakeCordClick(global
                            .globalMapMarker[global.selectedDeviceID]
                            .markerData
                            .deviceId!),
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => {
                        SetCoordClick(
                            global.globalMapMarker[global.selectedDeviceID]
                                .markerData.deviceId!,
                            double.parse(bufferDeviceLat),
                            double.parse(bufferDeviceLon)),
                      },
                      icon: Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildRadioSettings(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 150,
                child: Text('Мощность сигнала:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: global.selectedDeviceID > -1 &&
                        global.globalMapMarker[global.selectedDeviceID]
                                .markerData.deviceRssi !=
                            null
                    ? Text(
                        global.globalMapMarker[global.selectedDeviceID]
                            .markerData.deviceRssi!
                            .toString(),
                        textAlign: TextAlign.center)
                    : Text(
                        'null',
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => TakeSignalStrengthClick(global
                          .globalMapMarker[global.selectedDeviceID]
                          .markerData
                          .deviceId!),
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 150,
                child: Text('Разрешенные хопы:'),
              ),
            ),
            Flexible(
              flex: 3,
                child: SizedBox(
                  width: 200,
                )
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => TakeAllowedHopsClick(global
                          .globalMapMarker[global.selectedDeviceID]
                          .markerData
                          .deviceId!),
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 150,
                child: Text('Запрещенные хопы:'),
              ),
            ),
            Flexible(
                flex: 3,
                child: SizedBox(
                  width: 200,
                )
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => TakeUnallowedHopsClick(global
                          .globalMapMarker[global.selectedDeviceID]
                          .markerData
                          .deviceId!),
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 150,
                child:
                    Text("Ретранслировать всем:"),
              ),
            ),
            Flexible(
                flex: 3,
                child: SizedBox(
                  width: 200,
                )
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => TakeSignalStrengthClick(global
                          .globalMapMarker[global.selectedDeviceID]
                          .markerData
                          .deviceId!),
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildDeviceSettings(BuildContext context) {
    return Column();
  }

  List<bool> _isOpenMain = List.filled(8, false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        actions: <Widget>[
          DropdownButton<String>(
            icon: const Icon(Icons.keyboard_double_arrow_down),
            value: dropdownValue,
            items: dropdownItems,
            onChanged: (String? value) {
              setState(() {
                dropdownValue = value!;
                setDevId(dropdownValue);
                for (int i = 0; i < global.globalMapMarker.length; i++) {
                  if (global.globalMapMarker[i].markerData.deviceId ==
                      deviceId) {
                    global.selectedDeviceID = i;
                    global.mainBottomSelectedDev = Text(
                      '${global.globalMapMarker[i].markerData.deviceType!} #${global.globalMapMarker[i].markerData.deviceId}',
                      textScaleFactor: 1.4,
                    );
                  }
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(
              visible: checkTypeForMainSet(),
              child: ExpansionPanelList(
                elevation: 2,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isOpenMain[index] = !isExpanded;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Основные'),
                      );
                    },
                    body: buildMainSettings(context),
                    isExpanded: _isOpenMain[0],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Координаты'),
                      );
                    },
                    body: buildCoordSettings(context),
                    isExpanded: _isOpenMain[1],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Радиосеть'),
                      );
                    },
                    body: buildRadioSettings(context),
                    isExpanded: _isOpenMain[2],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Сохранение/Сброс настроек'),
                      );
                    },
                    body: buildDeviceSettings(context),
                    isExpanded: _isOpenMain[3],
                    canTapOnHeader: true,
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
