import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/Application.dart';
import 'package:projects/BasePackage.dart';
import 'package:projects/NetCommonPackages.dart';
import 'package:projects/NetPackagesDataTypes.dart';
import 'package:flutter/services.dart';
import 'package:projects/NetSeismicPackage.dart';

import 'AllEnum.dart';
import 'NetNetworkPackages.dart';
import 'RoutesManager.dart';
import 'core/Device.dart';
import 'global.dart' as global;

class TestPage extends StatefulWidget with TIDManagement {
  List<String> array = [];
  List<DropdownMenuItem<String>> dropdownItems = [];
  String dropdownValue = '', bufferSelectedDevice = '';
  Device device = Device();

  @override
  _TestPage createState() => new _TestPage();

  void addDeviceInDropdown(int devId, String devType) {
    print(devId.toString() + '   ' + devType);
    dropdownValue = devId.toString();
    var newItem = DropdownMenuItem(
      value: dropdownValue,
      child: Text('$devType '
          '#$devId'),
    );
    dropdownItems.add(newItem);
  }

  void changeDeviceInDropdown(int newDevId, String newDevType, String oldDevId) {
    dropdownValue = newDevId.toString();
    var newItem = DropdownMenuItem(
      value: dropdownValue,
      child: Text('$newDevType '
          '#$newDevId'),
    );

    for (int i = 0; i < dropdownItems.length; i++) {
      if (dropdownItems[i].value == oldDevId) {
        dropdownItems.removeAt(i);
        dropdownItems.insert(i, newItem);
        break;
      }
    }
  }

  void deleteDeviceInDropdown(int devId) {
    for (int i = 0; i < dropdownItems.length; i++) {
      if (dropdownItems[i].value == devId.toString()) {
        dropdownItems.removeAt(i);
        if (i == dropdownItems.length && i > 0){
          dropdownValue = dropdownItems[i - 1].value.toString();
          print (global.selectedDeviceID);
        }else{
          dropdownValue = dropdownItems[i].value.toString();
          print (global.selectedDeviceID);
        }
        break;
      }
    }
  }

  void selectDeviceInDropdown(int devId) {
    for (int i = 0; i < dropdownItems.length; i++) {
      if (dropdownItems[i].value == devId.toString()) {
          dropdownValue = dropdownItems[i].value.toString();
          break;
        }
      }
    }

  @override
  void acknowledgeReceived(int tid, BasePackage basePackage) {
    tits.remove(tid);
    array.add('acknowledgeReceived');
  }

  @override
  void dataReceived(int tid, BasePackage basePackage) {
    global.dataComeFlag = true;
    tits.remove(tid);
    if (basePackage.getType() == PackageType.VERSION) {
      var package = basePackage as VersionPackage;
      print('dataReceived: ${package.getVersion()}');
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceVersion = package.getVersion();
        }
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].firmwareVersion = package.getVersion();
          global.mapClass.MapMarkerActivate(package.getSender());
        }
      }
      array.add('dataReceived: ${package.getVersion()}');
    }

    if (basePackage.getType() == PackageType.TIME) {
      var package = basePackage as TimePackage;
      print('dataReceived: ${package.getTime()}');
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceTime = package.getTime();
          global.globalMapMarker[i].markerData.deviceAvailable = true;
          global.globalMapMarker[i].markerData.deviceReturnCheck = true;
        }
      }
      array.add('dataReceived: ${package.getTime()}');
    }

    if (basePackage.getType() == PackageType.ALL_INFORMATION) {
      var package = basePackage as AllInformationPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceAvailable = true;
          global.globalMapMarker[i].markerData.deviceReturnCheck = true;
          global.globalMapMarker[i].markerData.deviceCord!.longitude = package.getLongitude();
          global.globalMapMarker[i].markerData.deviceCord!.latitude = package.getLatitude();
          global.globalMapMarker[i].markerData.deviceTime = package.getTime();
          global.globalMapMarker[i].markerData.deviceLastAlarmType = package.getLastAlarmType();
          global.globalMapMarker[i].markerData.deviceLastAlarmReason = package.getLastAlarmReason();
          global.globalMapMarker[i].markerData.deviceLastAlarmTime = package.getLastAlarmTime();
          global.globalMapMarker[i].markerData.deviceStateMask = package.getStateMask();
          global.globalMapMarker[i].markerData.deviceBattery = package.getBattery();

          print('dataReceived: ${global.globalMapMarker[i].markerData.deviceCord}');
          print('dataReceived: ${global.globalMapMarker[i].markerData.deviceTime}');
          print('dataReceived: ${global.globalMapMarker[i].markerData.deviceLastAlarmType}');
          print('dataReceived: ${global.globalMapMarker[i].markerData.deviceLastAlarmReason}');
          print('dataReceived: ${global.globalMapMarker[i].markerData.deviceLastAlarmTime}');
          print('dataReceived: ${global.globalMapMarker[i].markerData.deviceStateMask}');
          print('dataReceived: ${global.globalMapMarker[i].markerData.deviceBattery}');

          array.add('dataReceived: ${global.globalMapMarker[i].markerData.deviceCord}');
          array.add('dataReceived: ${global.globalMapMarker[i].markerData.deviceTime}');
          array.add('dataReceived: ${global.globalMapMarker[i].markerData.deviceLastAlarmType}');
          array.add('dataReceived: ${global.globalMapMarker[i].markerData.deviceLastAlarmReason}');
          array.add('dataReceived: ${global.globalMapMarker[i].markerData.deviceLastAlarmTime}');
          array.add('dataReceived: ${global.globalMapMarker[i].markerData.deviceStateMask}');
          array.add('dataReceived: ${global.globalMapMarker[i].markerData.deviceBattery}');
        }
      }
      /*print('dataReceived: ${package.getLatitude()}');
      array.add('dataReceived: ${package.getLatitude()}');
      print('dataReceived: ${package.getLongitude()}');
      array.add('dataReceived: ${package.getLongitude()}');*/
    }

    if (basePackage.getType() == PackageType.COORDINATE) {
      var package = basePackage as CoordinatesPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceAvailable = true;
          global.globalMapMarker[i].markerData.deviceReturnCheck = true;
          global.globalMapMarker[i].markerData.deviceCord!.longitude = package.getLongitude();
          global.globalMapMarker[i].markerData.deviceCord!.latitude = package.getLatitude();
        }
      }

      print('dataReceived: ${package.getLatitude()}');
      array.add('dataReceived: ${package.getLatitude()}');
      print('dataReceived: ${package.getLongitude()}');
      array.add('dataReceived: ${package.getLongitude()}');
    }

    if (basePackage.getType() == PackageType.INFORMATION) {
      var package = basePackage as InformationPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceState = package.getState();
          global.globalMapMarker[i].markerData.deviceBattery = package.getBattery();
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

    if (basePackage.getType() == PackageType.ALLOWED_HOPS && !global.retransmissionRequests.contains(tid)) {
      var package = basePackage as HopsPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceAllowedHops = package.getHops();
        }
      }

      print('dataReceived: ${package.getHops()}');
      array.add('dataReceived: ${package.getHops()}');
      global.allowedHopsCame = true;
    }

    if (basePackage.getType() == PackageType.ALLOWED_HOPS && global.retransmissionRequests.contains(tid)) {
      global.retransmissionRequests.remove(tid);
      var package = basePackage as HopsPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceRetransmissionToAll = package.getHops();
        }
      }
      print('dataReceived: ${package.getHops()}');
      array.add('dataReceived: ${package.getHops()}');
      //global.allowedHopsCame = true;
    }

    if (basePackage.getType() == PackageType.UNALLOWED_HOPS) {
      var package = basePackage as HopsPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceUnallowedHops = package.getHops();
        }

        print('dataReceived: ${package.getHops()}');
        array.add('dataReceived: ${package.getHops()}');
        global.unallowedHopsCame = true;
      }
    }

    if (basePackage.getType() == PackageType.STATE) {
      var package = basePackage as StatePackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceMaskExtDevice = package.getStateMask();
          global.globalMapMarker[i].markerData.extDevice1 =
              ((global.globalMapMarker[i].markerData.deviceMaskExtDevice! & DeviceState.MONITORING_LINE1) != 0);
          global.globalMapMarker[i].markerData.extDevice2 =
              ((global.globalMapMarker[i].markerData.deviceMaskExtDevice! & DeviceState.MONITORING_LINE2) != 0);
          global.globalMapMarker[i].markerData.devicePhototrap =
              ((global.globalMapMarker[i].markerData.deviceMaskExtDevice! & DeviceState.LINES_CAMERA_TRAP) != 0);
          global.globalMapMarker[i].markerData.deviceGeophone =
              ((global.globalMapMarker[i].markerData.deviceMaskExtDevice! & DeviceState.MONITOR_SEISMIC) != 0);
        }
      }

      print('dataReceived: ${package.getStateMask()}');
      array.add('dataReceived: ${package.getStateMask()}');
    }

    if (basePackage.getType() == PackageType.PERIPHERY) {
      var package = basePackage as PeripheryMaskPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceMaskPeriphery = package.getPeripheryMask();

          global.globalMapMarker[i].markerData.deviceExtDev1State =
              ((global.globalMapMarker[i].markerData.deviceMaskPeriphery! & PeripheryMask.LINE1) != 0);
          global.globalMapMarker[i].markerData.deviceExtDev2State =
              ((global.globalMapMarker[i].markerData.deviceMaskPeriphery! & PeripheryMask.LINE2) != 0);
          global.globalMapMarker[i].markerData.deviceExtPhototrapState =
              ((global.globalMapMarker[i].markerData.deviceMaskPeriphery! & PeripheryMask.CAMERA) != 0);
        }
      }
      print('dataReceived: ${package.getPeripheryMask()}');
      array.add('dataReceived: ${package.getPeripheryMask()}');
    }

    if (basePackage.getType() == PackageType.EXTERNAL_POWER) {
      var package = basePackage as ExternalPowerPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceExternalPower = package.getExternalPowerState().index;
        }
      }
      print('dataReceived: ${package.getExternalPowerState()}');
      array.add('dataReceived: ${package.getExternalPowerState()}');
    }

    if (basePackage.getType() == PackageType.BATTERY_MONITOR) {
      var package = basePackage as BatteryMonitorPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceVoltage = package.getVoltage();
          global.globalMapMarker[i].markerData.deviceTemperature = package.getTemperature();
        }
      }
      print('dataReceived: ${package.getTemperature()}');
      array.add('dataReceived: ${package.getTemperature()}');
      print('dataReceived: ${package.getVoltage()}');
      array.add('dataReceived: ${package.getVoltage()}');
    }

    if (basePackage.getType() == PackageType.ALARM_REASON_MASK) {
      var package = basePackage as AlarmReasonMaskPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          print(package.getAlarmReasonMask());
          if (package.getAlarmReasonMask() == 0) {
            global.globalMapMarker[i].markerData.humanAlarm = false;
            global.globalMapMarker[i].markerData.transportAlarm = false;
          }
          if (package.getAlarmReasonMask() == 8) {
            global.globalMapMarker[i].markerData.humanAlarm = true;
            global.globalMapMarker[i].markerData.transportAlarm = false;
          }
          if (package.getAlarmReasonMask() == 16) {
            global.globalMapMarker[i].markerData.humanAlarm = false;
            global.globalMapMarker[i].markerData.transportAlarm = true;
          }
          if (package.getAlarmReasonMask() == 24) {
            global.globalMapMarker[i].markerData.humanAlarm = true;
            global.globalMapMarker[i].markerData.transportAlarm = true;
          }
        }
      }
      print('dataReceived: ${package.getAlarmReasonMask()}');
      array.add('dataReceived: ${package.getAlarmReasonMask()}');
    }

    if (basePackage.getType() == PackageType.SIGNAL_SWING) {
      var package = basePackage as SeismicSignalSwingPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceSignalSwing = package.getSignalSwing();
        }
      }
      print('dataReceived: ${package.getSignalSwing()}');
      array.add('dataReceived: ${package.getSignalSwing()}');
    }

    if (basePackage.getType() == PackageType.HUMAN_SENSITIVITY) {
      var package = basePackage as HumanSensitivityPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceHumanSensitivity = package.getHumanSensitivity();
        }
      }
      print('dataReceived: ${package.getHumanSensitivity()}');
      array.add('dataReceived: ${package.getHumanSensitivity()}');
    }

    //todo
  }

  @override
  void alarmReceived(BasePackage basePackage) {
    if (basePackage.getType() == PackageType.ALARM) {
      var package = basePackage as AlarmPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalMapMarker[i].markerData.deviceId == package.getSender()) {
          global.globalMapMarker[i].markerData.deviceAlarm = true;
          print('dataReceived: ${package.getAlarmType()}');
          global.mapClass.MapMarkerAlarm(global.globalMapMarker[i].markerData.deviceId!);
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

class _TestPage extends State<TestPage> with AutomaticKeepAliveClientMixin<TestPage> {
  bool get wantKeepAlive => true;
  bool checked = false;
  int? deviceId, intPhotoCompression;
  String dropdownValue = '', bufferSelectedDevice = '';

  ScrollController _scrollController = ScrollController();
  List<DropdownMenuItem<String>> dropdownItems = [];
  String stringId = '';
  String? chooseDeviceType, choosePhotoCompression;
  String deviceLat = '',
      deviceLon = '',
      bufferDeviceLon = '',
      bufferDeviceLat = '',
      cameraFrequency = '',
      bufferCameraFrequency = '',
      crossDevice = '';

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
    if (global.allowedHopsCame == true) {
      dialogAllowedHopsBuilder();
      global.allowedHopsCame = false;
    }
    if (global.unallowedHopsCame == true) {
      dialogUnallowedHopsBuilder();
      global.unallowedHopsCame = false;
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
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_TIME);
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
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_VERSION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeCordClick(int devId) {
    setState(() {
      Timer? timer;
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_COORDINATE);
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
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_INFORMATION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeAllInfoClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_ALL_INFORMATION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeStrengthSignalClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_INFORMATION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeAllowedHopsClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_ALLOWED_HOPS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void dialogAllowedHopsBuilder() {
    print('object');
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
      },
    );
  }

  void TakeUnallowedHopsClick(int devId) {
    setState(
      () {
        BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_UNALLOWED_HOPS);
        var tid = global.postManager.sendPackage(getInfo);
        widget.tits.add(tid);
      },
    );
  }

  void dialogUnallowedHopsBuilder() {
    print('object');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Запрещенные хопы'),
          content: Text(global.globalMapMarker[global.selectedDeviceID].markerData.deviceUnallowedHops.toString()),
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

  void TakeRetransmissionAllClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_ALLOWED_HOPS);
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
      hopsPackage.addHop(checked ? RoutesManager.getRtAllHop() : 0);
      var tid = global.postManager.sendPackage(hopsPackage);
      widget.tits.add(tid);
      global.retransmissionRequests.add(tid);
    });
  }

  void ButtonResetRetransmissionClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.SET_DEFAULT_NETWORK);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeInternalDeviceParamClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_STATE);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void SetInternalDeviceParamClick(int devId, bool dev1, bool dev2, bool dev3, bool dev4) {
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
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_PERIPHERY);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeExternalPowerClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_EXTERNAL_POWER);
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
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_BATTERY_MONITOR);
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

  void TakeStateHumanTransportSensitivityClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_ALARM_REASON_MASK);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void SetStateHumanTransportSensitivityClick(int devId, bool human, bool transport) {
    setState(() {
      AlarmReasonMaskPackage alarmReasonMaskPackage = AlarmReasonMaskPackage();
      alarmReasonMaskPackage.setReceiver(devId);
      alarmReasonMaskPackage.setSender(RoutesManager.getLaptopAddress());
      if (human == false && transport == false) {
        alarmReasonMaskPackage.setAlarmReasonMask(0);
      }
      if (human == true && transport == false) {
        alarmReasonMaskPackage.setAlarmReasonMask(8);
      }
      if (human == false && transport == true) {
        alarmReasonMaskPackage.setAlarmReasonMask(16);
      }
      if (human == true && transport == true) {
        alarmReasonMaskPackage.setAlarmReasonMask(24);
      }
      var tid = global.postManager.sendPackage(alarmReasonMaskPackage);
      widget.tits.add(tid);
    });
  }

  void TakeSignalSwingClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_SIGNAL_SWING);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void TakeHumanSensitivityClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_HUMAN_SENSITIVITY);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void SetHumanSensitivityClick(int devId, int sensitivity) {
    setState(() {
      HumanSensitivityPackage humanSensitivityPackage = HumanSensitivityPackage();
      humanSensitivityPackage.setReceiver(devId);
      humanSensitivityPackage.setSender(RoutesManager.getLaptopAddress());
      humanSensitivityPackage.setHumanSensitivity(sensitivity);
      var tid = global.postManager.sendPackage(humanSensitivityPackage);
      widget.tits.add(tid);
    });
  }

  void TakeTransportSensitivityClick(int devId) {}

  void SetTransportSensitivityClick(int devId, int sensitivity) {}

  void TakeTransportFilterClick(int devId) {}

  void SetTransportFilterClick(int devId, int filter) {}

  void TakeRatioTransportNoiseClick(int devId) {}

  void SetRatioTransportNoiseClick(int devId, int ratio) {}

  void TakeRecognitionParamClick(int devId) {}

  void SetRecognitionParamClick(int devId, int hindranceHuman, int humanTransport) {}

  void TakeAlarmFilterClick(int devId) {}

  void SetAlarmFilterClick(int devId, int singleHuman, int singleTransport, int seriesHuman, int seriesTransport) {}

  void TakePhotoCompressionClick(int devId) {}

  void SetPhotoCompressionClick(int devId, String value) {}

  void restartDevice() {}

  void saveDeviceParam() {}

  void returnDeviceToDefaultParam() {}

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

  void checkDevID(int markerIdForCheck, int oldDevId) {
    setState(() {
      if (markerIdForCheck > 0 && markerIdForCheck < 256) {
        for (int i = 0; i < global.globalDeviceList.length; i++) {
          if (global.globalDeviceList[i].id == markerIdForCheck) {
            showError('Такой ИД уже существует');
            break;
          }
          global.mapClass.ChangeMapMarker(
              oldDevId, markerIdForCheck, global.globalDeviceList[i].type.index, global.globalDeviceList[i], global.selectedDeviceID);
          widget.changeDeviceInDropdown(markerIdForCheck, global.globalDeviceList[i].type.name, oldDevId.toString());
        }
      } else {
        showError("Неверный ИД \n"
            "ИД может быть от 1 до 255");
      }
    });
  }

  void checkDevType(String devType) {
    setState(() {
      int id = global.globalDeviceList[global.selectedDeviceID].id;

      if (devType == global.deviceTypeList[0] &&
          global.globalMapMarker[global.selectedDeviceID].markerData.deviceType != global.deviceTypeList[0] &&
          global.flagCheckSPPU == true) {
        showError('СППУ уже существует');
      } else {
        widget.changeDeviceInDropdown(id, devType, id.toString());
        global.mapClass.ChangeMapMarker(
            id, id, global.deviceTypeList.indexOf(devType), global.globalDeviceList[global.selectedDeviceID], global.selectedDeviceID);
      }
    });
  }

  void checkDevCord() {
    setState(() {
      if (global.globalMapMarker[global.selectedDeviceID].markerData.deviceCord!.latitude.toString().length > 9) {
        deviceLat = global.globalMapMarker[global.selectedDeviceID].markerData.deviceCord!.latitude.toString().substring(0, 9);
      } else {
        deviceLat = global.globalMapMarker[global.selectedDeviceID].markerData.deviceCord!.latitude.toString();
      }
      if (global.globalMapMarker[global.selectedDeviceID].markerData.deviceCord!.longitude.toString().length > 9) {
        deviceLon = global.globalMapMarker[global.selectedDeviceID].markerData.deviceCord!.longitude.toString().substring(0, 9);
      } else {
        deviceLon = global.globalMapMarker[global.selectedDeviceID].markerData.deviceCord!.longitude.toString();
      }
    });
  }

  bool checkTypeForMainSet() {
    bool flag = false;
    if (global.selectedDeviceID > -1) {
      flag = true;
    }
    /*for (int i = 0; i < global.globalMapMarker.length; i++){

      }
      if (global.deviceTypeList.contains(global
          .globalMapMarker[global.selectedDeviceID].markerData.deviceType)) {
        flag = true;
      }
    }*/
    return flag;
  }

  Widget buildMainSettings(BuildContext context) {
    setState(() {
      if (global.selectedDeviceID > -1 && bufferSelectedDevice != global.selectedDeviceID.toString()) {
        stringId = global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!.toString();
        chooseDeviceType = global.globalMapMarker[global.selectedDeviceID].markerData.deviceType!.toString();
        deviceLat = global.globalMapMarker[global.selectedDeviceID].markerData.deviceCord!.latitude.toString().substring(0, 9);
        bufferDeviceLat = deviceLat;
        deviceLon = global.globalMapMarker[global.selectedDeviceID].markerData.deviceCord!.longitude.toString().substring(0, 9);
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
                  /*onChanged: (string) => stringId = string,*/
                ),
              ),
            ),
            Flexible(
                flex: 1,
                child: SizedBox(
                  width: 100,
                  child: IconButton(
                    onPressed: () => checkDevID(int.parse(stringId), global.globalDeviceList[global.selectedDeviceID].id),
                    icon: Icon(Icons.check),
                    color: Colors.green,
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
                  items: global.deviceTypeList.map<DropdownMenuItem<String>>((String value) {
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
                  color: Colors.green,
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
                child: global.selectedDeviceID > -1 && global.globalMapMarker[global.selectedDeviceID].markerData.deviceTime != null
                    ? Text(global.globalMapMarker[global.selectedDeviceID].markerData.deviceTime!.toString().substring(0, 19),
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
                        onPressed: () => TakeTimeClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        onPressed: () => SetTimeClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
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
                child: global.selectedDeviceID > -1 && global.globalMapMarker[global.selectedDeviceID].markerData.deviceVersion != null
                    ? Text(global.globalMapMarker[global.selectedDeviceID].markerData.deviceVersion!.toString(),
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
                      onPressed: () => TakeVersionClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
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
                        TakeCordClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => {
                        SetCoordClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!, double.parse(bufferDeviceLat),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                child: global.selectedDeviceID > -1 && global.globalMapMarker[global.selectedDeviceID].markerData.deviceRssi != null
                    ? Text(global.globalMapMarker[global.selectedDeviceID].markerData.deviceRssi!.toString(), textAlign: TextAlign.center)
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
                      onPressed: () => TakeSignalStrengthClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
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
                )),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => TakeAllowedHopsClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
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
                )),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => TakeUnallowedHopsClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
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
                child: Text("Ретранслировать всем:"),
              ),
            ),
            Flexible(
                flex: 3,
                child: SizedBox(
                  width: 200,
                  child: Checkbox(
                      value: global.selectedDeviceID > -1 &&
                              global.globalMapMarker[global.selectedDeviceID].markerData.deviceRetransmissionToAll != null
                          ? global.globalMapMarker[global.selectedDeviceID].markerData.deviceRetransmissionToAll![0] == 65535
                          : false,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value! == true) {
                            global.globalMapMarker[global.selectedDeviceID].markerData.deviceRetransmissionToAll![0] = 65535;
                          } else {
                            global.globalMapMarker[global.selectedDeviceID].markerData.deviceRetransmissionToAll![0] = 0;
                          }
                        });
                      }),
                )),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => TakeRetransmissionAllClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => SetRetransmissionAllClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!,
                          global.globalMapMarker[global.selectedDeviceID].markerData.deviceRetransmissionToAll![0] == 65535),
                      icon: Icon(Icons.check),
                      color: Colors.green,
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
            SizedBox(
              height: 40,
              child: OutlinedButton(
                onPressed: () => ButtonResetRetransmissionClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                child: Text('Сброс ретрансляции'),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget buildDeviceSettings(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton(
          onPressed: restartDevice,
          child: Row(
            children: [
              Icon(Icons.restart_alt),
              Text('Перезагрузить устройство'),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: saveDeviceParam,
          child: Row(
            children: [
              Icon(Icons.save),
              Text('Сохранить настройки'),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: restartDevice,
          child: Row(
            children: [
              Icon(Icons.restore),
              Text('Сбросить к заводским'),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildConnectedDevicesRT(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 150,
                child: Text("Вкл./Выкл. устройств:"),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Вн. устр. 1:"),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: Checkbox(
                    value: global.selectedDeviceID > -1 ? global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1 : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1 = value!;
                      });
                    }),
              ),
            ),
            const Flexible(
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
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Вн. устр. 2:"),
              ),
            ),
            Flexible(
                flex: 3,
                child: SizedBox(
                  width: 200,
                  child: Checkbox(
                      value: global.selectedDeviceID > -1 ? global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2 : false,
                      onChanged: (bool? value) {
                        setState(() {
                          global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2 = value!;
                        });
                      }),
                )),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => TakeInternalDeviceParamClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => SetInternalDeviceParamClick(
                          global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!,
                          global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1,
                          global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2,
                          false,
                          false),
                      icon: const Icon(Icons.check),
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 150,
                child: Text("Состояние устройств:"),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Вн. устр. 1:"),
              ),
            ),
            Visibility(
              visible: global.selectedDeviceID > -1 && global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1,
              child: Flexible(
                flex: 3,
                child: SizedBox(
                  width: 200,
                  child: Checkbox(
                      value: global.selectedDeviceID > -1
                          ? global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtDev1State
                          : false,
                      onChanged: (bool? value) {
                        setState(() {
                          global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtDev1State = value!;
                        });
                      }),
                ),
              ),
            ),
            const Flexible(
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
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Вн. устр. 2:"),
              ),
            ),
            Visibility(
              visible: global.selectedDeviceID > -1 && global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2,
              child: Flexible(
                  flex: 3,
                  child: SizedBox(
                    width: 200,
                    child: Checkbox(
                        value: global.selectedDeviceID > -1
                            ? global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtDev2State
                            : false,
                        onChanged: (bool? value) {
                          setState(() {
                            global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtDev2State = value!;
                          });
                        }),
                  )),
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => TakeInternalDeviceStateClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                      icon: const Icon(
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

  Widget buildConnectedDevicesCSD(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 150,
                child: Text("Вкл./Выкл. устройств:"),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Вн. устр. 1:"),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: Checkbox(
                    value: global.selectedDeviceID > -1 ? global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1 : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1 = value!;
                      });
                    }),
              ),
            ),
            const Flexible(
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
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Вн. устр. 2:"),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: Checkbox(
                    value: global.selectedDeviceID > -1 ? global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2 : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2 = value!;
                      });
                    }),
              ),
            ),
            const Flexible(
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
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Геофон:"),
              ),
            ),
            Flexible(
                flex: 3,
                child: SizedBox(
                  width: 200,
                  child: Checkbox(
                      value:
                          global.selectedDeviceID > -1 ? global.globalMapMarker[global.selectedDeviceID].markerData.deviceGeophone : false,
                      onChanged: (bool? value) {
                        setState(() {
                          global.globalMapMarker[global.selectedDeviceID].markerData.deviceGeophone = value!;
                        });
                      }),
                )),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => TakeInternalDeviceParamClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => SetInternalDeviceParamClick(
                          global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!,
                          global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1,
                          global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2,
                          global.globalMapMarker[global.selectedDeviceID].markerData.deviceGeophone,
                          false),
                      icon: const Icon(Icons.check),
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 150,
                child: Text("Состояние устройств:"),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Вн. устр. 1:"),
              ),
            ),
            Visibility(
              visible: global.selectedDeviceID > -1 && global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1,
              child: Flexible(
                flex: 3,
                child: SizedBox(
                  width: 200,
                  child: Checkbox(
                      value: global.selectedDeviceID > -1
                          ? global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtDev1State
                          : false,
                      onChanged: (bool? value) {
                        setState(() {
                          global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtDev1State = value!;
                        });
                      }),
                ),
              ),
            ),
            const Flexible(
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
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Вн. устр. 2:"),
              ),
            ),
            Visibility(
              visible: global.selectedDeviceID > -1 && global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2,
              child: Flexible(
                  flex: 3,
                  child: SizedBox(
                    width: 200,
                    child: Checkbox(
                        value: global.selectedDeviceID > -1
                            ? global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtDev2State
                            : false,
                        onChanged: (bool? value) {
                          setState(() {
                            global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtDev2State = value!;
                          });
                        }),
                  )),
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => TakeInternalDeviceStateClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                      icon: const Icon(
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

  Widget buildConnectedDevicesCFU(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 150,
                child: Text("Вкл./Выкл. устройств:"),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Вн. устр. 1:"),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: Checkbox(
                    value: global.selectedDeviceID > -1 ? global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1 : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1 = value!;
                      });
                    }),
              ),
            ),
            const Flexible(
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
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Вн. устр. 2:"),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: Checkbox(
                    value: global.selectedDeviceID > -1 ? global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2 : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2 = value!;
                      });
                    }),
              ),
            ),
            const Flexible(
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
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Обр. лин. фотоловушки:"),
              ),
            ),
            Flexible(
                flex: 3,
                child: SizedBox(
                  width: 200,
                  child: Checkbox(
                      value: global.selectedDeviceID > -1
                          ? global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtPhototrapState
                          : false,
                      onChanged: (bool? value) {
                        setState(() {
                          global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtPhototrapState = value!;
                        });
                      }),
                )),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => TakeInternalDeviceParamClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => SetInternalDeviceParamClick(
                          global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!,
                          global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1,
                          global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2,
                          false,
                          global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtPhototrapState),
                      icon: const Icon(Icons.check),
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 150,
                child: Text("Состояние устройств:"),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Вн. устр. 1:"),
              ),
            ),
            Visibility(
              visible: global.selectedDeviceID > -1 && global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1,
              child: Flexible(
                flex: 3,
                child: SizedBox(
                  width: 200,
                  child: Checkbox(
                      value: global.selectedDeviceID > -1
                          ? global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtDev1State
                          : false,
                      onChanged: (bool? value) {
                        setState(() {
                          global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtDev1State = value!;
                        });
                      }),
                ),
              ),
            ),
            const Flexible(
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
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Вн. устр. 2:"),
              ),
            ),
            Visibility(
              visible: global.selectedDeviceID > -1 && global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2,
              child: Flexible(
                  flex: 3,
                  child: SizedBox(
                    width: 200,
                    child: Checkbox(
                        value: global.selectedDeviceID > -1
                            ? global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtDev2State
                            : false,
                        onChanged: (bool? value) {
                          setState(() {
                            global.globalMapMarker[global.selectedDeviceID].markerData.deviceExtDev2State = value!;
                          });
                        }),
                  )),
            ),
            const Flexible(
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
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text("Камера:"),
              ),
            ),
            Visibility(
              visible: global.selectedDeviceID > -1 && global.globalMapMarker[global.selectedDeviceID].markerData.devicePhototrap,
              child: Flexible(
                flex: 3,
                child: SizedBox(
                  width: 200,
                  child: Checkbox(
                      value:
                          global.selectedDeviceID > -1 ? global.globalMapMarker[global.selectedDeviceID].markerData.devicePhototrap : false,
                      onChanged: (bool? value) {
                        setState(() {
                          global.globalMapMarker[global.selectedDeviceID].markerData.devicePhototrap = value!;
                        });
                      }),
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
                      onPressed: () => TakeInternalDeviceStateClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                      icon: const Icon(
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

  //TODO: Поправить

  Widget buildExtPower(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 150,
              child: Text("Предохранитель:"),
            ),
          ),
          Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: Checkbox(
                    value: global.selectedDeviceID > -1 ? global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2 : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2 = value!;
                      });
                    }),
              )),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () => TakeInternalDeviceParamClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => SetInternalDeviceParamClick(
                        global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!,
                        global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1,
                        global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2,
                        false,
                        false),
                    icon: const Icon(Icons.check),
                    color: Colors.green,
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
                width: 100,
                child: Text('Задержка \nактивации:'),
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
                items: global.deviceTypeList.map<DropdownMenuItem<String>>((String value) {
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
          const Flexible(
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
                child: Text('Длительность \nимпульса:'),
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
                items: global.deviceTypeList.map<DropdownMenuItem<String>>((String value) {
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
          const Flexible(
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
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 150,
              child: Text("Включение по обрывной:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Visibility(
                visible: true, //TODO
                child: Checkbox(
                    value: global.selectedDeviceID > -1 ? global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2 : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2 = value!;
                      });
                    }),
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
                    onPressed: () => TakeInternalDeviceParamClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => SetInternalDeviceParamClick(
                        global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!,
                        global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1,
                        global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2,
                        false,
                        false),
                    icon: const Icon(Icons.check),
                    color: Colors.green,
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
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 150,
              child: Text("Питание:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Visibility(
                visible: true, //TODO
                child: Checkbox(
                    value: global.selectedDeviceID > -1 ? global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2 : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2 = value!;
                      });
                    }),
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
                    onPressed: () => TakeInternalDeviceParamClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => SetInternalDeviceParamClick(
                        global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!,
                        global.globalMapMarker[global.selectedDeviceID].markerData.extDevice1,
                        global.globalMapMarker[global.selectedDeviceID].markerData.extDevice2,
                        false,
                        false),
                    icon: const Icon(Icons.check),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget buildPowerSupply(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 150,
                child: Text('Напряжение, В:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: global.selectedDeviceID > -1 && global.globalMapMarker[global.selectedDeviceID].markerData.deviceBattery != null
                    ? Text(global.globalMapMarker[global.selectedDeviceID].markerData.deviceBattery!.toString(),
                        textAlign: TextAlign.center)
                    : Text(
                        'null',
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
            const Flexible(
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
                width: 150,
                child: Text('Температура, °С:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: global.selectedDeviceID > -1 && global.globalMapMarker[global.selectedDeviceID].markerData.deviceTemperature != null
                    ? Text(global.globalMapMarker[global.selectedDeviceID].markerData.deviceTemperature!.toString(),
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
                      onPressed: () => TakeBatteryMonitorClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
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

//TODO: Поправить (again)
  Widget buildSeismicSettings(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Text("Человек:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                  value: global.selectedDeviceID > -1 ? global.globalMapMarker[global.selectedDeviceID].markerData.humanAlarm : false,
                  onChanged: (bool? value) {
                    setState(() {
                      global.globalMapMarker[global.selectedDeviceID].markerData.humanAlarm = value!;
                    });
                  }),
            ),
          ),
          const Flexible(
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
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Text("Транспорт:"),
            ),
          ),
          Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: Checkbox(
                    value: global.selectedDeviceID > -1 ? global.globalMapMarker[global.selectedDeviceID].markerData.transportAlarm : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalMapMarker[global.selectedDeviceID].markerData.transportAlarm = value!;
                      });
                    }),
              )),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () =>
                        TakeStateHumanTransportSensitivityClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => SetStateHumanTransportSensitivityClick(
                        global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!,
                        global.globalMapMarker[global.selectedDeviceID].markerData.humanAlarm,
                        global.globalMapMarker[global.selectedDeviceID].markerData.transportAlarm),
                    icon: const Icon(Icons.check),
                    color: Colors.green,
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
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 150,
              child: Text('Размах сигнала:'),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: global.selectedDeviceID > -1 && global.globalMapMarker[global.selectedDeviceID].markerData.deviceSignalSwing != null
                  ? Text(global.globalMapMarker[global.selectedDeviceID].markerData.deviceSignalSwing!.toString(),
                      textAlign: TextAlign.center)
                  : const Text(
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
                    onPressed: () => TakeSignalSwingClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                    icon: const Icon(
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
          const Flexible(
              flex: 2,
              child: SizedBox(
                width: 140,
                child: Text('Чувствительность \nпо человеку:\n(25-255)'),
              )),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: TextFormField(
                textAlign: TextAlign.center,
                initialValue: global.selectedDeviceID > -1 ? '100' : '25',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String value = newValue.text;
                    global.globalMapMarker[global.selectedDeviceID].markerData.deviceHumanSensitivity = int.parse(value);
                    if (value.length > 3) {
                      return TextEditingValue(
                        text: oldValue.text,
                        selection: TextSelection.collapsed(offset: oldValue.selection.end),
                      );
                    }
                    if (global.globalMapMarker[global.selectedDeviceID].markerData.deviceHumanSensitivity! < 25) {
                      global.globalMapMarker[global.selectedDeviceID].markerData.deviceHumanSensitivity = 25;
                    }
                    if (global.globalMapMarker[global.selectedDeviceID].markerData.deviceHumanSensitivity! > 255) {
                      global.globalMapMarker[global.selectedDeviceID].markerData.deviceHumanSensitivity = 255;
                    }
                    return TextEditingValue(
                      text: global.globalMapMarker[global.selectedDeviceID].markerData.deviceHumanSensitivity.toString(),
                      selection: TextSelection.collapsed(
                          offset: global.globalMapMarker[global.selectedDeviceID].markerData.deviceHumanSensitivity.toString().length),
                    );
                  })
                ],
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
                    onPressed: () => TakeHumanSensitivityClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => SetHumanSensitivityClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!,
                        global.globalMapMarker[global.selectedDeviceID].markerData.deviceHumanSensitivity!),
                    icon: const Icon(Icons.check),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget buildCameraSettings(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
                flex: 2,
                child: SizedBox(
                  width: 100,
                  child: Text('Чувствительность:'),
                )),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: TextFormField(
                  //autocorrect: false,
                  key: Key(cameraFrequency),
                  textAlign: TextAlign.center,
                  initialValue: cameraFrequency,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  onChanged: (string) => {
                    bufferCameraFrequency = string,
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
                  child: Text('Сжатие фотографий:'),
                )),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: DropdownButton<String>(
                  selectedItemBuilder: (BuildContext context) {
                    return global.photoCompression.map((String value) {
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
                  items: global.photoCompression.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    choosePhotoCompression = value!;
                  },
                  value: choosePhotoCompression,
                  icon: const Icon(Icons.keyboard_double_arrow_down),
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
                        TakePhotoCompressionClick(global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!),
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => {
                        SetPhotoCompressionClick(
                            global.globalMapMarker[global.selectedDeviceID].markerData.deviceId!, choosePhotoCompression!),
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

  final List<bool> _isOpenMain = List.filled(4, false);
  final List<bool> _isOpenCSD = List.filled(8, false);
  final List<bool> _isOpenCFU = List.filled(8, false);
  final List<bool> _isOpenRT = List.filled(7, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        actions: <Widget>[
          DropdownButton<String>(
            icon: const Icon(Icons.keyboard_double_arrow_down),
            value: widget.dropdownValue,
            items: widget.dropdownItems,
            onChanged: (String? value) {
              setState(() {
                widget.dropdownValue = value!;
                setDevId(widget.dropdownValue);
                for (int i = 0; i < global.globalMapMarker.length; i++) {
                  if (global.globalMapMarker[i].markerData.deviceId == deviceId) {
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
              visible: chooseDeviceType == global.deviceTypeList[0],
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
            Visibility(
              visible: chooseDeviceType == global.deviceTypeList[3],
              child: ExpansionPanelList(
                elevation: 2,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isOpenRT[index] = !isExpanded;
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
                    isExpanded: _isOpenRT[0],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Координаты'),
                      );
                    },
                    body: buildCoordSettings(context),
                    isExpanded: _isOpenRT[1],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Подключенные устройства'),
                      );
                    },
                    body: buildConnectedDevicesRT(context),
                    isExpanded: _isOpenRT[2],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Внешнее питание'),
                      );
                    },
                    body: buildExtPower(context),
                    isExpanded: _isOpenRT[3],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Радиосеть'),
                      );
                    },
                    body: buildRadioSettings(context),
                    isExpanded: _isOpenRT[4],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Источник питания'),
                      );
                    },
                    body: buildPowerSupply(context),
                    isExpanded: _isOpenRT[5],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Сохранение/Сброс настроек'),
                      );
                    },
                    body: buildDeviceSettings(context),
                    isExpanded: _isOpenRT[6],
                    canTapOnHeader: true,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: chooseDeviceType == global.deviceTypeList[1],
              child: ExpansionPanelList(
                elevation: 2,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isOpenCSD[index] = !isExpanded;
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
                    isExpanded: _isOpenCSD[0],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Координаты'),
                      );
                    },
                    body: buildCoordSettings(context),
                    isExpanded: _isOpenCSD[1],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Подключенные устройства'),
                      );
                    },
                    body: buildConnectedDevicesCSD(context),
                    isExpanded: _isOpenCSD[2],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Внешнее питание'),
                      );
                    },
                    body: buildExtPower(context),
                    isExpanded: _isOpenCSD[3],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Радиосеть'),
                      );
                    },
                    body: buildRadioSettings(context),
                    isExpanded: _isOpenCSD[4],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Источник питания'),
                      );
                    },
                    body: buildPowerSupply(context),
                    isExpanded: _isOpenCSD[5],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Сейсмика'),
                      );
                    },
                    body: buildSeismicSettings(context),
                    isExpanded: _isOpenCSD[6],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Сохранение/Сброс настроек'),
                      );
                    },
                    body: buildDeviceSettings(context),
                    isExpanded: _isOpenCSD[7],
                    canTapOnHeader: true,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: chooseDeviceType == global.deviceTypeList[2],
              child: ExpansionPanelList(
                elevation: 2,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isOpenCFU[index] = !isExpanded;
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
                    isExpanded: _isOpenCFU[0],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Координаты'),
                      );
                    },
                    body: buildCoordSettings(context),
                    isExpanded: _isOpenCFU[1],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Подключенные устройства'),
                      );
                    },
                    body: buildConnectedDevicesCFU(context),
                    isExpanded: _isOpenCFU[2],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Внешнее питание'),
                      );
                    },
                    body: buildExtPower(context),
                    isExpanded: _isOpenCFU[3],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Радиосеть'),
                      );
                    },
                    body: buildRadioSettings(context),
                    isExpanded: _isOpenCFU[4],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Источник питания'),
                      );
                    },
                    body: buildPowerSupply(context),
                    isExpanded: _isOpenCFU[5],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Камера'),
                      );
                    },
                    body: buildCameraSettings(context),
                    isExpanded: _isOpenCFU[6],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Сохранение/Сброс настроек'),
                      );
                    },
                    body: buildDeviceSettings(context),
                    isExpanded: _isOpenCFU[7],
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
