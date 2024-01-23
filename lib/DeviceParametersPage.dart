import 'dart:async';

import 'package:flutter/material.dart';
import 'package:projects/Application.dart';
import 'package:projects/BasePackage.dart';
import 'package:projects/NetCommonPackages.dart';
import 'package:projects/NetPackagesDataTypes.dart';
import 'package:flutter/services.dart';
import 'package:projects/NetPhotoPackages.dart';
import 'package:projects/NetSeismicPackage.dart';
import 'package:projects/core/NetDevice.dart';

import 'AllEnum.dart';
import 'NetNetworkPackages.dart';
import 'PageWithMap.dart';
import 'RoutesManager.dart';
import 'core/CPD.dart';
import 'core/CSD.dart';
import 'core/MCD.dart';
import 'core/Marker.dart';
import 'core/RT.dart';
import 'global.dart' as global;

class DeviceParametersPage extends StatefulWidget with TIDManagement {
  List<String> array = [];
  List<DropdownMenuItem<String>> dropdownItems = [];
  String dropdownValue = '';
  late _DeviceParametersPage _page;

  Marker _cloneItem = Marker();
  Map<int, BasePackage> setRequests = {};

  void addDeviceInDropdown(int id, String type) {
    dropdownValue = id.toString();
    var newItem = DropdownMenuItem(
      value: dropdownValue,
      child: Text('$type '
          '#$id'),
    );
    dropdownItems.add(newItem);
  }

  void stdConnected(int stdId) {
    Timer(Duration(seconds: 4), () {

      if (global.listMapMarkers.isEmpty && global.pageWithMap.coord() != null){
        global.pageWithMap.createFirstSTDAutomatically(int.parse(global.STDNum), global.pageWithMap.coord()!.latitude, global.pageWithMap.coord()!.longitude);
      }
      var req = BasePackage.makeBaseRequest(stdId, PackageType.GET_MODEM_FREQUENCY);
      var tid = global.postManager.sendPackage(req);
      tits.add(tid);

      var tp = TimePackage();
      tp.setTime(DateTime.now());
      tp.setReceiver(stdId);
      tp.setSender(RoutesManager.getLaptopAddress());

      tid = global.postManager.sendPackage(tp);
      setRequests[tid] = tp;
      tits.add(tid);

      req = BasePackage.makeBaseRequest(stdId, PackageType.GET_ALLOWED_HOPS);
      tid = global.postManager.sendPackage(req);
      tits.add(tid);
      global.stdHopsCheckRequests.add(tid);

      print('std init');

    });


    // TODO PollMan.startPollRoutines();
  }

  void changeDeviceInDropdown(int newId, String newType, String oldId) {
    addDeviceInDropdown(newId, newType);
    deleteDeviceInDropdown(int.parse(oldId));
    selectDeviceInDropdown(newId);
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
    var sender = basePackage.getSender();
    var nd = global.itemsMan.get<NetDevice>(sender);

    if (nd == null) return;

    if (!global.listMapMarkers.containsKey(sender)) return;

    if (!setRequests.containsKey(tid)) return;

    if (setRequests[tid] is TimePackage) {
      var package = setRequests[tid] as TimePackage;
      nd.time = package.getTime();
    }
    if (setRequests[tid] is CoordinatesPackage) {
      var package = setRequests[tid] as CoordinatesPackage;
      nd.setStoredCoordinates(package.getLatitude(), package.getLongitude());
      nd.setCoordinates(package.getLatitude(), package.getLongitude());
    }
    if (setRequests[tid] is StatePackage && nd is RT) {
      var package = setRequests[tid] as StatePackage;
      nd.stateMask = package.getStateMask();
    }
    if (setRequests[tid] is ExternalPowerSafetyCatchPackage && nd is RT) {
      var package = setRequests[tid] as ExternalPowerSafetyCatchPackage;
      nd.extPowerSafetyCatchState = package.getSafetyCatchState();
    }
    if (setRequests[tid] is AutoExternalPowerPackage && nd is RT) {
      var package = setRequests[tid] as AutoExternalPowerPackage;
      nd.autoExtPowerActivationDelaySec = package.getActivationDelay();
      nd.extPowerImpulseDurationSec = package.getImpulseDuration();
      nd.autoExtPowerState = package.getAutoExternalPowerModeState();
    }
    if (setRequests[tid] is ExternalPowerPackage) {
      var package = setRequests[tid] as ExternalPowerPackage;
      if (nd is RT){
        nd.extPower = package.getExternalPowerState();
      }else if (nd is MCD){
        nd.GPSState = package.getExternalPowerState() == ExternalPower.ON;
      }
    }
    if (setRequests[tid] is AlarmReasonMaskPackage && nd is CSD) {
      var package = setRequests[tid] as AlarmReasonMaskPackage;
      nd.alarmReasonMask = package.getAlarmReasonMask();
    }
    if (setRequests[tid] is HumanSensitivityPackage && nd is CSD) {
      var package = setRequests[tid] as HumanSensitivityPackage;
      nd.humanSensitivity = package.getHumanSensitivity();
    }
    if (setRequests[tid] is TransportSensitivityPackage && nd is CSD) {
      var package = setRequests[tid] as TransportSensitivityPackage;
      nd.transportSensitivity = package.getTransportSensitivity();
    }
    if (setRequests[tid] is CriterionFilterPackage && nd is CSD) {
      var package = setRequests[tid] as CriterionFilterPackage;
      nd.criterionFilter = package.getCriterionFilter();
    }
    if (setRequests[tid] is SignalToNoiseRatioPackage && nd is CSD) {
      var package = setRequests[tid] as SignalToNoiseRatioPackage;
      nd.snr = package.getSignalToNoiseRatio();
    }
    if (setRequests[tid] is CriterionRecognitionPackage && nd is CSD) {
      var package = setRequests[tid] as CriterionRecognitionPackage;
      nd.recognitionParameters = package.getCriteria();
    }
    if (setRequests[tid] is EEPROMFactorsPackage && nd is RT) {
      var package = setRequests[tid] as EEPROMFactorsPackage;
      nd.wakeNetworkResendTimeMs = package.getWakeNetworkResendTimeMs();
      nd.alarmResendTimeMs = package.getAlarmResendTimeMs();
      nd.seismicResendTimeMs = package.getSeismicResendTimeMs();
      nd.photoResendTimeMs = package.getPhotoResendTimeMs();
      nd.alarmTriesResend = package.getAlarmTriesResend();
      nd.seismicTriesResend = package.getSeismicTriesResend();
      nd.photoTriesResend = package.getPhotoTriesResend();
      nd.periodicSendTelemetryTime10s = package.getPeriodicSendTelemetryTime10S();
      nd.afterSeismicAlarmPauseS = package.getAfterSeismicAlarmPauseS();
      nd.afterLineAlarmPauseS = package.getAfterLineAlarmPauseS();
      nd.batteryPeriodicUpdate10min = package.getBatteryPeriodicUpdate10Min();
      nd.batteryVoltageThresholdAlarm100mV = package.getBatteryVoltageThresholdAlarm100mV();
      nd.batteryResidueThresholdAlarmPC = package.getBatteryResidueThresholdAlarmPC();
      nd.batteryPeriodicAlarmH = package.getBatteryPeriodicAlarmH();
      nd.deviceType = package.getDeviceType();

      nd.humanSignalsTreshold = package.getHumanSignalsTreshold();
      nd.humanIntervalsCount = package.getHumanIntervalsCount();
      nd.transportSignalsTreshold = package.getTransportSignalsTreshold();
      nd.transportIntervalsCount = package.getTransportIntervalsCount();
    }
    if (setRequests[tid] is PhotoParametersPackage && nd is CPD) {
      var package = setRequests[tid] as PhotoParametersPackage;
      nd.setCameraParameters(package.getInvLightSensitivity(), package.getCompressRatio());
    }

    setRequests.remove(tid);
    print(basePackage.getType());
    global.pageWithMap.activateMapMarker(sender);
    array.add('acknowledgeReceived');
    global.dataComeFlag = true;

    _page.setAllNums();
  }

  @override
  void dataReceived(int tid, BasePackage basePackage) {
    tits.remove(tid);
    var type = basePackage.getType();
    var sender = basePackage.getSender();
    var nd = global.itemsMan.get<NetDevice>(sender);

    if (nd == null) return;

    print('dataReceived');

    if (type == PackageType.VERSION) {
      var package = basePackage as VersionPackage;
      nd.firmwareVersion = package.getVersion();
      global.pageWithMap.activateMapMarker(sender);
      array.add('dataReceived: ${package.getVersion()}');
    }

    if (type == PackageType.TIME) {
      var package = basePackage as TimePackage;
      nd.time = package.getTime();
      global.pageWithMap.activateMapMarker(sender);
      array.add('dataReceived: ${package.getTime()}');
    }

    if (type == PackageType.ALL_INFORMATION) {
      var package = basePackage as AllInformationPackage;
      if (nd is RT) {
        nd.setStoredCoordinates(package.getLatitude(), package.getLongitude());
        nd.setCoordinates(nd.storedLatitude, nd.storedLongitude);
        nd.time = package.getTime();
        nd.stateMask = package.getStateMask();
        nd.batMonVoltage = package.getBattery();
        nd.state = NDState.Online;
        switch (package.getLastAlarmType()) {
          case AlarmType.SEISMIC:
            nd.state = NDState.SeismicAlarm;
            break;
          case AlarmType.TRAP:
            nd.state = NDState.PhototrapAlarm;
            break;
          case AlarmType.LINE1:
            nd.state = NDState.BreaklineAlarm;
            break;
          case AlarmType.LINE2:
            nd.state = NDState.BreaklineAlarm;
            break;
          case AlarmType.RADIATION:
            nd.state = NDState.RadiationAlarm;
            break;
          case AlarmType.BATTERY:
            nd.state = NDState.LowBatteryAlarm;
            break;
          case AlarmType.NO:
            nd.state = NDState.Online;
            break;
          case AlarmType.EXT_POWER_SAFETY_CATCH_OFF:
            nd.state = NDState.ExternalPowerSafetyCatchOff;
            break;
          case AlarmType.AUTO_EXT_POWER_TRIGGERED:
            nd.state = NDState.AutoExternalPowerTriggered;
        }

        global.pageWithMap.activateMapMarker(sender);
        array.add('dataReceived: ${package.getLongitude()}');
        array.add('dataReceived: ${package.getLatitude()}');
        array.add('dataReceived: ${package.getTime()}');
        array.add('dataReceived: ${package.getStateMask()}');
        array.add('dataReceived: ${package.getBattery()}');
      }
    }

    if (type == PackageType.COORDINATE) {
      var package = basePackage as CoordinatesPackage;
      nd.setStoredCoordinates(package.getLatitude(), package.getLongitude());
      nd.setCoordinates(nd.storedLatitude, nd.storedLongitude);
      global.listMapMarkers[sender]?.point.latitude = nd.latitude;
      global.listMapMarkers[sender]?.point.longitude = nd.longitude;

      array.add('dataReceived: ${nd.latitude}');
      array.add('dataReceived: ${nd.longitude}');
      global.pageWithMap.activateMapMarker(sender);
    }

    if (type == PackageType.INFORMATION) {
      var package = basePackage as InformationPackage;
      if (nd is RT) {
        nd.RSSI = package.getRssi();

        array.add('dataReceived: ${package.getRssi()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.ALLOWED_HOPS) {
      var package = basePackage as HopsPackage;
      if (nd is RT) {
        nd.allowedHops = package.getHops();
        var rtMode = RoutesManager.getRtMode(nd.allowedHops);
        global.allowedHopsCame = true;

        print('enter');
        if (global.stdHopsCheckRequests.contains(tid)) {
          global.stdHopsCheckRequests.remove(tid);
          global.allowedHopsCame = false;

          if (rtMode == RtMode.NoOne) {
            var hp = HopsPackage();
            print('switch On rtMode');
            hp.setType(PackageType.SET_ALLOWED_HOPS);
            hp.setSender(RoutesManager.getLaptopAddress());
            hp.setReceiver(package.getPartner());

            hp.addHop(RoutesManager.getRtAllHop());
            hp.fillZeroHops();

            global.postManager.sendPackage(hp);
          }
        } else if (global.retransmissionRequests.contains(tid)) {
          global.retransmissionRequests.remove(tid);
          array.add('dataReceived: ${package.getHops()}');
          global.pageWithMap.activateMapMarker(sender);
        }
      } else if (nd is MCD) {
        var rtMode = RoutesManager.getRtMode(package.getHops());
        nd.priority = rtMode == RtMode.ToAll;
      }
    }

    if (type == PackageType.UNALLOWED_HOPS) {
      if (nd is RT) {
        var package = basePackage as HopsPackage;
        nd.unallowedHops = package.getHops();

        array.add('dataReceived: ${package.getHops()}');
        global.pageWithMap.activateMapMarker(sender);
        global.unallowedHopsCame = true;
      }
    }

    if (type == PackageType.MODEM_FREQUENCY) {
      var package = basePackage as ModemFrequencyPackage;
      nd.modemFrequency = package.getModemFrequency();
      global.pageWithMap.activateMapMarker(sender);
      array.add('dataReceived: ${package.getModemFrequency()}');
    }

    if (type == PackageType.STATE) {
      var package = basePackage as StatePackage;
      if (nd is RT) {
        nd.stateMask = package.getStateMask();
        array.add('dataReceived: ${package.getStateMask()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.PERIPHERY) {
      var package = basePackage as PeripheryMaskPackage;
      if (nd is RT) {
        nd.peripheryMask = package.getPeripheryMask();

        array.add('dataReceived: ${package.getPeripheryMask()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.EXTERNAL_POWER) {
      var package = basePackage as ExternalPowerPackage;
      if (nd is RT) {
        nd.extPower = package.getExternalPowerState();
      } else if (nd is MCD) {
        nd.GPSState = package.getExternalPowerState() == ExternalPower.ON;
      }
      array.add('dataReceived: ${package.getExternalPowerState()}');
      global.pageWithMap.activateMapMarker(sender);
    }

    if (type == PackageType.BATTERY_MONITOR) {
      var package = basePackage as BatteryMonitorPackage;
      if (nd is RT) {
        nd.setBatMonParameters(package.getResidue(), package.getUsedCapacity(), package.getVoltage(), package.getCurrent(),
            package.getTemperature(), package.getElapsedTime());
      } else if (nd is MCD) {
        nd.setBatMonParameters(package.getVoltage(), package.getTemperature());
      }

      array.add('dataReceived: ${package.getTemperature()}');
      array.add('dataReceived: ${package.getVoltage()}');
      array.add('dataReceived: ${package.getCurrent()}');
      array.add('dataReceived: ${package.getElapsedTime()}');
      array.add('dataReceived: ${package.getUsedCapacity()}');
      array.add('dataReceived: ${package.getResidue()}');
      global.pageWithMap.activateMapMarker(sender);
    }

    // TODO: add Battery state
    if (type == PackageType.BATTERY_STATE) {
      var package = basePackage as BatteryStatePackage;
      if (nd is RT) {
        var isWeakBattery = package.getBatteryState() == BatteryState.BAD;

        if (isWeakBattery && !nd.weakBattery) {
          //AlarmWeaBattery(nd.id());
        } else if (!isWeakBattery && nd.weakBattery) {
          //DeviceSettingsEvent(nd.id(), BatteryChanged);
        }
        nd.weakBattery = isWeakBattery;
        //deviceBatteryStateChanged(rt.id(), isWeakBattery);

        array.add('dataReceived: ${package.getBatteryState()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.ALARM_REASON_MASK) {
      var package = basePackage as AlarmReasonMaskPackage;
      if (nd is CSD) {
        nd.alarmReasonMask = package.getAlarmReasonMask();
        array.add('dataReceived: ${package.getAlarmReasonMask()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.SIGNAL_SWING) {
      var package = basePackage as SeismicSignalSwingPackage;
      if (nd is CSD) {
        nd.signalSwing = package.getSignalSwing();

        array.add('dataReceived: ${package.getSignalSwing()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.HUMAN_SENSITIVITY) {
      var package = basePackage as HumanSensitivityPackage;
      if (nd is CSD) {
        nd.humanSensitivity = package.getHumanSensitivity();

        array.add('dataReceived: ${package.getHumanSensitivity()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.HUMAN_FREQ_THRESHOLD) {
      var package = basePackage as HumanFreqThresholdPackage;
      if (nd is CSD) {
        nd.humanFreqThreshold = package.getHumanFreqThresholdPackage();

        array.add('dataReceived: ${package.getHumanFreqThresholdPackage()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.TRANSPORT_SENSITIVITY) {
      var package = basePackage as TransportSensitivityPackage;
      if (nd is CSD) {
        nd.transportSensitivity = package.getTransportSensitivity();

        array.add('dataReceived: ${package.getTransportSensitivity()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.CRITERION_FILTER) {
      var package = basePackage as CriterionFilterPackage;
      if (nd is CSD) {
        nd.criterionFilter = package.getCriterionFilter();

        array.add('dataReceived: ${package.getCriterionFilter()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.SIGNAL_TO_NOISE_RATIO) {
      var package = basePackage as SignalToNoiseRatioPackage;
      if (nd is CSD) {
        nd.snr = package.getSignalToNoiseRatio();

        array.add('dataReceived: ${package.getSignalToNoiseRatio()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.CRITERION_RECOGNITION) {
      var package = basePackage as CriterionRecognitionPackage;
      if (nd is CSD) {
        nd.recognitionParameters = package.getCriteria();

        array.add('dataReceived: ${package.getCriteria()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.PHOTO_PARAMETERS) {
      var package = basePackage as PhotoParametersPackage;
      if (nd is CPD) {
        nd.setCameraParameters(package.getInvLightSensitivity(), package.getCompressRatio());

        array.add('dataReceived: ${package.getInvLightSensitivity()}');
        array.add('dataReceived: ${package.getCompressRatio()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.TRAP_ADDRESS) {
      var package = basePackage as PhototrapPackage;
      if (nd is CPD) {
        nd.targetSensor = package.getCrossDevicesList().first;

        array.add('dataReceived: ${package.getCrossDevicesList()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.EEPROM_FACTORS) {
      var package = basePackage as EEPROMFactorsPackage;
      if (nd is RT) {
        nd.EEPROMInitialized = true;
        nd.wakeNetworkResendTimeMs = package.getWakeNetworkResendTimeMs();
        nd.alarmResendTimeMs = package.getAlarmResendTimeMs();
        nd.seismicResendTimeMs = package.getSeismicResendTimeMs();
        nd.photoResendTimeMs = package.getPhotoResendTimeMs();
        nd.alarmTriesResend = package.getAlarmTriesResend();
        nd.seismicTriesResend = package.getSeismicTriesResend();
        nd.photoTriesResend = package.getPhotoTriesResend();
        nd.periodicSendTelemetryTime10s = package.getPeriodicSendTelemetryTime10S();
        nd.afterSeismicAlarmPauseS = package.getAfterSeismicAlarmPauseS();
        nd.afterLineAlarmPauseS = package.getAfterLineAlarmPauseS();
        nd.batteryPeriodicUpdate10min = package.getBatteryPeriodicUpdate10Min();
        nd.batteryVoltageThresholdAlarm100mV = package.getBatteryVoltageThresholdAlarm100mV();
        nd.batteryResidueThresholdAlarmPC = package.getBatteryResidueThresholdAlarmPC();
        nd.batteryPeriodicAlarmH = package.getBatteryPeriodicAlarmH();
        nd.deviceType = package.getDeviceType();

        nd.humanSignalsTreshold = package.getHumanSignalsTreshold();
        nd.humanIntervalsCount = package.getHumanIntervalsCount();
        nd.transportSignalsTreshold = package.getTransportSignalsTreshold();
        nd.transportIntervalsCount = package.getTransportIntervalsCount();

        array.add('dataReceived: ${package.getHumanSignalsTreshold()}');
        array.add('dataReceived: ${package.getHumanIntervalsCount()}');
        array.add('dataReceived: ${package.getTransportSignalsTreshold()}');
        array.add('dataReceived: ${package.getTransportIntervalsCount()}');
        global.pageWithMap.activateMapMarker(package.getSender());
      }
    }

    if (type == PackageType.TRAP_PHOTO_LIST) {
      var package = basePackage as PhototrapFilesPackage;
      if (nd is CPD) {
        nd.phototrapFiles = package.getPhototrapFiles();

        array.add('dataReceived: ${package.getPhototrapFiles()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.SAFETY_CATCH) {
      var package = basePackage as ExternalPowerSafetyCatchPackage;
      if (nd is RT) {
        nd.extPowerSafetyCatchState = package.getSafetyCatchState();

        array.add('dataReceived: ${package.getSafetyCatchState()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    if (type == PackageType.AUTO_EXT_POWER) {
      var package = basePackage as AutoExternalPowerPackage;
      if (nd is RT) {
        nd.autoExtPowerActivationDelaySec = package.getActivationDelay();
        nd.extPowerImpulseDurationSec = package.getImpulseDuration();
        nd.autoExtPowerState = package.getAutoExternalPowerModeState();

        array.add('dataReceived: ${package.getActivationDelay()}');
        array.add('dataReceived: ${package.getImpulseDuration()}');
        array.add('dataReceived: ${package.getAutoExternalPowerModeState()}');
        global.pageWithMap.activateMapMarker(sender);
      }
    }

    global.dataComeFlag = true;
    _page.setAllNums();
    _page.checkNewIdDevice();
  }

  @override
  void alarmReceived(BasePackage basePackage) {
    if (basePackage.getType() == PackageType.ALARM) {
      var package = basePackage as AlarmPackage;
      var bufDev = package.getSender();
      if (global.itemsMan.getAllIds().contains(bufDev)) {
        global.pageWithMap.alarmMapMarker(bufDev, package.getAlarmReason());

        array.add('dataReceived: ${package.getAlarmType()}');
        array.add('dataReceived: ${package.getAlarmReason()}');
        global.dataComeFlag = true;
        _page.checkNewIdDevice();
      }
    }
  }

  @override
  void ranOutOfSendAttempts(int tid, BasePackage? pb) {
    tits.remove(tid);
    if (global.itemsMan.getAllIds().contains(pb!.getReceiver()) && global.listMapMarkers[pb.getReceiver()]!.markerData.notifier.active) {
      global.pageWithMap.deactivateMapMarker(global.listMapMarkers[pb.getReceiver()]!.markerData.id!);
      array.add('RanOutOfSendAttempts');
      global.dataComeFlag = true;
      _page.checkNewIdDevice();
    }
  }

  @override
  State createState() {
    _page = _DeviceParametersPage();
    return _page;
  }
}

class _DeviceParametersPage extends State<DeviceParametersPage> with AutomaticKeepAliveClientMixin<DeviceParametersPage> {
  @override
  bool get wantKeepAlive => true;
  ScrollController _scrollController = ScrollController();
  List<DropdownMenuItem<String>> dropdownItems = [];
  String? bufferDeviceType;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration.zero, (_) {
      setState(() {});
    });
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
        setAllNums();
      }
      if (global.unallowedHopsCame == true) {
        dialogUnallowedHopsBuilder();
        global.unallowedHopsCame = false;
        setAllNums();
      }
    });
  }

  //Main settings

  void checkDevID(int newId, int oldId) {
    setState(() {
      var listIdsBuf = global.itemsMan.getAllIds();
      if (oldId == newId) return;
      if (listIdsBuf.contains(newId)) {
        showError('This ID already exists');
        widget._cloneItem.id = oldId;
        return;
      }
      if (newId > 0 && newId < 256) {
        showError("Invalid ID \n ID can be from 1 to 255");
        widget._cloneItem.id = oldId;
        return;
      }
      if (listIdsBuf.contains(oldId)) {
        global.pageWithMap.changeMapMarkerID(oldId, newId);
        setAllNums();
      }
    });
  }

  void checkDevType(int id, String oldType, String newType) {
    setState(() {
      if (oldType == newType) {
        return;
      }
      if (newType == STD.Name() && global.flagCheckSPPU == true) {
        showError('STD on map');
        return;
      }
      if (newType != STD.Name() && oldType == STD.Name() && global.flagCheckSPPU == true) {
        global.flagCheckSPPU = false;
      }
      global.pageWithMap.changeMapMarkerType(id, oldType, newType);
      setAllNums();
    });
  }

  void takeTimeClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_TIME);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setTimeClick(int devId) {
    setState(() {
      TimePackage timePackage = TimePackage();
      timePackage.setReceiver(devId);
      timePackage.setSender(RoutesManager.getLaptopAddress());
      var tid = global.postManager.sendPackage(timePackage);

      widget.setRequests[tid] = timePackage;
      widget.tits.add(tid);
    });
  }

  void takeVersionClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_VERSION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  //Coord settings

  void takeCordClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_COORDINATE);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setCordClick(int devId, double latitude, double longitude) {
    setState(() {
      CoordinatesPackage coordinatesPackage = CoordinatesPackage();
      coordinatesPackage.setReceiver(devId);
      coordinatesPackage.setSender(RoutesManager.getLaptopAddress());
      coordinatesPackage.setLatitude(latitude);
      coordinatesPackage.setLongitude(longitude);
      var tid = global.postManager.sendPackage(coordinatesPackage);

      widget.setRequests[tid] = coordinatesPackage;
      widget.tits.add(tid);
    });
  }

  //Radio settings

  void takeSignalStrengthClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_INFORMATION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void takeAllowedHopsClick(int devId) {
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
          title: const Text('Allowed hops'),
          content: Text(global.itemsMan.getSelected<RT>()!.allowedHops.toString()),
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

  void takeUnallowedHopsClick(int devId) {
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
          title: const Text('Unallowed hops'),
          content: Text(global.itemsMan.getSelected<RT>()!.unallowedHops.toString()),
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

  void takeRetransmissionAllClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_ALLOWED_HOPS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.retransmissionRequests.add(tid);
    });
  }

  void setRetransmissionAllClick(int devId, bool checked) {
    setState(() {
      HopsPackage hopsPackage = HopsPackage();
      hopsPackage.setReceiver(devId);
      hopsPackage.setSender(RoutesManager.getLaptopAddress());
      hopsPackage.addHop(checked ? RoutesManager.getRtAllHop() : 0);
      hopsPackage.fillZeroHops();
      var tid = global.postManager.sendPackage(hopsPackage);
      widget.setRequests[tid] = hopsPackage;
      widget.tits.add(tid);
      global.retransmissionRequests.add(tid);
    });
  }

  void takePriorityClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_ALLOWED_HOPS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setPriorityClick(int devId, bool priority) {
    setState(() {
      HopsPackage hopsPackage = HopsPackage();
      hopsPackage.setReceiver(devId);
      hopsPackage.setSender(RoutesManager.getLaptopAddress());
      hopsPackage.addHop(priority ? RoutesManager.getRtAllHop() : 0);
      hopsPackage.addHop(0);
      var tid = global.postManager.sendPackage(hopsPackage);
      widget.setRequests[tid] = hopsPackage;
      widget.tits.add(tid);
    });
  }

  void buttonResetRetransmissionClick(int devId) {
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

  void takeInternalDeviceParamClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_STATE);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setInternalDeviceParamClick(int devId, int mask) {
    setState(() {
      StatePackage statePackage = StatePackage();
      statePackage.setReceiver(devId);
      statePackage.setSender(RoutesManager.getLaptopAddress());
      statePackage.setStateMask(mask);
      var tid = global.postManager.sendPackage(statePackage);
      widget.setRequests[tid] = statePackage;
      widget.tits.add(tid);
    });
  }

  void takeInternalDeviceStateClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_PERIPHERY);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  // Internal power

  void takeSafetyCatch(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_SAFETY_CATCH);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setSafetyCatch(int devId, bool safetyCatch) {
    setState(() {
      ExternalPowerSafetyCatchPackage externalPowerSafetyCatchPackage = ExternalPowerSafetyCatchPackage();
      externalPowerSafetyCatchPackage.setReceiver(devId);
      externalPowerSafetyCatchPackage.setSender(RoutesManager.getLaptopAddress());
      externalPowerSafetyCatchPackage.setSafetyCatchState(safetyCatch);
      var tid = global.postManager.sendPackage(externalPowerSafetyCatchPackage);
      widget.setRequests[tid] = externalPowerSafetyCatchPackage;
      widget.tits.add(tid);
    });
  }

  void takeAutoExtPower(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_AUTO_EXT_POWER);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setAutoExtPower(int devId, bool extPower, int delayS, int durationS) {
    setState(() {
      AutoExternalPowerPackage autoExternalPowerPackage = AutoExternalPowerPackage();
      autoExternalPowerPackage.setReceiver(devId);
      autoExternalPowerPackage.setSender(RoutesManager.getLaptopAddress());
      autoExternalPowerPackage.setActivationDelay(delayS);
      autoExternalPowerPackage.setImpulseDuration(durationS);
      autoExternalPowerPackage.setAutoExternalPowerModeState(extPower);
      var tid = global.postManager.sendPackage(autoExternalPowerPackage);
      widget.setRequests[tid] = autoExternalPowerPackage;
      widget.tits.add(tid);
    });
  }

  void takeExternalPowerClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_EXTERNAL_POWER);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setExternalPowerClick(int devId, ExternalPower extFlag) {
    setState(() {
      ExternalPowerPackage externalPowerPackage = ExternalPowerPackage();
      externalPowerPackage.setReceiver(devId);
      externalPowerPackage.setSender(RoutesManager.getLaptopAddress());
      externalPowerPackage.setExternalPowerState(extFlag);
      var tid = global.postManager.sendPackage(externalPowerPackage);
      widget.setRequests[tid] = externalPowerPackage;
      widget.tits.add(tid);
    });
  }

  // Power source

  void takeBatteryMonitorClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_BATTERY_MONITOR);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  //Seismic settings

  void takeStateHumanTransportSensitivityClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_ALARM_REASON_MASK);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setStateHumanTransportSensitivityClick(int devId, int mask) {
    setState(() {
      AlarmReasonMaskPackage alarmReasonMaskPackage = AlarmReasonMaskPackage();
      alarmReasonMaskPackage.setReceiver(devId);
      alarmReasonMaskPackage.setSender(RoutesManager.getLaptopAddress());
      alarmReasonMaskPackage.setAlarmReasonMask(mask);
      var tid = global.postManager.sendPackage(alarmReasonMaskPackage);
      widget.setRequests[tid] = alarmReasonMaskPackage;

      widget.tits.add(tid);
    });
  }

  void takeSignalSwingClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_SIGNAL_SWING);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void takeHumanSensitivityClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_HUMAN_SENSITIVITY);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setHumanSensitivityClick(int devId, int sensitivity) {
    setState(() {
      HumanSensitivityPackage humanSensitivityPackage = HumanSensitivityPackage();
      humanSensitivityPackage.setReceiver(devId);
      humanSensitivityPackage.setSender(RoutesManager.getLaptopAddress());
      humanSensitivityPackage.setHumanSensitivity(sensitivity);
      var tid = global.postManager.sendPackage(humanSensitivityPackage);
      widget.setRequests[tid] = humanSensitivityPackage;

      widget.tits.add(tid);
    });
  }

  void takeTransportSensitivityClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_TRANSPORT_SENSITIVITY);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setTransportSensitivityClick(int devId, int sensitivity) {
    setState(() {
      TransportSensitivityPackage transportSensitivityPackage = TransportSensitivityPackage();
      transportSensitivityPackage.setReceiver(devId);
      transportSensitivityPackage.setSender(RoutesManager.getLaptopAddress());
      transportSensitivityPackage.setTransportSensitivity(sensitivity);
      var tid = global.postManager.sendPackage(transportSensitivityPackage);
      widget.setRequests[tid] = transportSensitivityPackage;
      widget.tits.add(tid);
    });
  }

  void takeCriterionFilterClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_CRITERION_FILTER);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setCriterionFilterClick(int devId, CriterionFilter filter) {
    setState(() {
      CriterionFilterPackage criterionFilterPackage = CriterionFilterPackage();
      criterionFilterPackage.setReceiver(devId);
      criterionFilterPackage.setSender(RoutesManager.getLaptopAddress());
      criterionFilterPackage.setCriterionFilter(filter);
      var tid = global.postManager.sendPackage(criterionFilterPackage);
      widget.setRequests[tid] = criterionFilterPackage;
      widget.tits.add(tid);
    });
  }

  void takeSignalToNoiseClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_SIGNAL_TO_NOISE_RATIO);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setSignalToNoiseClick(int devId, int snr) {
    setState(() {
      SignalToNoiseRatioPackage signalToNoiseRatioPackage = SignalToNoiseRatioPackage();
      signalToNoiseRatioPackage.setReceiver(devId);
      signalToNoiseRatioPackage.setSender(RoutesManager.getLaptopAddress());
      signalToNoiseRatioPackage.setSignalToNoiseRatio(snr);
      var tid = global.postManager.sendPackage(signalToNoiseRatioPackage);
      widget.setRequests[tid] = signalToNoiseRatioPackage;
      widget.tits.add(tid);
    });
  }

  void takeCriterionRecognitionClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_CRITERION_RECOGNITION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setCriterionRecognitionClick(int devId, int index, List<int> value) {
    setState(() {
      CriterionRecognitionPackage criterionRecognitionPackage = CriterionRecognitionPackage();
      criterionRecognitionPackage.setReceiver(devId);
      criterionRecognitionPackage.setSender(RoutesManager.getLaptopAddress());
      for (int i = 0; i < index; i++) {
        criterionRecognitionPackage.setCriterion(i, value[i]);
      }
      var tid = global.postManager.sendPackage(criterionRecognitionPackage);
      widget.setRequests[tid] = criterionRecognitionPackage;
      widget.tits.add(tid);
    });
  }

  void takeEEPROMClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_EEPROM_FACTORS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setEEPROMClick(int devId, int singleHuman, int singleTransport, int seriesHuman, int seriesTransport) {
    setState(() {
      var device = global.itemsMan.getSelected<RT>()!;
      if (!device.EEPROMInitialized) {
        return;
      }

      EEPROMFactorsPackage pfp = EEPROMFactorsPackage();
      pfp.setReceiver(devId);
      pfp.setSender(RoutesManager.getLaptopAddress());
      pfp.setWakeNetworkResendTimeMs(device.wakeNetworkResendTimeMs);
      pfp.setAlarmResendTimeMs(device.alarmResendTimeMs);
      pfp.setSeismicResendTimeMs(device.seismicResendTimeMs);
      pfp.setPhotoResendTimeMs(device.photoResendTimeMs);
      pfp.setAlarmTriesResend(device.alarmTriesResend);
      pfp.setSeismicTriesResend(device.seismicTriesResend);
      pfp.setPhotoTriesResend(device.photoTriesResend);
      pfp.setPeriodicSendTelemetryTime10S(device.periodicSendTelemetryTime10s);
      pfp.setAfterSeismicAlarmPauseS(device.afterSeismicAlarmPauseS);
      pfp.setAfterLineAlarmPauseS(device.afterLineAlarmPauseS);
      pfp.setBatteryPeriodicUpdate10Min(device.batteryPeriodicUpdate10min);
      pfp.setBatteryVoltageThresholdAlarm100mV(device.batteryVoltageThresholdAlarm100mV);
      pfp.setBatteryResidueThresholdAlarmPC(device.batteryResidueThresholdAlarmPC);
      pfp.setBatteryPeriodicAlarmH(device.batteryPeriodicAlarmH);
      pfp.setDeviceType(device.deviceType);

      pfp.setHumanSignalsTreshold(singleHuman);
      pfp.setHumanIntervalsCount(seriesHuman);
      pfp.setTransportSignalsTreshold(singleTransport);
      pfp.setTransportIntervalsCount(seriesTransport);
      var tid = global.postManager.sendPackage(pfp);
      widget.setRequests[tid] = pfp;
      widget.tits.add(tid);
    });
  }

  //Camera settings

  void takePhotoParametersClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_PHOTO_PARAMETERS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setPhotoParametersClick(int devId, int invLightSensitivity, PhotoImageCompression compressionRatio) {
    setState(() {
      PhotoParametersPackage photoParametersPackage = PhotoParametersPackage();
      photoParametersPackage.setReceiver(devId);
      photoParametersPackage.setSender(RoutesManager.getLaptopAddress());
      photoParametersPackage.setParameters(invLightSensitivity, compressionRatio);
      var tid = global.postManager.sendPackage(photoParametersPackage);
      widget.setRequests[tid] = photoParametersPackage;
      widget.tits.add(tid);
    });
  }

  void takeAllInfoClick(int devId) {
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

  void setMyCordsForDevice() {
    setState(() {
      widget._cloneItem.setCoordinates(global.pageWithMap.coord()!.latitude, global.pageWithMap.coord()!.longitude);
      global.listMapMarkers[widget._cloneItem.id]!.point.latitude = widget._cloneItem.latitude;
      global.listMapMarkers[widget._cloneItem.id]!.point.longitude = widget._cloneItem.longitude;
    });
  }

  void setAllNums() {
    setState(() {
      var item = global.itemsMan.getSelected<Marker>();
      if (item == null) return;
      widget._cloneItem = item.clone();
      bufferDeviceType = widget._cloneItem.typeName();
      if (widget._cloneItem is RT) {
        print((widget._cloneItem as RT).extPowerImpulseDurationSec);
      }
    });
  }

  Widget buildMainSettings(BuildContext context) {
    if (widget._cloneItem is! NetDevice) {
      return Container();
    }

    var nd = widget._cloneItem as NetDevice;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text('ID:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: /*TextFormField(
                    key: Key(widget._cloneItem!.id.toString()),
                    textAlign: TextAlign.center,
                    initialValue: widget._cloneItem!.id.toString(),
                    decoration: InputDecoration(helperText: widget._cloneItem!.id.toString()),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    maxLength: 3,
                    onChanged: (string) => widget._cloneItem!.id = int.parse(string),
                    onSaved: (string) => widget._cloneItem!.id = int.parse(string!),
                    textInputAction: ,

                  ),*/
                    TextField(
                  controller: TextEditingController(text: nd.id.toString()),
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (string) => nd.id = int.parse(string),
                  onSubmitted: (string) => nd.id = int.parse(string),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: SizedBox(
                width: 100,
                child: IconButton(
                  onPressed: () => checkDevID(nd.id, global.itemsMan.getSelected<NetDevice>()!.id),
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
                child: Text('Type:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: DropdownButton<String>(
                  alignment: AlignmentDirectional.topCenter,
                  onChanged: (String? value) {
                    bufferDeviceType = value!;
                  },
                  value: bufferDeviceType,
                  icon: const Icon(Icons.keyboard_double_arrow_down),
                  items: global.deviceTypeList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: SizedBox(
                width: 100,
                child: IconButton(
                  onPressed: () => checkDevType(nd.id, nd.typeName(), bufferDeviceType!),
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
                child: Text('Date/time:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(width: 200, child: Text(nd.time.toString().substring(0, 19), textAlign: TextAlign.center)),
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => takeTimeClick(nd.id),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setTimeClick(nd.id),
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
                child: Text('Firmware version:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(width: 200, child: Text(nd.firmwareVersion.toString(), textAlign: TextAlign.center)),
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => takeVersionClick(nd.id),
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
    if (widget._cloneItem is! NetDevice) {
      return Container();
    }

    var nd = widget._cloneItem as NetDevice;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text('Latitude:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: /*TextFormField(
                    key: Key(global.listMapMarkers[global.itemsMan.getSelected<NetDevice>()!.id]!.point.latitude.toStringAsFixed(6)),
                    textAlign: TextAlign.center,
                    initialValue: global.listMapMarkers[global.itemsMan.getSelected<NetDevice>()!.id]!.point.latitude.toStringAsFixed(6),
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                    onChanged: (string) {
                      global.listMapMarkers[global.itemsMan.getSelected<NetDevice>()!.id]!.point.latitude = double.parse(string);
                      bufLatitude = double.parse(string);
                    },
                  ),*/
                    TextField(
                  controller: TextEditingController(text: global.listMapMarkers[nd.id]!.point.latitude.toStringAsFixed(6)),
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (string) {
                    nd.setCoordinates(double.parse(string), nd.longitude);
                    global.listMapMarkers[nd.id]!.point.latitude = double.parse(string);
                  },
                  onSubmitted: (string) {
                    nd.setCoordinates(double.parse(string), nd.longitude);
                    global.listMapMarkers[nd.id]!.point.latitude = double.parse(string);
                  },
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: IconButton(
                  onPressed: () => setMyCordsForDevice(),
                  icon: const Icon(Icons.abc),
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
                child: Text('Longitude:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: /*TextFormField(
                    key: Key(global.listMapMarkers[global.itemsMan.getSelected<NetDevice>()!.id]!.point.longitude.toStringAsFixed(6)),
                    textAlign: TextAlign.center,
                    initialValue: global.listMapMarkers[global.itemsMan.getSelected<NetDevice>()!.id]!.point.longitude.toStringAsFixed(6),
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                    onChanged: (string) {
                      global.listMapMarkers[global.itemsMan.getSelected<NetDevice>()!.id]!.point.longitude = double.parse(string);
                      bufLongitude = double.parse(string);
                    },
                  ),*/
                    TextField(
                  controller: TextEditingController(text: global.listMapMarkers[nd.id]!.point.longitude.toStringAsFixed(6)),
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (string) {
                    nd.setCoordinates(nd.latitude, double.parse(string));
                    global.listMapMarkers[nd.id]!.point.longitude = double.parse(string);
                  },
                  onSubmitted: (string) {
                    nd.setCoordinates(nd.latitude, double.parse(string));
                    global.listMapMarkers[nd.id]!.point.longitude = double.parse(string);
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
                      onPressed: () => takeCordClick(nd.id),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setCordClick(nd.id, nd.latitude, nd.longitude),
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
    if (widget._cloneItem is! RT) {
      return Container();
    }

    var rt = widget._cloneItem as RT;

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
                child: Text('Signal strength:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: Text(rt.RSSI.toString(), textAlign: TextAlign.center),
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
                      onPressed: () => takeSignalStrengthClick(rt.id),
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
                child: Text('Allowed hops:'),
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
                      onPressed: () => takeAllowedHopsClick(rt.id),
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
                child: Text('Unallowed hops:'),
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
                      onPressed: () => takeUnallowedHopsClick(rt.id),
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
                child: Text("Rebroadcast to everyone:"),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: Checkbox(
                    value: rt.allowedHops[0] == 65535 ? true : false,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value! == true) {
                          rt.allowedHops[0] = 65535;
                        } else {
                          rt.allowedHops[0] = 0;
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
                      onPressed: () => takeRetransmissionAllClick(rt.id),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setRetransmissionAllClick(rt.id, rt.allowedHops[0] == 65535),
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
                onPressed: () => buttonResetRetransmissionClick(rt.id),
                child: const Text('Reset retransmission'),
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
    if (widget._cloneItem is! NetDevice) {
      return Container();
    }

    var nd = widget._cloneItem as NetDevice;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton(
          onPressed: () => restartDevice(nd.id),
          child: const Row(
            children: [
              Icon(Icons.restart_alt),
              Text('Reset device'),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () => saveDeviceParam(nd.id),
          child: const Row(
            children: [
              Icon(Icons.save),
              Text('Save settings'),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () => restartDevice(nd.id),
          child: const Row(
            children: [
              Icon(Icons.restore),
              Text('Factory reset'),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildConnectedDevices(BuildContext context) {
    if (widget._cloneItem is! RT) {
      return Container();
    }

    var rt = widget._cloneItem as RT;

    List<Widget> children = [];

    if (widget._cloneItem is RT) {
      children.add(const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: Text("On/Off in. dev.:"),
          ),
        ],
      ));
      children.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Text("In. Dev. 1:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                  value: rt.stateMask & DeviceState.MONITORING_LINE1 != 0,
                  onChanged: (bool? value) {
                    if (value!) {
                      rt.stateMask |= DeviceState.MONITORING_LINE1;
                    } else {
                      rt.stateMask &= ~DeviceState.MONITORING_LINE1;
                    }

                    setState(() {});
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
      ));
      children.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Text("In. dev. 2:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                  value: rt.stateMask & DeviceState.MONITORING_LINE2 != 0,
                  onChanged: (bool? value) {
                    if (value!) {
                      rt.stateMask |= DeviceState.MONITORING_LINE2;
                    } else {
                      rt.stateMask &= ~DeviceState.MONITORING_LINE2;
                    }

                    setState(() {});
                  }),
            ),
          ),
          Flexible(
            flex: 2,
            child: (widget._cloneItem is! CSD && widget._cloneItem is! CPD)
                ? SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () => takeInternalDeviceParamClick(rt.id),
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.blue,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setInternalDeviceParamClick(rt.id, rt.stateMask),
                          icon: const Icon(Icons.check),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  )
                : const SizedBox(
                    width: 100,
                  ),
          ),
        ],
      ));
    }

    if (widget._cloneItem is CSD) {
      children.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Text("Geophone:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                  value: rt.stateMask & DeviceState.MONITOR_SEISMIC != 0,
                  onChanged: (bool? value) {
                    if (value!) {
                      rt.stateMask |= DeviceState.MONITOR_SEISMIC;
                    } else {
                      rt.stateMask &= ~DeviceState.MONITOR_SEISMIC;
                    }

                    setState(() {});
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
                    onPressed: () => takeInternalDeviceParamClick(rt.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setInternalDeviceParamClick(rt.id, rt.stateMask),
                    icon: const Icon(Icons.check),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ));
    }

    if (widget._cloneItem is CPD) {
      children.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Text("Camera trap:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                  value: rt.stateMask & DeviceState.LINES_CAMERA_TRAP != 0,
                  onChanged: (bool? value) {
                    if (value!) {
                      rt.stateMask |= DeviceState.LINES_CAMERA_TRAP;
                    } else {
                      rt.stateMask &= ~DeviceState.LINES_CAMERA_TRAP;
                    }

                    setState(() {});
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
                    onPressed: () => takeInternalDeviceParamClick(rt.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setInternalDeviceParamClick(rt.id, rt.stateMask),
                    icon: const Icon(Icons.check),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ));
    }

    if (widget._cloneItem is RT) {
      children.add(const Row(
        children: [
          SizedBox(
            width: 300,
            child: Text("Device status:"),
          ),
        ],
      ));
      children.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Text("In. dev. 1:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                  value: rt.peripheryMask & PeripheryMask.LINE1 != 0,
                  onChanged: (bool? value) {
                    if (value!) {
                      rt.peripheryMask |= PeripheryMask.LINE1;
                    } else {
                      rt.peripheryMask &= ~PeripheryMask.LINE1;
                    }

                    setState(() {});
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
      ));
      children.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Text("In. dev. 2:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                  value: rt.peripheryMask & PeripheryMask.LINE2 != 0,
                  onChanged: (bool? value) {
                    if (value!) {
                      rt.peripheryMask |= PeripheryMask.LINE2;
                    } else {
                      rt.peripheryMask &= ~PeripheryMask.LINE2;
                    }

                    setState(() {});
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
                    onPressed: () => takeInternalDeviceStateClick(rt.id),
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
      ));
    }

    if (widget._cloneItem is CPD) {
      children.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Text("Camera:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                  value: rt.peripheryMask & PeripheryMask.CAMERA != 0,
                  onChanged: (bool? value) {
                    if (value!) {
                      rt.peripheryMask |= PeripheryMask.CAMERA;
                    } else {
                      rt.peripheryMask &= ~PeripheryMask.CAMERA;
                    }

                    setState(() {});
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
                    onPressed: () => takeInternalDeviceStateClick(rt.id),
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
      ));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }

  Widget buildExtPower(BuildContext context) {
    if (widget._cloneItem is! RT) {
      return Container();
    }

    var rt = widget._cloneItem as RT;

    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 150,
              child: Text("Safety catch:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                  value: rt.extPowerSafetyCatchState,
                  onChanged: (bool? value) {
                    setState(() {
                      rt.extPowerSafetyCatchState = value!;
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
                    onPressed: () => takeSafetyCatch(rt.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setSafetyCatch(rt.id, rt.extPowerSafetyCatchState),
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
              child: Text('Activation \ndelay:'),
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
                        '$value sec',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList();
                },
                isExpanded: true,
                items: global.delayList.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value sec'),
                  );
                }).toList(),
                onChanged: rt.extPowerSafetyCatchState
                    ? (int? value) {
                        rt.autoExtPowerActivationDelaySec = value!;
                      }
                    : null,
                value: global.delayList.contains(rt.autoExtPowerActivationDelaySec) ? rt.autoExtPowerActivationDelaySec : null,
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
              child: Text('Pulse \nduration:'),
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
                        '$value sec',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList();
                },
                isExpanded: true,
                items: global.impulseList.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value sec'),
                  );
                }).toList(),
                onChanged: rt.extPowerSafetyCatchState
                    ? (int? value) {
                        rt.extPowerImpulseDurationSec = value!;
                      }
                    : null,
                value: global.impulseList.contains(rt.extPowerImpulseDurationSec) ? rt.extPowerImpulseDurationSec : null,
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
              child: Text("Switching by break:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                value: rt.autoExtPowerState,
                onChanged: global.itemsMan.getSelected<RT>()!.extPowerSafetyCatchState
                    ? (bool? value) {
                        setState(() {
                          rt.autoExtPowerState = value!;
                        });
                      }
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
                    onPressed: () => takeAutoExtPower(rt.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        setAutoExtPower(rt.id, rt.autoExtPowerState, rt.autoExtPowerActivationDelaySec, rt.extPowerImpulseDurationSec),
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
              child: Text("Power:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                  value: rt.extPower.index != 0,
                  onChanged: (bool? value) {
                    setState(() {
                      value! ? rt.extPower = ExternalPower.ON : rt.extPower = ExternalPower.OFF;
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
                    onPressed: () => takeExternalPowerClick(rt.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setExternalPowerClick(rt.id, rt.extPower),
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
    if (widget._cloneItem is! RT) {
      return Container();
    }

    var rt = widget._cloneItem as RT;

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
                child: Text('Voltage, V:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: Text(rt.batMonVoltage.toStringAsFixed(2), textAlign: TextAlign.center),
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
                child: Text('Temperature, °С:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: Text(rt.batMonTemperature.toStringAsFixed(2), textAlign: TextAlign.center),
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
                      onPressed: () => takeBatteryMonitorClick(rt.id),
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
    if (widget._cloneItem is! CSD) {
      return Container();
    }

    var csd = widget._cloneItem as CSD;

    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Text("Human:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                  value: csd.alarmReasonMask & AlarmReasonMask.HUMAN != 0,
                  onChanged: (bool? value) {
                    if (value!) {
                      csd.alarmReasonMask |= AlarmReasonMask.HUMAN;
                    } else {
                      csd.alarmReasonMask &= ~AlarmReasonMask.HUMAN;
                    }
                    setState(() {});
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
              child: Text("Transport:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                  value: csd.alarmReasonMask & AlarmReasonMask.AUTO != 0,
                  onChanged: (bool? value) {
                    if (value!) {
                      csd.alarmReasonMask |= AlarmReasonMask.AUTO;
                    } else {
                      csd.alarmReasonMask &= ~AlarmReasonMask.AUTO;
                    }
                    setState(() {});
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
                    onPressed: () => takeStateHumanTransportSensitivityClick(csd.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setStateHumanTransportSensitivityClick(csd.id, csd.alarmReasonMask),
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
              child: Text('Signal swing:'),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Text(csd.signalSwing.toString(), textAlign: TextAlign.center),
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
                    onPressed: () => takeSignalSwingClick(csd.id),
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
              child: Text('Human \nsensitivity:\n(25-255)'),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: /*TextFormField(
                  key: Key(bufHumanSens.toString()),
                  textAlign: TextAlign.center,
                  initialValue: bufHumanSens.toString(),
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
                ),*/
                  TextField(
                controller: TextEditingController(text: csd.humanSensitivity.toString()),
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (string) => csd.humanSensitivity = int.parse(string),
                onSubmitted: (string) => csd.humanSensitivity = int.parse(string),
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
                    onPressed: () => takeHumanSensitivityClick(csd.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      csd.humanSensitivity > 24 && csd.humanSensitivity < 256
                          ? setHumanSensitivityClick(global.itemsMan.getSelected<CSD>()!.id, csd.humanSensitivity)
                          : {
                              showError('Sensitivity from 25 to 255'),
                              csd.humanSensitivity = global.itemsMan.getSelected<CSD>()!.humanSensitivity,
                            };
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
              child: Text('Transport \nsensitivity:\n(25-255)'),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: /*TextFormField(
                  textAlign: TextAlign.center,
                  key: Key(bufAutoSens.toString()),
                  initialValue: bufAutoSens.toString(),
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
                ),*/
                  TextField(
                controller: TextEditingController(text: csd.transportSensitivity.toString()),
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (string) => csd.transportSensitivity = int.parse(string),
                onSubmitted: (string) => csd.transportSensitivity = int.parse(string),
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
                    onPressed: () => takeTransportSensitivityClick(csd.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      csd.transportSensitivity > 24 && csd.transportSensitivity < 256
                          ? setTransportSensitivityClick(csd.id, csd.transportSensitivity)
                          : {
                              showError('Sensitivity from 25 to 255'),
                              csd.transportSensitivity = global.itemsMan.getSelected<CSD>()!.transportSensitivity
                            };
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
              width: 100,
              child: Text('Criterion \nfilter:'),
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
                    child: Text(global.critFilter[value.index]),
                  );
                }).toList(),
                onChanged: (CriterionFilter? value) {
                  csd.criterionFilter = value!;
                },
                value: csd.criterionFilter,
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
                    onPressed: () => takeCriterionFilterClick(csd.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setCriterionFilterClick(csd.id, csd.criterionFilter),
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
              child: Text('Ratio signal \ntransport/noise:\n(5-40)'),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: /*TextFormField(
                textAlign: TextAlign.center,
                key: Key(bufSnr.toString()),
                initialValue: bufSnr.toString(),
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
              ),*/
                  TextField(
                controller: TextEditingController(text: csd.snr.toString()),
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (string) => csd.snr = int.parse(string),
                onSubmitted: (string) => csd.snr = int.parse(string),
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
                    onPressed: () => takeSignalToNoiseClick(csd.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      csd.snr > 4 && csd.snr < 41
                          ? setSignalToNoiseClick(csd.id, csd.snr)
                          : {showError('Ratio from 5 to 40'), csd.snr = global.itemsMan.getSelected<CSD>()!.snr};
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
      const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text('Recognition parameters:'),
      ]),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Text("Interference/Person"),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: /*TextFormField(
                textAlign: TextAlign.center,
                key: Key(bufRecogniZero.toString()),
                initialValue: bufRecogniZero.toString(),
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
              ),*/
                  TextField(
                controller: TextEditingController(text: csd.recognitionParameters[0].toString()),
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (string) => csd.recognitionParameters[0] = int.parse(string),
                onSubmitted: (string) => csd.recognitionParameters[0] = int.parse(string),
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
              child: Text('Human/Transport'),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: /*TextFormField(
                textAlign: TextAlign.center,
                key: Key(bufRecogniFirst.toString()),
                initialValue: bufRecogniFirst.toString(),
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
              ),*/
                  TextField(
                controller: TextEditingController(text: csd.recognitionParameters[1].toString()),
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (string) => csd.recognitionParameters[1] = int.parse(string),
                onSubmitted: (string) => csd.recognitionParameters[1] = int.parse(string),
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
                    onPressed: () => takeCriterionRecognitionClick(csd.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      csd.recognitionParameters[0] > -1 &&
                              csd.recognitionParameters[0] < 256 &&
                              csd.recognitionParameters[1] > -1 &&
                              csd.recognitionParameters[1] < 256
                          ? setCriterionRecognitionClick(csd.id, csd.recognitionParameters.length, csd.recognitionParameters)
                          : showError('Parameters from 0 to 255');
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
      const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text('Alarm filtering:'),
      ]),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: Text("Single(human):"),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: /*TextFormField(
                textAlign: TextAlign.center,
                key: Key(global.itemsMan.getSelected<CSD>()!.humanSignalsTreshold.toString()),
                initialValue: global.itemsMan.getSelected<CSD>()!.humanSignalsTreshold.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String value = newValue.text;
                    global.itemsMan.getSelected<CSD>()!.humanSignalsTreshold = int.parse(value);
                    if (value.length > 3) {
                      return TextEditingValue(
                        text: oldValue.text,
                        selection: TextSelection.collapsed(offset: oldValue.selection.end),
                      );
                    }
                    return TextEditingValue(
                      text: global.itemsMan.getSelected<CSD>()!.humanSignalsTreshold.toString(),
                      selection:
                          TextSelection.collapsed(offset: global.itemsMan.getSelected<CSD>()!.humanSignalsTreshold.toString().length),
                    );
                  })
                ],
              ),*/
                  TextField(
                controller: TextEditingController(text: csd.humanSignalsTreshold.toString()),
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (string) => csd.humanSignalsTreshold = int.parse(string),
                onSubmitted: (string) => csd.humanSignalsTreshold = int.parse(string),
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
              child: Text("Serial(person):"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: DropdownButton<int>(
                selectedItemBuilder: (BuildContext context) {
                  return global.serialHuman.map((int value) {
                    return Align(
                      alignment: Alignment.center,
                      child: Text(
                        '$value in ' + value.toString() + '0 seconds ',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList();
                },
                isExpanded: true,
                items: global.serialHuman.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value in ' + value.toString() + '0 seconds '),
                  );
                }).toList(),
                onChanged: (int? value) {
                  csd.seriesHumanFilterTreshold = value!;
                },
                value: csd.seriesHumanFilterTreshold,
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
              child: Text("Single(transport):"),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: /*TextFormField(
                textAlign: TextAlign.center,
                key: Key(global.itemsMan.getSelected<CSD>()!.transportSignalsTreshold.toString()),
                initialValue: global.itemsMan.getSelected<CSD>()!.transportSignalsTreshold.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String value = newValue.text;
                    global.itemsMan.getSelected<CSD>()!.transportSignalsTreshold = int.parse(value);
                    if (value.length > 3) {
                      return TextEditingValue(
                        text: oldValue.text,
                        selection: TextSelection.collapsed(offset: oldValue.selection.end),
                      );
                    }
                    return TextEditingValue(
                      text: global.itemsMan.getSelected<CSD>()!.transportSignalsTreshold.toString(),
                      selection:
                          TextSelection.collapsed(offset: global.itemsMan.getSelected<CSD>()!.transportSignalsTreshold.toString().length),
                    );
                  })
                ],
              ),*/
                  TextField(
                controller: TextEditingController(text: csd.transportSignalsTreshold.toString()),
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (string) => csd.transportSignalsTreshold = int.parse(string),
                onSubmitted: (string) => csd.transportSignalsTreshold = int.parse(string),
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
              child: Text("Serial(transport):"),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              width: 100,
              child: DropdownButton<int>(
                selectedItemBuilder: (BuildContext context) {
                  return global.serialTransport.map((int value) {
                    return Align(
                      alignment: Alignment.center,
                      child: Text(
                        '$value in ' + value.toString() + '0 seconds ',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList();
                },
                isExpanded: true,
                items: global.serialTransport.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value in ' + value.toString() + '0 seconds '),
                  );
                }).toList(),
                onChanged: (int? value) {
                  csd.seriesTransportFilterTreshold = value!;
                },
                value: csd.seriesTransportFilterTreshold,
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
                    onPressed: () => takeEEPROMClick(csd.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      csd.humanSignalsTreshold > -1 &&
                              csd.humanSignalsTreshold < 256 &&
                              csd.transportSignalsTreshold > -1 &&
                              csd.transportSignalsTreshold < 256
                          ? {
                              csd.EEPROMInitialized
                                  ? setEEPROMClick(csd.id, csd.humanSignalsTreshold, csd.transportSignalsTreshold,
                                      csd.seriesHumanFilterTreshold, csd.seriesTransportFilterTreshold)
                                  : showError('Request data first'),
                            }
                          : showError('Parameters from 0 to 255');
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
    ]);
  }

  Widget buildCameraSettings(BuildContext context) {
    if (widget._cloneItem is! CPD) {
      return Container();
    }

    var cpd = widget._cloneItem as CPD;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text('Sensitivity:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(
                width: 200,
                child: /* TextFormField(
                    textAlign: TextAlign.center,
                    initialValue:
                        global.itemsMan.getSelected() != null ? global.itemsMan.getSelected<CPD>()!.cameraSensitivity.toString() : 'null',
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        String value = newValue.text;
                        global.itemsMan.getSelected<CPD>()!.cameraSensitivity = int.parse(value);
                        if (value.length > 3) {
                          return TextEditingValue(
                            text: oldValue.text,
                            selection: TextSelection.collapsed(offset: oldValue.selection.end),
                          );
                        }
                        return TextEditingValue(
                          text: global.itemsMan.getSelected<CPD>()!.cameraSensitivity.toString(),
                          selection:
                              TextSelection.collapsed(offset: global.itemsMan.getSelected<CPD>()!.cameraSensitivity.toString().length),
                        );
                      }),
                    ],
                  ),*/
                    TextField(
                  controller: TextEditingController(text: cpd.cameraSensitivity.toString()),
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (string) => cpd.cameraSensitivity = int.parse(string),
                  onSubmitted: (string) => cpd.cameraSensitivity = int.parse(string),
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
                  onChanged: (PhotoImageCompression? value) => cpd.cameraCompression = value!,
                  value: cpd.cameraCompression,
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
                      onPressed: () => takePhotoParametersClick(cpd.id),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        cpd.cameraSensitivity > -1 && cpd.cameraSensitivity < 256
                            ? setPhotoParametersClick(cpd.id, cpd.cameraSensitivity, cpd.cameraCompression)
                            : {
                                showError('Sensitivity from 0 to 255'),
                                cpd.cameraSensitivity = global.itemsMan.getSelected<CPD>()!.cameraSensitivity
                              };
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

  Widget buildMCDSettings(BuildContext context) {
    if (widget._cloneItem is! MCD) {
      return Container();
    }

    var mcd = widget._cloneItem as MCD;

    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Flexible(
            flex: 2,
            child: SizedBox(
              width: 150,
              child: Text("Priority:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                  value: mcd.priority,
                  onChanged: (bool? value) {
                    setState(() {
                      mcd.priority = value!;
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
                    onPressed: () => takeRetransmissionAllClick(mcd.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setRetransmissionAllClick(mcd.id, mcd.priority),
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
              child: Text("GPS:"),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              width: 200,
              child: Checkbox(
                  value: mcd.GPSState,
                  onChanged: (bool? value) {
                    setState(() {
                      mcd.GPSState = value!;
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
                    onPressed: () => takeExternalPowerClick(mcd.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setExternalPowerClick(mcd.id, mcd.GPSState ? ExternalPower.ON : ExternalPower.OFF),
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

  Widget buildPowerMCD(BuildContext context) {
    if (widget._cloneItem is! MCD) {
      return Container();
    }

    var mcd = widget._cloneItem as MCD;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Text('Voltage, V:'),
              ),
            ),
            Flexible(
              flex: 3,
              child: SizedBox(width: 200, child: Text(mcd.batMonVoltage.toStringAsFixed(2), textAlign: TextAlign.center)),
            ),
            Flexible(
              flex: 2,
              child: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => takeBatteryMonitorClick(global.itemsMan.getSelected<NetDevice>()!.id),
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

  final List<bool> _isOpenMain = List.filled(4, false);
  final List<bool> _isOpenCSD = List.filled(8, false);
  final List<bool> _isOpenCFU = List.filled(8, false);
  final List<bool> _isOpenRT = List.filled(7, false);
  final List<bool> _isOpenMCD = List.filled(5, false);

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
                global.pageWithMap.unselectMapMarker();
                global.itemsMan.setSelected(int.parse(widget.dropdownValue));
                global.pageWithMap.selectMapMarker(global.itemsMan.getSelected<NetDevice>()!.id);
                global.mainBottomSelectedDev = Text(
                  '${global.itemsMan.getSelected<NetDevice>()!.typeName()} #${global.itemsMan.getSelected<NetDevice>()!.id}',
                  textScaleFactor: 1.4,
                );
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(
              visible: widget._cloneItem.typeName() == STD.Name(),
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
                        title: Text('Main'),
                      );
                    },
                    body: buildMainSettings(context),
                    isExpanded: _isOpenMain[0],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Coordinates'),
                      );
                    },
                    body: buildCoordSettings(context),
                    isExpanded: _isOpenMain[1],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Radio'),
                      );
                    },
                    body: buildRadioSettings(context),
                    isExpanded: _isOpenMain[2],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Save/Reset settings'),
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
              visible: widget._cloneItem.typeName() == RT.Name(),
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
                      return const ListTile(
                        title: Text('Main'),
                      );
                    },
                    body: buildMainSettings(context),
                    isExpanded: _isOpenRT[0],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Coordinates'),
                      );
                    },
                    body: buildCoordSettings(context),
                    isExpanded: _isOpenRT[1],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Connected devices'),
                      );
                    },
                    body: buildConnectedDevices(context),
                    isExpanded: _isOpenRT[2],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('External power'),
                      );
                    },
                    body: buildExtPower(context),
                    isExpanded: _isOpenRT[3],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Radio'),
                      );
                    },
                    body: buildRadioSettings(context),
                    isExpanded: _isOpenRT[4],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Power supply'),
                      );
                    },
                    body: buildPowerSupply(context),
                    isExpanded: _isOpenRT[5],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Save/Reset settings'),
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
              visible: widget._cloneItem.typeName() == CSD.Name(),
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
                      return const ListTile(
                        title: Text('Main'),
                      );
                    },
                    body: buildMainSettings(context),
                    isExpanded: _isOpenCSD[0],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Coordinates'),
                      );
                    },
                    body: buildCoordSettings(context),
                    isExpanded: _isOpenCSD[1],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Connected devices'),
                      );
                    },
                    body: buildConnectedDevices(context),
                    isExpanded: _isOpenCSD[2],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('External power'),
                      );
                    },
                    body: buildExtPower(context),
                    isExpanded: _isOpenCSD[3],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Radio'),
                      );
                    },
                    body: buildRadioSettings(context),
                    isExpanded: _isOpenCSD[4],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Power supply'),
                      );
                    },
                    body: buildPowerSupply(context),
                    isExpanded: _isOpenCSD[5],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Seismic'),
                      );
                    },
                    body: buildSeismicSettings(context),
                    isExpanded: _isOpenCSD[6],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Save/Reset settings'),
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
              visible: widget._cloneItem.typeName() == CPD.Name(),
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
                      return const ListTile(
                        title: Text('Main'),
                      );
                    },
                    body: buildMainSettings(context),
                    isExpanded: _isOpenCFU[0],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Coordinates'),
                      );
                    },
                    body: buildCoordSettings(context),
                    isExpanded: _isOpenCFU[1],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Connected devices'),
                      );
                    },
                    body: buildConnectedDevices(context),
                    isExpanded: _isOpenCFU[2],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('External power'),
                      );
                    },
                    body: buildExtPower(context),
                    isExpanded: _isOpenCFU[3],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Radio'),
                      );
                    },
                    body: buildRadioSettings(context),
                    isExpanded: _isOpenCFU[4],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Power supply'),
                      );
                    },
                    body: buildPowerSupply(context),
                    isExpanded: _isOpenCFU[5],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Camera'),
                      );
                    },
                    body: buildCameraSettings(context),
                    isExpanded: _isOpenCFU[6],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Save/Reset settings'),
                      );
                    },
                    body: buildDeviceSettings(context),
                    isExpanded: _isOpenCFU[7],
                    canTapOnHeader: true,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget._cloneItem.typeName() == MCD.Name(),
              child: ExpansionPanelList(
                elevation: 2,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isOpenMCD[index] = !isExpanded;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Main'),
                      );
                    },
                    body: buildMainSettings(context),
                    isExpanded: _isOpenMCD[0],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Coordinates'),
                      );
                    },
                    body: buildCoordSettings(context),
                    isExpanded: _isOpenMCD[1],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Power supply'),
                      );
                    },
                    body: buildPowerMCD(context),
                    isExpanded: _isOpenMCD[2],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('MCD'),
                      );
                    },
                    body: buildMCDSettings(context),
                    isExpanded: _isOpenMCD[3],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Save/Reset settings'),
                      );
                    },
                    body: buildDeviceSettings(context),
                    isExpanded: _isOpenMCD[4],
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