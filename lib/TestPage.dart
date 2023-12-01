import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:projects/Application.dart';
import 'package:projects/BasePackage.dart';
import 'package:projects/NetCommonPackages.dart';
import 'package:projects/NetPackagesDataTypes.dart';
import 'package:flutter/services.dart';
import 'package:projects/NetPhotoPackages.dart';
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
  late _TestPage _page;

  void addDeviceInDropdown(int id, String type, int? posInDropdown) {
    dropdownValue = id.toString();
    var newItem = DropdownMenuItem(
      value: dropdownValue,
      child: Text('$type '
          '#$id'),
    );
    if (posInDropdown == null) {
      dropdownItems.add(newItem);
    } else {
      dropdownItems.insert(posInDropdown, newItem);
    }
  }

  void changeDeviceInDropdown(int newId, String newType, String oldId, int posInDropdown) {
    deleteDeviceInDropdown(int.parse(oldId));
    addDeviceInDropdown(newId, newType, posInDropdown);
  }

  void deleteDeviceInDropdown(int id) {
    for (int i = 0; i < dropdownItems.length; i++) {
      if (dropdownItems[i].value == id.toString()) {
        dropdownItems.removeAt(i);
        if (i == dropdownItems.length && i > 0) {
          dropdownValue = dropdownItems[i - 1].value.toString();
        } else {
          dropdownValue = dropdownItems[i].value.toString();
        }
        break;
      }
    }
  }

  void selectDeviceInDropdown(int id) {
    for (int i = 0; i < dropdownItems.length; i++) {
      if (dropdownItems[i].value == id.toString()) {
        dropdownValue = dropdownItems[i].value.toString();
        _page.setAllNums();
        break;
      }
    }
  }

  @override
  void acknowledgeReceived(int tid, BasePackage basePackage) {
    tits.remove(tid);
    array.add('acknowledgeReceived');
    global.dataComeFlag = true;
  }

  @override
  void dataReceived(int tid, BasePackage basePackage) {
    tits.remove(tid);

    if (basePackage.getType() == PackageType.VERSION) {
      var package = basePackage as VersionPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].firmwareVersion = package.getVersion();
          global.pageWithMap.ActivateMapMarker(package.getSender());
          array.add('dataReceived: ${package.getVersion()}');
        }
      }
    }

    if (basePackage.getType() == PackageType.TIME) {
      var package = basePackage as TimePackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].timeS = package.getTime();
          global.pageWithMap.ActivateMapMarker(package.getSender());
        }
      }
      array.add('dataReceived: ${package.getTime()}');
    }

    if (basePackage.getType() == PackageType.ALL_INFORMATION) {
      var package = basePackage as AllInformationPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].storedLongitude = package.getLongitude();
          global.globalDeviceList[i].storedLatitude = package.getLatitude();
          global.globalDeviceList[i].timeS = package.getTime();
          global.globalDeviceList[i].stateMask = package.getStateMask();
          global.globalDeviceList[i].batMonVoltage = package.getBattery();
          global.globalDeviceList[i].objState = ObjState.Online;

          switch (package.getLastAlarmType()) {
            case AlarmType.SEISMIC:
              global.globalDeviceList[i].objState = ObjState.SeismicAlarm;
              break;
            case AlarmType.TRAP:
              global.globalDeviceList[i].objState = ObjState.PhototrapAlarm;
              break;
            case AlarmType.LINE1:
              global.globalDeviceList[i].objState = ObjState.BreaklineAlarm;
              break;
            case AlarmType.LINE2:
              global.globalDeviceList[i].objState = ObjState.BreaklineAlarm;
              break;
            case AlarmType.RADIATION:
              global.globalDeviceList[i].objState = ObjState.RadiationAlarm;
              break;
            case AlarmType.BATTERY:
              global.globalDeviceList[i].objState = ObjState.LowBatteryAlarm;
              break;
            case AlarmType.NO:
              global.globalDeviceList[i].objState = ObjState.Online;
              break;
            case AlarmType.EXT_POWER_SAFETY_CATCH_OFF:
              global.globalDeviceList[i].objState = ObjState.ExternalPowerSafetyCatchOff;
              break;
            case AlarmType.AUTO_EXT_POWER_TRIGGERED:
              global.globalDeviceList[i].objState = ObjState.AutoExternalPowerTriggered;
          }

          array.add('dataReceived: ${package.getLongitude()}');
          array.add('dataReceived: ${package.getLatitude()}');
          array.add('dataReceived: ${package.getTime()}');
          array.add('dataReceived: ${package.getStateMask()}');
          array.add('dataReceived: ${package.getBattery()}');
          global.pageWithMap.ActivateMapMarker(package.getSender());
        }
      }
    }

    if (basePackage.getType() == PackageType.COORDINATE) {
      var package = basePackage as CoordinatesPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].storedLongitude = package.getLongitude();
          global.globalDeviceList[i].storedLatitude = package.getLatitude();
          global.globalMapMarker[i].markerData.cord = LatLng(package.getLatitude(), package.getLongitude());
        }
      }

      array.add('dataReceived: ${package.getLatitude()}');
      array.add('dataReceived: ${package.getLongitude()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.INFORMATION) {
      var package = basePackage as InformationPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].rssi = package.getRssi();
        }
      }
      array.add('dataReceived: ${package.getRssi()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.ALLOWED_HOPS && !global.retransmissionRequests.contains(tid)) {
      var package = basePackage as HopsPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].allowedHops = package.getHops();
        }
      }
      array.add('dataReceived: ${package.getHops()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
      global.allowedHopsCame = true;
    }

    if (basePackage.getType() == PackageType.ALLOWED_HOPS && global.retransmissionRequests.contains(tid)) {
      global.retransmissionRequests.remove(tid);
      var package = basePackage as HopsPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].allowedHops = package.getHops();
        }
      }
      array.add('dataReceived: ${package.getHops()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.UNALLOWED_HOPS) {
      var package = basePackage as HopsPackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].unallowedHops = package.getHops();
        }
      }
      array.add('dataReceived: ${package.getHops()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
      global.unallowedHopsCame = true;
    }

    if (basePackage.getType() == PackageType.MODEM_FREQUENCY) {
      var package = basePackage as ModemFrequencyPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].modemFrequency = package.getModemFrequency();
          global.pageWithMap.ActivateMapMarker(package.getSender());
        }
      }
      array.add('dataReceived: ${package.getModemFrequency()}');
    }

    if (basePackage.getType() == PackageType.STATE) {
      var package = basePackage as StatePackage;

      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].stateMask = package.getStateMask();
          global.globalDeviceList[i].extDevice1 = ((global.globalDeviceList[i].stateMask & DeviceState.MONITORING_LINE1) != 0);
          global.globalDeviceList[i].extDevice2 = ((global.globalDeviceList[i].stateMask & DeviceState.MONITORING_LINE2) != 0);
          global.globalDeviceList[i].devicePhototrap = ((global.globalDeviceList[i].stateMask & DeviceState.LINES_CAMERA_TRAP) != 0);
          global.globalDeviceList[i].deviceGeophone = ((global.globalDeviceList[i].stateMask & DeviceState.MONITOR_SEISMIC) != 0);
        }
      }

      print('dataReceived: ${package.getStateMask()}');
      array.add('dataReceived: ${package.getStateMask()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.PERIPHERY) {
      var package = basePackage as PeripheryMaskPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].peripheryMask = package.getPeripheryMask();

          global.globalDeviceList[i].deviceExtDev1State = ((global.globalDeviceList[i].peripheryMask & PeripheryMask.LINE1) != 0);
          global.globalDeviceList[i].deviceExtDev2State = ((global.globalDeviceList[i].peripheryMask & PeripheryMask.LINE2) != 0);
          global.globalDeviceList[i].deviceExtPhototrapState = ((global.globalDeviceList[i].peripheryMask & PeripheryMask.CAMERA) != 0);
        }
      }
      array.add('dataReceived: ${package.getPeripheryMask()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.EXTERNAL_POWER) {
      var package = basePackage as ExternalPowerPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].extPower = package.getExternalPowerState();
        }
      }
      array.add('dataReceived: ${package.getExternalPowerState()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.BATTERY_MONITOR) {
      var package = basePackage as BatteryMonitorPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].batMonVoltage = package.getVoltage();
          global.globalDeviceList[i].batMonTemperature = package.getTemperature();
          global.globalDeviceList[i].batMonCurrentMA = package.getCurrent();
          global.globalDeviceList[i].batMonElapsedTime = package.getElapsedTime();
          global.globalDeviceList[i].batMonUsedCapacity = package.getUsedCapacity();
          global.globalDeviceList[i].batMonResidue = package.getResidue();
        }
      }
      array.add('dataReceived: ${package.getTemperature()}');
      array.add('dataReceived: ${package.getVoltage()}');
      array.add('dataReceived: ${package.getCurrent()}');
      array.add('dataReceived: ${package.getElapsedTime()}');
      array.add('dataReceived: ${package.getUsedCapacity()}');
      array.add('dataReceived: ${package.getResidue()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.BATTERY_STATE) {
      var package = basePackage as BatteryStatePackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].weakBatteryFlag = package.getBatteryState() == BatteryState.BAD;
        }
      }
      array.add('dataReceived: ${package.getBatteryState()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.ALARM_REASON_MASK) {
      var package = basePackage as AlarmReasonMaskPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          if (package.getAlarmReasonMask() == 0) {
            global.globalDeviceList[i].humanAlarm = false;
            global.globalDeviceList[i].transportAlarm = false;
          }
          if (package.getAlarmReasonMask() == 8) {
            global.globalDeviceList[i].humanAlarm = true;
            global.globalDeviceList[i].transportAlarm = false;
          }
          if (package.getAlarmReasonMask() == 16) {
            global.globalDeviceList[i].humanAlarm = false;
            global.globalDeviceList[i].transportAlarm = true;
          }
          if (package.getAlarmReasonMask() == 24) {
            global.globalDeviceList[i].humanAlarm = true;
            global.globalDeviceList[i].transportAlarm = true;
          }
        }
      }
      print('dataReceived: ${package.getAlarmReasonMask()}');
      array.add('dataReceived: ${package.getAlarmReasonMask()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.SIGNAL_SWING) {
      var package = basePackage as SeismicSignalSwingPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].signalSwing = package.getSignalSwing();
        }
      }
      print('dataReceived: ${package.getSignalSwing()}');
      array.add('dataReceived: ${package.getSignalSwing()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.HUMAN_SENSITIVITY) {
      var package = basePackage as HumanSensitivityPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].humanSensitivity = package.getHumanSensitivity();
        }
      }
      array.add('dataReceived: ${package.getHumanSensitivity()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.TRANSPORT_SENSITIVITY) {
      var package = basePackage as TransportSensitivityPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].transportSensitivity = package.getTransportSensitivity();
        }
      }
      array.add('dataReceived: ${package.getTransportSensitivity()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.CRITERION_FILTER) {
      var package = basePackage as CriterionFilterPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].criterionFilter = package.getCriterionFilter();
        }
      }
      array.add('dataReceived: ${package.getCriterionFilter()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.SIGNAL_TO_NOISE_RATIO) {
      var package = basePackage as SignalToNoiseRatioPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].snr = package.getSignalToNoiseRatio();
        }
      }
      array.add('dataReceived: ${package.getSignalToNoiseRatio()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.CRITERION_RECOGNITION) {
      var package = basePackage as CriterionRecognitionPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].recognitionParameters = package.getCriteria();
        }
      }
      print(package.getCriteria());
      array.add('dataReceived: ${package.getCriteria()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.PHOTO_PARAMETERS) {
      var package = basePackage as PhotoParametersPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].cameraSensitivity = package.getInvLightSensitivity();
          global.globalDeviceList[i].cameraCompression = package.getCompressRatio();
        }
      }
      array.add('dataReceived: ${package.getInvLightSensitivity()}');
      array.add('dataReceived: ${package.getCompressRatio()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.TRAP_ADDRESS) {
      var package = basePackage as PhototrapPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].targetSensor = package.getCrossDevicesList().first;
        }
      }
      array.add('dataReceived: ${package.getCrossDevicesList()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.EEPROM_FACTORS) {
      var package = basePackage as EEPROMFactorsPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].eepromInitialized = true;
          global.globalDeviceList[i].wake_network_resend_time_ms = package.getWakeNetworkResendTimeMs();
          global.globalDeviceList[i].alarm_resend_time_ms = package.getAlarmResendTimeMs();
          global.globalDeviceList[i].seismic_resend_time_ms = package.getSeismicResendTimeMs();
          global.globalDeviceList[i].photo_resend_time_ms = package.getPhotoResendTimeMs();
          global.globalDeviceList[i].alarm_tries_resend = package.getAlarmTriesResend();
          global.globalDeviceList[i].seismic_tries_resend = package.getSeismicTriesResend();
          global.globalDeviceList[i].photo_tries_resend = package.getPhotoTriesResend();
          global.globalDeviceList[i].periodic_send_telemetry_time_10s = package.getPeriodicSendTelemetryTime10S();
          global.globalDeviceList[i].after_seismic_alarm_pause_s = package.getAfterSeismicAlarmPauseS();
          global.globalDeviceList[i].after_line_alarm_pause_s = package.getAfterLineAlarmPauseS();
          global.globalDeviceList[i].battery_periodic_update_10min = package.getBatteryPeriodicUpdate10Min();
          global.globalDeviceList[i].battery_voltage_threshold_alarm_100mV = package.getBatteryVoltageThresholdAlarm100mV();
          global.globalDeviceList[i].battery_residue_threshold_alarm_pc = package.getBatteryResidueThresholdAlarmPC();
          global.globalDeviceList[i].battery_periodic_alarm_h = package.getBatteryPeriodicAlarmH();
          global.globalDeviceList[i].device_type = package.getDeviceType();

          global.globalDeviceList[i].humanSignalsTreshold = package.getHumanSignalsTreshold();
          global.globalDeviceList[i].humanIntervalsCount = package.getHumanIntervalsCount();
          global.globalDeviceList[i].transportSignalsTreshold = package.getTransportSignalsTreshold();
          global.globalDeviceList[i].transportIntervalsCount = package.getTransportIntervalsCount();
        }
      }
      array.add('dataReceived: ${package.getHumanSignalsTreshold()}');
      array.add('dataReceived: ${package.getHumanIntervalsCount()}');
      array.add('dataReceived: ${package.getTransportSignalsTreshold()}');
      array.add('dataReceived: ${package.getTransportIntervalsCount()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.TRAP_PHOTO_LIST) {
      var package = basePackage as PhototrapFilesPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].phototrapFiles = package.getPhototrapFiles();
        }
      }
      array.add('dataReceived: ${package.getPhototrapFiles()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.SAFETY_CATCH) {
      var package = basePackage as ExternalPowerSafetyCatchPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].extPowerSafetyCatchState = package.getSafetyCatchState();
        }
      }
      array.add('dataReceived: ${package.getSafetyCatchState()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    if (basePackage.getType() == PackageType.AUTO_EXT_POWER) {
      var package = basePackage as AutoExternalPowerPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.globalDeviceList[i].autoExtPowerActivationDelaySec = package.getActivationDelay();
          global.globalDeviceList[i].extPowerImpulseDurationSec = package.getImpulseDuration();
          global.globalDeviceList[i].autoExtPowerState = package.getAutoExternalPowerModeState();
        }
      }
      array.add('dataReceived: ${package.getActivationDelay()}');
      array.add('dataReceived: ${package.getImpulseDuration()}');
      array.add('dataReceived: ${package.getAutoExternalPowerModeState()}');
      global.pageWithMap.ActivateMapMarker(package.getSender());
    }

    global.dataComeFlag = true;
    _page.checkNewIdDevice();
  }

  @override
  void alarmReceived(BasePackage basePackage) {
    if (basePackage.getType() == PackageType.ALARM) {
      var package = basePackage as AlarmPackage;
      for (int i = 0; i < global.globalMapMarker.length; i++) {
        if (global.globalDeviceList[i].id == package.getSender()) {
          global.pageWithMap.AlarmMapMarker(global.globalDeviceList[i].id, package.getAlarmReason());
          array.add('dataReceived: ${package.getAlarmType()}');
          array.add('dataReceived: ${package.getAlarmReason()}');
          global.dataComeFlag = true;
          _page.checkNewIdDevice();
        }
      }
    }
  }

  @override
  void ranOutOfSendAttempts(int tid, BasePackage? pb) {
    tits.remove(tid);
    for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (global.globalDeviceList[i].id == pb!.getReceiver()) {
        if (global.globalMapMarker[i].markerData.notifier.active) {
          global.pageWithMap.DeactivateMapMarker(global.globalDeviceList[i].id);
          array.add('RanOutOfSendAttempts');
          global.dataComeFlag = true;
          _page.checkNewIdDevice();
        }
      }
    }
  }

  @override
  State createState() {
    _page = _TestPage();
    return _page;
  }
}

class _TestPage extends State<TestPage> with AutomaticKeepAliveClientMixin<TestPage> {
  @override
  bool get wantKeepAlive => true;
  bool bufSafety = false, bufAutoExt = false;
  ExternalPower bufExtPower = ExternalPower.OFF;
  int? deviceId, bufSafetyDelay, bufImpulse, bufferCameraSensitivity, bufHumanSens, bufAutoSens, bufSnr, bufRecogniZero, bufRecogniFirst;
  List<String> critFilter = ['1 из 3', '2 из 3', '3 из 3', '2 из 4', '3 из 4', '4 из 4'];

  ScrollController _scrollController = ScrollController();
  List<DropdownMenuItem<String>> dropdownItems = [];
  String stringId = '';
  String? chooseDeviceType, bufferDeviceType;
  String deviceLat = '', deviceLon = '', bufferDeviceLon = '', bufferDeviceLat = '';

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration.zero, (_) {
      setState(() {});
    });
  }

  void setDevId(String string) {
    deviceId = int.parse(string);
  }

  void checkNewIdDevice() {
    setState(() {
      if (global.dataComeFlag) {
        global.list = ListView.builder(
            reverse: true,
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: widget.array.length,
            itemBuilder: (context, i) {
              return Text(
                widget.array[i],
                textScaleFactor: 0.85,
              );
            });
        if (widget.array.length > 3) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
        global.dataComeFlag = false;
      }

      if (global.allowedHopsCame == true) {
        dialogAllowedHopsBuilder();
        global.allowedHopsCame = false;
      }
      if (global.unallowedHopsCame == true) {
        dialogUnallowedHopsBuilder();
        global.unallowedHopsCame = false;
      }
    });
  }

  //Main settings

  void checkDevID(int newId, int oldId, String type) {
    var bufferPos = 0;
    print(newId.toString() + '   ' + oldId.toString());
    setState(() {
      if (newId > 0 && newId < 256 && oldId != newId) {
        for (int i = 0; i < global.globalDeviceList.length; i++) {
          if (global.globalDeviceList[i].id == newId) {
            showError('Такой ИД уже существует');
            break;
          }
          if (global.globalDeviceList[i].id == oldId) {
            bufferPos = i;
          }
          if (i == global.globalDeviceList.length - 1) {
            print(' goooooo  ');
            global.pageWithMap.ChangeMapMarker(oldId, newId, type, type, global.globalDeviceList[bufferPos], bufferPos);
          }
        }
      } else {
        showError("Неверный ИД \n"
            "ИД может быть от 1 до 255");
      }
    });
  }

  void checkDevType(int id, String oldType, String newType) {
    setState(() {
      for (int i = 0; i < global.globalDeviceList.length; i++) {
        if (global.globalDeviceList[i].id == id && global.globalDeviceList[i].type.name == oldType && oldType != newType) {
          if (newType == DeviceType.STD.name && global.globalDeviceList[i].type != DeviceType.STD && global.flagCheckSPPU == true) {
            showError('СППУ уже существует');
            break;
          } else {
            global.pageWithMap.ChangeMapMarker(id, id, oldType, newType, global.globalDeviceList[i], i);
          }
          break;
        }
      }
    });
  }

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

  //Coord settings

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

  //Radio settings

  void TakeSignalStrengthClick(int devId) {
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Разрешенные хопы'),
          content: Text(global.globalDeviceList[global.selectedMapMarkerIndex].allowedHops.toString()),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Запрещенные хопы'),
          content: Text(global.globalDeviceList[global.selectedMapMarkerIndex].unallowedHops.toString()),
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

  // Save/Reset settings
  //TODO Защита от дурня строка 7к в mainwindow.cpp

  void restartDevice(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.REBOOT_SYSTEM);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void saveDeviceParam(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.SAVE_PARAMETERS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void returnDeviceToDefaultParam(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.SET_DEFAULT_PARAMETERS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  // Connected devices

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

  // Internal power

  void TakeSafetyCatch(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_SAFETY_CATCH);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void SetSafetyCatch(int devId, bool safetyCatch) {
    setState(() {
      ExternalPowerSafetyCatchPackage externalPowerSafetyCatchPackage = ExternalPowerSafetyCatchPackage();
      externalPowerSafetyCatchPackage.setReceiver(devId);
      externalPowerSafetyCatchPackage.setSender(RoutesManager.getLaptopAddress());
      externalPowerSafetyCatchPackage.setSafetyCatchState(safetyCatch);
      var tid = global.postManager.sendPackage(externalPowerSafetyCatchPackage);
      widget.tits.add(tid);
    });
  }

  void TakeAutoExtPower(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_AUTO_EXT_POWER);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void SetAutoExtPower(int devId, bool extPower, int delayS, int durationS) {
    setState(() {
      AutoExternalPowerPackage autoExternalPowerPackage = AutoExternalPowerPackage();
      autoExternalPowerPackage.setReceiver(devId);
      autoExternalPowerPackage.setSender(RoutesManager.getLaptopAddress());
      autoExternalPowerPackage.setActivationDelay(delayS);
      autoExternalPowerPackage.setImpulseDuration(durationS);
      autoExternalPowerPackage.setAutoExternalPowerModeState(extPower);
      var tid = global.postManager.sendPackage(autoExternalPowerPackage);
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

  // Power source

  void TakeBatteryMonitorClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_BATTERY_MONITOR);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  //Seismic settings

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

  void TakeTransportSensitivityClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_TRANSPORT_SENSITIVITY);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void SetTransportSensitivityClick(int devId, int sensitivity) {
    setState(() {
      TransportSensitivityPackage transportSensitivityPackage = TransportSensitivityPackage();
      transportSensitivityPackage.setReceiver(devId);
      transportSensitivityPackage.setSender(RoutesManager.getLaptopAddress());
      transportSensitivityPackage.setTransportSensitivity(sensitivity);
      var tid = global.postManager.sendPackage(transportSensitivityPackage);
      widget.tits.add(tid);
    });
  }

  void TakeCriterionFilterClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_CRITERION_FILTER);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void SetCriterionFilterClick(int devId, CriterionFilter filter) {
    setState(() {
      CriterionFilterPackage criterionFilterPackage = CriterionFilterPackage();
      criterionFilterPackage.setReceiver(devId);
      criterionFilterPackage.setSender(RoutesManager.getLaptopAddress());
      criterionFilterPackage.setCriterionFilter(filter);
      var tid = global.postManager.sendPackage(criterionFilterPackage);
      widget.tits.add(tid);
    });
  }

  void TakeSignalToNoiseClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_SIGNAL_TO_NOISE_RATIO);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void SetSignalToNoiseClick(int devId, int snr) {
    setState(() {
      SignalToNoiseRatioPackage signalToNoiseRatioPackage = SignalToNoiseRatioPackage();
      signalToNoiseRatioPackage.setReceiver(devId);
      signalToNoiseRatioPackage.setSender(RoutesManager.getLaptopAddress());
      signalToNoiseRatioPackage.setSignalToNoiseRatio(snr);
      var tid = global.postManager.sendPackage(signalToNoiseRatioPackage);
      widget.tits.add(tid);
    });
  }

  void TakeCriterionRecognitionClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_CRITERION_RECOGNITION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void SetCriterionRecognitionClick(int devId, int index, List<int> value) {
    setState(() {
      CriterionRecognitionPackage criterionRecognitionPackage = CriterionRecognitionPackage();
      criterionRecognitionPackage.setReceiver(devId);
      criterionRecognitionPackage.setSender(RoutesManager.getLaptopAddress());
      for (int i = 0; i < index; i++) {
        criterionRecognitionPackage.setCriterion(i, value[i]);
      }
      var tid = global.postManager.sendPackage(criterionRecognitionPackage);
      widget.tits.add(tid);
    });
  }

  void TakeEEPROMClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_EEPROM_FACTORS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void SetEEPROMClick(int devId, int singleHuman, int singleTransport, int seriesHuman, int seriesTransport) {
    setState(() {
      var device = global.globalDeviceList[global.selectedMapMarkerIndex];
      if (!device.eepromInitialized) {
        return;
      }

      EEPROMFactorsPackage pfp = EEPROMFactorsPackage();
      pfp.setReceiver(devId);
      pfp.setSender(RoutesManager.getLaptopAddress());
      pfp.setWakeNetworkResendTimeMs(device.wake_network_resend_time_ms);
      pfp.setAlarmResendTimeMs(device.alarm_resend_time_ms);
      pfp.setSeismicResendTimeMs(device.seismic_resend_time_ms);
      pfp.setPhotoResendTimeMs(device.photo_resend_time_ms);
      pfp.setAlarmTriesResend(device.alarm_tries_resend);
      pfp.setSeismicTriesResend(device.seismic_tries_resend);
      pfp.setPhotoTriesResend(device.photo_tries_resend);
      pfp.setPeriodicSendTelemetryTime10S(device.periodic_send_telemetry_time_10s);
      pfp.setAfterSeismicAlarmPauseS(device.after_seismic_alarm_pause_s);
      pfp.setAfterLineAlarmPauseS(device.after_line_alarm_pause_s);
      pfp.setBatteryPeriodicUpdate10Min(device.battery_periodic_update_10min);
      pfp.setBatteryVoltageThresholdAlarm100mV(device.battery_voltage_threshold_alarm_100mV);
      pfp.setBatteryResidueThresholdAlarmPC(device.battery_residue_threshold_alarm_pc);
      pfp.setBatteryPeriodicAlarmH(device.battery_periodic_alarm_h);
      pfp.setDeviceType(device.device_type);

      pfp.setHumanSignalsTreshold(singleHuman);
      pfp.setHumanIntervalsCount(seriesHuman);
      pfp.setTransportSignalsTreshold(singleTransport);
      pfp.setTransportIntervalsCount(seriesTransport);
      var tid = global.postManager.sendPackage(pfp);
      widget.tits.add(tid);
    });
  }

  //Camera settings

  void TakePhotoParametersClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_PHOTO_PARAMETERS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void SetPhotoParametersClick(int devId, int invLightSensitivity, PhotoImageCompression compressionRatio) {
    setState(() {
      PhotoParametersPackage photoParametersPackage = PhotoParametersPackage();
      photoParametersPackage.setReceiver(devId);
      photoParametersPackage.setSender(RoutesManager.getLaptopAddress());
      photoParametersPackage.setParameters(invLightSensitivity, compressionRatio);
      var tid = global.postManager.sendPackage(photoParametersPackage);
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

  void checkDevCord() {
    setState(() {
      for (int i = 0; i < global.globalDeviceList.length; i++) {
        if (global.globalDeviceList[i].id == global.pageWithMap.selectedMapMarker) {
          if (global.globalDeviceList[i].latitude.toString().length > 9) {
            deviceLat = global.globalDeviceList[i].latitude.toString().substring(0, 9);
          } else {
            deviceLat = global.globalDeviceList[i].latitude.toString();
          }
          if (global.globalDeviceList[i].longitude.toString().length > 9) {
            deviceLon = global.globalDeviceList[i].longitude.toString().substring(0, 9);
          } else {
            deviceLon = global.globalDeviceList[i].longitude.toString();
          }
          break;
        }
      }
    });
  }

  void setAllNums() {
    setState(() {
      if (global.pageWithMap.selectedMapMarker > 0) {
        for (int i = 0; i < global.globalDeviceList.length; i++) {
          if (global.globalDeviceList[i].id == global.pageWithMap.selectedMapMarker) {
            stringId = global.globalDeviceList[i].id.toString();
            chooseDeviceType = global.globalDeviceList[i].type.name;
            deviceLat = global.globalMapMarker[i].point.latitude.toString().substring(0, 9);
            bufferDeviceLat = deviceLat;
            deviceLon = global.globalMapMarker[i].point.longitude.toString().substring(0, 9);
            bufferDeviceLon = deviceLon;
            bufferDeviceType = global.globalDeviceList[i].type.name;

            bufSafetyDelay = global.delayList[0];
            bufImpulse = global.impulseList[0];
            global.selectedMapMarkerIndex = i;
            bufSafety = global.globalDeviceList[i].extPowerSafetyCatchState;
            bufExtPower = global.globalDeviceList[i].extPower;
            bufAutoExt = global.globalDeviceList[i].autoExtPowerState;
            bufHumanSens = global.globalDeviceList[i].humanSensitivity;
            bufAutoSens = global.globalDeviceList[i].transportSensitivity;
            bufSnr = global.globalDeviceList[i].snr;
            bufRecogniZero = global.globalDeviceList[i].recognitionParameters[0];
            bufRecogniFirst = global.globalDeviceList[i].recognitionParameters[1];
            break;
          }
        }
      }
    });
  }

  Widget buildMainSettings(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text('ИД:'),
              ),
            ),
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
                  onPressed: () => checkDevID(int.parse(stringId), global.globalDeviceList[global.selectedMapMarkerIndex].id,
                      global.globalDeviceList[global.selectedMapMarkerIndex].type.name),
                  icon: const Icon(Icons.check),
                  color: Colors.green,
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
                width: 100,
                child: Text('Тип:'),
              ),
            ),
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
                    bufferDeviceType = value!;
                  },
                  value: bufferDeviceType,
                  icon: const Icon(Icons.keyboard_double_arrow_down),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: SizedBox(
                width: 100,
                child: IconButton(
                  onPressed: () => checkDevType(global.globalDeviceList[global.selectedMapMarkerIndex].id,
                      global.globalDeviceList[global.selectedMapMarkerIndex].type.name, bufferDeviceType!),
                  icon: const Icon(Icons.check),
                  color: Colors.green,
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
                width: 100,
                child: Text('Время дата:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: global.selectedMapMarkerIndex > -1
                    ? Text(global.globalDeviceList[global.selectedMapMarkerIndex].timeS.toString().substring(0, 19),
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
                  children: [
                    IconButton(
                      onPressed: () => TakeTimeClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => SetTimeClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                      icon: const Icon(
                        Icons.access_time,
                        color: Colors.green,
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
                width: 100,
                child: Text('Версия прошивки:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: global.selectedMapMarkerIndex > -1
                    ? Text(global.globalDeviceList[global.selectedMapMarkerIndex].firmwareVersion.toString(), textAlign: TextAlign.center)
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => TakeVersionClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
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

  Widget buildCoordSettings(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text('Широта:'),
              ),
            ),
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
                child: Text('Долгота:'),
              ),
            ),
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
                        TakeCordClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => {
                        SetCoordClick(global.globalDeviceList[global.selectedMapMarkerIndex].id, double.parse(bufferDeviceLat),
                            double.parse(bufferDeviceLon)),
                      },
                      icon: const Icon(
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
            const Flexible(
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
                child: global.selectedMapMarkerIndex > -1
                    ? Text(global.globalDeviceList[global.selectedMapMarkerIndex].rssi.toString(), textAlign: TextAlign.center)
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
                      onPressed: () => TakeSignalStrengthClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
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
                width: 150,
                child: Text('Разрешенные хопы:'),
              ),
            ),
            const Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
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
                      onPressed: () => TakeAllowedHopsClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
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
                width: 150,
                child: Text('Запрещенные хопы:'),
              ),
            ),
            const Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
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
                      onPressed: () => TakeUnallowedHopsClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
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
                width: 150,
                child: Text("Ретранслировать всем:"),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: Checkbox(
                    value:
                        global.selectedMapMarkerIndex > -1 && global.globalDeviceList[global.selectedMapMarkerIndex].allowedHops[0] == 65535
                            ? true
                            : false,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value! == true) {
                          global.globalDeviceList[global.selectedMapMarkerIndex].allowedHops[0] = 65535;
                        } else {
                          global.globalDeviceList[global.selectedMapMarkerIndex].allowedHops[0] = 0;
                        }
                      });
                    }),
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
                      onPressed: () => TakeRetransmissionAllClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => SetRetransmissionAllClick(global.globalDeviceList[global.selectedMapMarkerIndex].id,
                          global.globalDeviceList[global.selectedMapMarkerIndex].allowedHops[0] == 65535),
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
            SizedBox(
              height: 40,
              child: OutlinedButton(
                onPressed: () => ButtonResetRetransmissionClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                child: const Text('Сброс ретрансляции'),
              ),
            ),
          ],
        ),
        const SizedBox(
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
          onPressed: () => {restartDevice(global.globalDeviceList[global.selectedMapMarkerIndex].id)},
          child: const Row(
            children: [
              Icon(Icons.restart_alt),
              Text('Перезагрузить устройство'),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () => {saveDeviceParam(global.globalDeviceList[global.selectedMapMarkerIndex].id)},
          child: const Row(
            children: [
              Icon(Icons.save),
              Text('Сохранить настройки'),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () => {restartDevice(global.globalDeviceList[global.selectedMapMarkerIndex].id)},
          child: const Row(
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
          children: [
            SizedBox(
              width: 300,
              child: Text("Вкл./Выкл. устройств:"),
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
                    value: global.selectedMapMarkerIndex > -1 ? global.globalDeviceList[global.selectedMapMarkerIndex].extDevice1 : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalDeviceList[global.selectedMapMarkerIndex].extDevice1 = value!;
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
                    value: global.selectedMapMarkerIndex > -1 ? global.globalDeviceList[global.selectedMapMarkerIndex].extDevice2 : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalDeviceList[global.selectedMapMarkerIndex].extDevice2 = value!;
                      });
                    }),
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
                      onPressed: () => TakeInternalDeviceParamClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => SetInternalDeviceParamClick(
                          global.globalDeviceList[global.selectedMapMarkerIndex].id,
                          global.globalDeviceList[global.selectedMapMarkerIndex].extDevice1,
                          global.globalDeviceList[global.selectedMapMarkerIndex].extDevice2,
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
          children: [
            SizedBox(
              width: 300,
              child: Text("Состояние устройств:"),
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
            global.selectedMapMarkerIndex > -1
                ? Flexible(
                    flex: 3,
                    child: SizedBox(
                      width: 200,
                      child: Checkbox(
                        value: global.selectedMapMarkerIndex > -1
                            ? global.globalDeviceList[global.selectedMapMarkerIndex].deviceExtDev1State
                            : false,
                        onChanged: null,
                      ),
                    ),
                  )
                : const Flexible(
                    flex: 3,
                    child: SizedBox(
                      width: 200,
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
            global.selectedMapMarkerIndex > -1
                ? Flexible(
                    flex: 3,
                    child: SizedBox(
                      width: 200,
                      child: Checkbox(
                        value: global.selectedMapMarkerIndex > -1
                            ? global.globalDeviceList[global.selectedMapMarkerIndex].deviceExtDev2State
                            : false,
                        onChanged: null,
                      ),
                    ),
                  )
                : const Flexible(
                    flex: 3,
                    child: SizedBox(
                      width: 200,
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
                      onPressed: () => TakeInternalDeviceStateClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
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
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 300,
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
                    value: global.selectedMapMarkerIndex > -1 ? global.globalDeviceList[global.selectedMapMarkerIndex].extDevice1 : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalDeviceList[global.selectedMapMarkerIndex].extDevice1 = value!;
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
                    value: global.selectedMapMarkerIndex > -1 ? global.globalDeviceList[global.selectedMapMarkerIndex].extDevice2 : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalDeviceList[global.selectedMapMarkerIndex].extDevice2 = value!;
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
                        global.selectedMapMarkerIndex > -1 ? global.globalDeviceList[global.selectedMapMarkerIndex].deviceGeophone : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalDeviceList[global.selectedMapMarkerIndex].deviceGeophone = value!;
                      });
                    }),
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
                      onPressed: () => TakeInternalDeviceParamClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => SetInternalDeviceParamClick(
                          global.globalDeviceList[global.selectedMapMarkerIndex].id,
                          global.globalDeviceList[global.selectedMapMarkerIndex].extDevice1,
                          global.globalDeviceList[global.selectedMapMarkerIndex].extDevice2,
                          global.globalDeviceList[global.selectedMapMarkerIndex].deviceGeophone,
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
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 300,
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
            global.selectedMapMarkerIndex > -1
                ? Flexible(
                    flex: 3,
                    child: SizedBox(
                      width: 200,
                      child: Checkbox(
                        value: global.selectedMapMarkerIndex > -1
                            ? global.globalDeviceList[global.selectedMapMarkerIndex].deviceExtDev1State
                            : false,
                        onChanged: null,
                      ),
                    ),
                  )
                : const Flexible(
                    flex: 3,
                    child: SizedBox(
                      width: 200,
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
            global.selectedMapMarkerIndex > -1
                ? Flexible(
                    flex: 3,
                    child: SizedBox(
                      width: 200,
                      child: Checkbox(
                        value: global.selectedMapMarkerIndex > -1
                            ? global.globalDeviceList[global.selectedMapMarkerIndex].deviceExtDev2State
                            : false,
                        onChanged: null,
                      ),
                    ),
                  )
                : const Flexible(
                    flex: 3,
                    child: SizedBox(
                      width: 200,
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
                      onPressed: () => TakeInternalDeviceStateClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
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
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 300,
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
                    value: global.selectedMapMarkerIndex > -1 ? global.globalDeviceList[global.selectedMapMarkerIndex].extDevice1 : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalDeviceList[global.selectedMapMarkerIndex].extDevice1 = value!;
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
                    value: global.selectedMapMarkerIndex > -1 ? global.globalDeviceList[global.selectedMapMarkerIndex].extDevice2 : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalDeviceList[global.selectedMapMarkerIndex].extDevice2 = value!;
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
                child: Text("Обр. лин. фотолов.:"),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: Checkbox(
                    value: global.selectedMapMarkerIndex > -1
                        ? global.globalDeviceList[global.selectedMapMarkerIndex].deviceExtPhototrapState
                        : false,
                    onChanged: (bool? value) {
                      setState(() {
                        global.globalDeviceList[global.selectedMapMarkerIndex].deviceExtPhototrapState = value!;
                      });
                    }),
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
                      onPressed: () => TakeInternalDeviceParamClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => SetInternalDeviceParamClick(
                          global.globalDeviceList[global.selectedMapMarkerIndex].id,
                          global.globalDeviceList[global.selectedMapMarkerIndex].extDevice1,
                          global.globalDeviceList[global.selectedMapMarkerIndex].extDevice2,
                          false,
                          global.globalDeviceList[global.selectedMapMarkerIndex].deviceExtPhototrapState),
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
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 300,
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
            global.selectedMapMarkerIndex > -1
                ? Flexible(
                    flex: 3,
                    child: SizedBox(
                      width: 200,
                      child: Checkbox(
                        value: global.selectedMapMarkerIndex > -1
                            ? global.globalDeviceList[global.selectedMapMarkerIndex].deviceExtDev1State
                            : false,
                        onChanged: null,
                      ),
                    ),
                  )
                : const Flexible(
                    flex: 3,
                    child: SizedBox(
                      width: 200,
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
            global.selectedMapMarkerIndex > -1
                ? Flexible(
                    flex: 3,
                    child: SizedBox(
                      width: 200,
                      child: Checkbox(
                        value: global.selectedMapMarkerIndex > -1
                            ? global.globalDeviceList[global.selectedMapMarkerIndex].deviceExtDev2State
                            : false,
                        onChanged: null,
                      ),
                    ),
                  )
                : const Flexible(
                    flex: 3,
                    child: SizedBox(
                      width: 200,
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
                child: Text("Камера:"),
              ),
            ),
            global.selectedMapMarkerIndex > -1
                ? Flexible(
                    flex: 3,
                    child: SizedBox(
                      width: 200,
                      child: Checkbox(
                        value: global.selectedMapMarkerIndex > -1
                            ? global.globalDeviceList[global.selectedMapMarkerIndex].devicePhototrap
                            : false,
                        onChanged: null,
                      ),
                    ),
                  )
                : const Flexible(
                    flex: 3,
                    child: SizedBox(
                      width: 200,
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
                      onPressed: () => TakeInternalDeviceStateClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
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
                  value: global.selectedMapMarkerIndex > -1 ? bufSafety : false,
                  onChanged: (bool? value) {
                    setState(() {
                      bufSafety = value!;
                    });
                  }),
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
                    onPressed: () => TakeSafetyCatch(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => SetSafetyCatch(global.globalDeviceList[global.selectedMapMarkerIndex].id,
                        global.globalDeviceList[global.selectedMapMarkerIndex].extPowerSafetyCatchState),
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
              width: 100,
              child: Text('Задержка \nактивации:'),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: DropdownButton<int>(
                selectedItemBuilder: (BuildContext context) {
                  return global.delayList.map((int value) {
                    return Align(
                      alignment: Alignment.center,
                      child: Text(
                        '$value сек',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList();
                },
                isExpanded: true,
                items: global.delayList.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value сек'),
                  );
                }).toList(),
                onChanged: global.selectedMapMarkerIndex > -1
                    ? global.globalDeviceList[global.selectedMapMarkerIndex].extPowerSafetyCatchState
                        ? (int? value) {
                            bufSafetyDelay = value!;
                          }
                        : null
                    : null,
                value: bufSafetyDelay,
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
              width: 100,
              child: Text('Длительность \nимпульса:'),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: DropdownButton<int>(
                selectedItemBuilder: (BuildContext context) {
                  return global.impulseList.map((int value) {
                    return Align(
                      alignment: Alignment.center,
                      child: Text(
                        '$value сек',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList();
                },
                isExpanded: true,
                items: global.impulseList.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value сек'),
                  );
                }).toList(),
                onChanged: global.selectedMapMarkerIndex > -1
                    ? global.globalDeviceList[global.selectedMapMarkerIndex].extPowerSafetyCatchState
                        ? (int? value) {
                            bufImpulse = value!;
                          }
                        : null
                    : null,
                value: bufImpulse,
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
              child: Checkbox(
                value:
                    global.selectedMapMarkerIndex > -1 ? global.globalDeviceList[global.selectedMapMarkerIndex].autoExtPowerState : false,
                onChanged: global.selectedMapMarkerIndex > -1
                    ? global.globalDeviceList[global.selectedMapMarkerIndex].extPowerSafetyCatchState
                        ? (bool? value) {
                            setState(() {
                              bufAutoExt = value!;
                            });
                          }
                        : null
                    : null,
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
                    onPressed: () => TakeAutoExtPower(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => SetAutoExtPower(
                        global.globalDeviceList[global.selectedMapMarkerIndex].id, bufAutoExt, bufSafetyDelay!, bufImpulse!),
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
              child: Checkbox(
                  value: global.selectedMapMarkerIndex > -1 ? bufExtPower.index != 0 : false,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == false) {
                        bufExtPower = ExternalPower.OFF;
                      } else {
                        bufExtPower = ExternalPower.ON;
                      }
                    });
                  }),
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
                    onPressed: () => TakeInternalDeviceParamClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => SetInternalDeviceParamClick(
                        global.globalDeviceList[global.selectedMapMarkerIndex].id,
                        global.globalDeviceList[global.selectedMapMarkerIndex].extDevice1,
                        global.globalDeviceList[global.selectedMapMarkerIndex].extDevice2,
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
            const Flexible(
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
                child: global.selectedMapMarkerIndex > -1
                    ? Text(global.globalDeviceList[global.selectedMapMarkerIndex].batMonVoltage.toString(), textAlign: TextAlign.center)
                    : const Text(
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
            const Flexible(
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
                child: global.selectedMapMarkerIndex > -1
                    ? Text(global.globalDeviceList[global.selectedMapMarkerIndex].batMonTemperature.toString(), textAlign: TextAlign.center)
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
                      onPressed: () => TakeBatteryMonitorClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
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
                  value: global.selectedMapMarkerIndex > -1 ? global.globalDeviceList[global.selectedMapMarkerIndex].humanAlarm : false,
                  onChanged: (bool? value) {
                    setState(() {
                      global.globalDeviceList[global.selectedMapMarkerIndex].humanAlarm = value!;
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
                  value: global.selectedMapMarkerIndex > -1 ? global.globalDeviceList[global.selectedMapMarkerIndex].transportAlarm : false,
                  onChanged: (bool? value) {
                    setState(() {
                      global.globalDeviceList[global.selectedMapMarkerIndex].transportAlarm = value!;
                    });
                  }),
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
                    onPressed: () => TakeStateHumanTransportSensitivityClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => SetStateHumanTransportSensitivityClick(
                        global.globalDeviceList[global.selectedMapMarkerIndex].id,
                        global.globalDeviceList[global.selectedMapMarkerIndex].humanAlarm,
                        global.globalDeviceList[global.selectedMapMarkerIndex].transportAlarm),
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
              child: global.selectedMapMarkerIndex > -1
                  ? Text(global.globalDeviceList[global.selectedMapMarkerIndex].signalSwing.toString(), textAlign: TextAlign.center)
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
                    onPressed: () => TakeSignalSwingClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
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
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: TextFormField(
                key: Key(bufHumanSens.toString()),
                textAlign: TextAlign.center,
                initialValue: global.selectedMapMarkerIndex > -1 ? bufHumanSens.toString() : 'null',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String value = newValue.text;
                    bufHumanSens = int.parse(value);
                    if (value.length > 3) {
                      return TextEditingValue(
                        text: oldValue.text,
                        selection: TextSelection.collapsed(offset: oldValue.selection.end),
                      );
                    }
                    return TextEditingValue(
                      text: bufHumanSens.toString(),
                      selection: TextSelection.collapsed(offset: bufHumanSens.toString().length),
                    );
                  }),
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
                    onPressed: () => TakeHumanSensitivityClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => bufHumanSens! > 24 && bufHumanSens! < 256
                        ? SetHumanSensitivityClick(global.globalDeviceList[global.selectedMapMarkerIndex].id, bufHumanSens!)
                        : {
                            showError('Чувствительность от 25 до 255'),
                            global.globalDeviceList[global.selectedMapMarkerIndex].humanSensitivity = 25,
                            bufHumanSens = 25,
                          },
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
              width: 140,
              child: Text('Чувствительность \nпо транспорту:\n(25-255)'),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: TextFormField(
                textAlign: TextAlign.center,
                key: Key(bufAutoSens.toString()),
                initialValue: global.selectedMapMarkerIndex > -1 ? bufAutoSens.toString() : 'null',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String value = newValue.text;
                    bufAutoSens = int.parse(value);
                    if (value.length > 3) {
                      return TextEditingValue(
                        text: oldValue.text,
                        selection: TextSelection.collapsed(offset: oldValue.selection.end),
                      );
                    }
                    return TextEditingValue(
                      text: bufAutoSens.toString(),
                      selection: TextSelection.collapsed(offset: bufAutoSens.toString().length),
                    );
                  }),
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
                    onPressed: () => TakeTransportSensitivityClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => bufAutoSens! > 24 && bufAutoSens! < 256
                        ? SetTransportSensitivityClick(global.globalDeviceList[global.selectedMapMarkerIndex].id, bufAutoSens!)
                        : showError('Чувствительность от 25 до 255'),
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
              width: 100,
              child: Text('Критерийный \nфильтр:'),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: DropdownButton<CriterionFilter>(
                isExpanded: true,
                items: CriterionFilter.values.map<DropdownMenuItem<CriterionFilter>>((CriterionFilter value) {
                  return DropdownMenuItem<CriterionFilter>(
                    value: value,
                    child: Text(critFilter[value.index]),
                  );
                }).toList(),
                onChanged: global.selectedMapMarkerIndex > -1
                    ? (CriterionFilter? value) {
                        global.globalDeviceList[global.selectedMapMarkerIndex].criterionFilter = value!;
                      }
                    : null,
                value: global.selectedMapMarkerIndex > -1 ? global.globalDeviceList[global.selectedMapMarkerIndex].criterionFilter : null,
                icon: const Icon(Icons.keyboard_double_arrow_down),
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
                    onPressed: () => TakeCriterionFilterClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => SetCriterionFilterClick(global.globalDeviceList[global.selectedMapMarkerIndex].id,
                        global.globalDeviceList[global.selectedMapMarkerIndex].criterionFilter),
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
              width: 140,
              child: Text('Отношение сигнал \nтранспорта/шум:\n(5-40)'),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: TextFormField(
                textAlign: TextAlign.center,
                key: Key(bufSnr.toString()),
                initialValue: global.selectedMapMarkerIndex > -1 ? bufSnr.toString() : 'null',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String value = newValue.text;
                    bufSnr = int.parse(value);
                    if (value.length > 2) {
                      return TextEditingValue(
                        text: oldValue.text,
                        selection: TextSelection.collapsed(offset: oldValue.selection.end),
                      );
                    }
                    return TextEditingValue(
                      text: bufSnr.toString(),
                      selection: TextSelection.collapsed(offset: bufSnr.toString().length),
                    );
                  }),
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
                    onPressed: () => TakeSignalToNoiseClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => bufSnr! > 4 && bufSnr! < 41
                        ? SetSignalToNoiseClick(global.globalDeviceList[global.selectedMapMarkerIndex].id, bufSnr!)
                        : showError('Отношение от 5 до 40'),
                    icon: const Icon(Icons.check),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text('Параметры распознавания:'),
      ]),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Text("Помеха/Человек"),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: TextFormField(
                textAlign: TextAlign.center,
                key: Key(bufRecogniZero.toString()),
                initialValue: global.selectedMapMarkerIndex > -1 ? bufRecogniZero.toString() : 'null',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String value = newValue.text;
                    bufRecogniZero = int.parse(value);
                    if (value.length > 3) {
                      return TextEditingValue(
                        text: oldValue.text,
                        selection: TextSelection.collapsed(offset: oldValue.selection.end),
                      );
                    }
                    return TextEditingValue(
                      text: bufRecogniZero.toString(),
                      selection: TextSelection.collapsed(offset: bufRecogniZero.toString().length),
                    );
                  })
                ],
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
              width: 140,
              child: Text('Человек/Транспорт'),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: TextFormField(
                textAlign: TextAlign.center,
                key: Key(bufRecogniFirst.toString()),
                initialValue: global.selectedMapMarkerIndex > -1 ? bufRecogniFirst.toString() : 'null',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String value = newValue.text;
                    bufRecogniFirst = int.parse(value);
                    if (value.length > 3) {
                      return TextEditingValue(
                        text: oldValue.text,
                        selection: TextSelection.collapsed(offset: oldValue.selection.end),
                      );
                    }
                    return TextEditingValue(
                      text: bufRecogniFirst.toString(),
                      selection: TextSelection.collapsed(offset: bufRecogniFirst.toString().length),
                    );
                  }),
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
                    onPressed: () => TakeCriterionRecognitionClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => bufRecogniZero! > -1 && bufRecogniZero! < 256 && bufRecogniFirst! > -1 && bufRecogniFirst! < 256
                        ? {
                            global.globalDeviceList[global.selectedMapMarkerIndex].recognitionParameters[0] = bufRecogniZero!,
                            global.globalDeviceList[global.selectedMapMarkerIndex].recognitionParameters[1] = bufRecogniFirst!,
                            SetCriterionRecognitionClick(
                                global.globalDeviceList[global.selectedMapMarkerIndex].id,
                                global.globalDeviceList[global.selectedMapMarkerIndex].recognitionParameters.length,
                                global.globalDeviceList[global.selectedMapMarkerIndex].recognitionParameters)
                          }
                        : showError('Параметры от 0 до 255'),
                    icon: const Icon(Icons.check),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text('Фильтрация тревог:'),
      ]),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Text("Одиночные(человек):"),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: global.selectedMapMarkerIndex > -1
                  ? TextFormField(
                      textAlign: TextAlign.center,
                      key: Key(global.globalDeviceList[global.selectedMapMarkerIndex].humanSignalsTreshold.toString()),
                      initialValue: global.globalDeviceList[global.selectedMapMarkerIndex].humanSignalsTreshold.toString(),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          String value = newValue.text;
                          global.globalDeviceList[global.selectedMapMarkerIndex].humanSignalsTreshold = int.parse(value);
                          if (value.length > 3) {
                            return TextEditingValue(
                              text: oldValue.text,
                              selection: TextSelection.collapsed(offset: oldValue.selection.end),
                            );
                          }
                          return TextEditingValue(
                            text: global.globalDeviceList[global.selectedMapMarkerIndex].humanSignalsTreshold.toString(),
                            selection: TextSelection.collapsed(
                                offset: global.globalDeviceList[global.selectedMapMarkerIndex].humanSignalsTreshold.toString().length),
                          );
                        })
                      ],
                    )
                  : const Text('null'),
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
              child: Text("Серийные(человек):"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: global.selectedMapMarkerIndex > -1
                  ? DropdownButton<int>(
                      selectedItemBuilder: (BuildContext context) {
                        return global.serialHuman.map((int value) {
                          return Align(
                            alignment: Alignment.center,
                            child: Text(
                              '$value за ' + value.toString() + '0 секунд ',
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList();
                      },
                      isExpanded: true,
                      items: global.serialHuman.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value за ' + value.toString() + '0 секунд '),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        global.globalDeviceList[global.selectedMapMarkerIndex].seriesHumanFilterTreshold = value!;
                      },
                      value: global.globalDeviceList[global.selectedMapMarkerIndex].seriesHumanFilterTreshold,
                      icon: const Icon(Icons.keyboard_double_arrow_down),
                    )
                  : const Text('null'),
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
              child: Text("Одиночные(транспорт):"),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: global.selectedMapMarkerIndex > -1
                  ? TextFormField(
                      textAlign: TextAlign.center,
                      key: Key(global.globalDeviceList[global.selectedMapMarkerIndex].transportSignalsTreshold.toString()),
                      initialValue: global.globalDeviceList[global.selectedMapMarkerIndex].transportSignalsTreshold.toString(),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          String value = newValue.text;
                          global.globalDeviceList[global.selectedMapMarkerIndex].transportSignalsTreshold = int.parse(value);
                          if (value.length > 3) {
                            return TextEditingValue(
                              text: oldValue.text,
                              selection: TextSelection.collapsed(offset: oldValue.selection.end),
                            );
                          }
                          return TextEditingValue(
                            text: global.globalDeviceList[global.selectedMapMarkerIndex].transportSignalsTreshold.toString(),
                            selection: TextSelection.collapsed(
                                offset: global.globalDeviceList[global.selectedMapMarkerIndex].transportSignalsTreshold.toString().length),
                          );
                        })
                      ],
                    )
                  : const Text('null'),
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
              child: Text("Серийные(транспорт):"),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: global.selectedMapMarkerIndex > -1
                  ? DropdownButton<int>(
                      selectedItemBuilder: (BuildContext context) {
                        return global.serialTransport.map((int value) {
                          return Align(
                            alignment: Alignment.center,
                            child: Text(
                              '$value за ' + value.toString() + '0 секунд ',
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList();
                      },
                      isExpanded: true,
                      items: global.serialTransport.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value за ' + value.toString() + '0 секунд '),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        global.globalDeviceList[global.selectedMapMarkerIndex].seriesTransportFilterTreshold = value!;
                      },
                      value: global.globalDeviceList[global.selectedMapMarkerIndex].seriesTransportFilterTreshold,
                      icon: const Icon(Icons.keyboard_double_arrow_down),
                    )
                  : const Text('null'),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => TakeEEPROMClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => global.globalDeviceList[global.selectedMapMarkerIndex].humanSignalsTreshold > -1 &&
                            global.globalDeviceList[global.selectedMapMarkerIndex].humanSignalsTreshold < 256 &&
                            global.globalDeviceList[global.selectedMapMarkerIndex].transportSignalsTreshold > -1 &&
                            global.globalDeviceList[global.selectedMapMarkerIndex].transportSignalsTreshold < 256
                        ? {
                            global.globalDeviceList[global.selectedMapMarkerIndex].eepromInitialized
                                ? SetEEPROMClick(
                                    global.globalDeviceList[global.selectedMapMarkerIndex].id,
                                    global.globalDeviceList[global.selectedMapMarkerIndex].humanSignalsTreshold,
                                    global.globalDeviceList[global.selectedMapMarkerIndex].transportSignalsTreshold,
                                    global.globalDeviceList[global.selectedMapMarkerIndex].seriesHumanFilterTreshold,
                                    global.globalDeviceList[global.selectedMapMarkerIndex].seriesTransportFilterTreshold)
                                : showError('Сначала запросите данные'),
                          }
                        : showError('Параметры от 0 до 255'),
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
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text('Чувствительность:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  initialValue: global.selectedMapMarkerIndex > -1
                      ? global.globalDeviceList[global.selectedMapMarkerIndex].cameraSensitivity.toString()
                      : 'null',
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      String value = newValue.text;
                      global.globalDeviceList[global.selectedMapMarkerIndex].cameraSensitivity = int.parse(value);
                      if (value.length > 3) {
                        return TextEditingValue(
                          text: oldValue.text,
                          selection: TextSelection.collapsed(offset: oldValue.selection.end),
                        );
                      }
                      return TextEditingValue(
                        text: global.globalDeviceList[global.selectedMapMarkerIndex].cameraSensitivity.toString(),
                        selection: TextSelection.collapsed(
                            offset: global.globalDeviceList[global.selectedMapMarkerIndex].cameraSensitivity.toString().length),
                      );
                    }),
                  ],
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
                child: Text('Сжатие фотографий:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: DropdownButton<PhotoImageCompression>(
                  isExpanded: true,
                  items: PhotoImageCompression.values.map<DropdownMenuItem<PhotoImageCompression>>((PhotoImageCompression value) {
                    return DropdownMenuItem<PhotoImageCompression>(
                      value: value,
                      child: Text(value.name),
                    );
                  }).toList(),
                  onChanged: global.selectedMapMarkerIndex > -1
                      ? (PhotoImageCompression? value) {
                          global.globalDeviceList[global.selectedMapMarkerIndex].cameraCompression = value!;
                        }
                      : null,
                  value:
                      global.selectedMapMarkerIndex > -1 ? global.globalDeviceList[global.selectedMapMarkerIndex].cameraCompression : null,
                  icon: const Icon(Icons.keyboard_double_arrow_down),
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
                      onPressed: () => TakePhotoParametersClick(global.globalDeviceList[global.selectedMapMarkerIndex].id),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => global.globalDeviceList[global.selectedMapMarkerIndex].cameraSensitivity > -1 &&
                              global.globalDeviceList[global.selectedMapMarkerIndex].cameraSensitivity < 256
                          ? SetPhotoParametersClick(
                              global.globalDeviceList[global.selectedMapMarkerIndex].id,
                              global.globalDeviceList[global.selectedMapMarkerIndex].cameraSensitivity,
                              global.globalDeviceList[global.selectedMapMarkerIndex].cameraCompression)
                          : {
                              showError('Чувствительность от 0 до 255'),
                              global.globalDeviceList[global.selectedMapMarkerIndex].cameraSensitivity = 25
                            },
                      icon: const Icon(Icons.check),
                      color: Colors.green,
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
                  if (global.globalDeviceList[i].id == deviceId) {
                    global.selectedMapMarkerIndex = i;
                    global.pageWithMap.SelectedMapMarker(global.globalDeviceList[i].id);
                    global.mainBottomSelectedDev = Text(
                      '${global.globalDeviceList[i].type.name} #${global.globalDeviceList[i].id}',
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
                      return const ListTile(
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
