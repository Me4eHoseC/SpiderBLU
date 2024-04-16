import 'dart:async';

import '../core/AIRS.dart';
import 'BasePackage.dart';
import 'FileManager.dart';
import 'NetCommonPackages.dart';
import 'NetNetworkPackages.dart';
import 'NetPackagesDataTypes.dart';
import 'NetPhotoPackages.dart';
import 'NetSeismicPackage.dart';
import 'PostManager.dart';
import 'RoutesManager.dart';

import '../core/CPD.dart';
import '../core/CSD.dart';
import '../core/MCD.dart';
import '../core/NetDevice.dart';
import '../core/RT.dart';
import '../global.dart' as global;
import 'PackageTypes.dart';

class PackageProcessor {
  List<global.TIDManagement> subscribers = [];

  void packageReceived(BasePackage package) {
    PackageType type = package.getType();
    int size = package.getSize();

    // async file part received
    if (FileManager.isFileType(type)) {
      Timer.run(() => global.fileManager.addFilePart(package as FilePartPackage));
      global.pollManager.packageReceived(package);
      return;
    }

    // alarm received
    if (type == PackageType.ALARM) {
      global.deviceParametersPage.alarmReceived(package);
      global.pollManager.packageReceived(package);
      return;
    }

    // request received
    if (size == BasePackage.minExpectedSize && !package.isAnswer()) {
      _requestReceived(package);
      global.pollManager.packageReceived(package);
      return;
    }

    var tid = global.postManager.getRequestTransactionId(package.getInvId());
    global.postManager.responseReceived(package);

    global.pollManager.packageReceived(package, tid);

    var subscriber = _getSubscriber(tid);
    subscriber?.tits.remove(tid); // TODO: may be remove and implement in subscriber?

    // data received
    if (package.getSize() != BasePackage.minExpectedSize) {
      _unpackPackage(package);

      if (subscriber != null) {
        Timer.run(() => subscriber.dataReceived(tid, package));
      }

      return;
    }

    // acknowledge received
    if (package.isAnswer() && subscriber != null) {
      var dataPackage = subscriber.setRequests[tid];
      if (dataPackage != null) _unpackPackage(dataPackage);

      subscriber.setRequests.remove(tid);
      Timer.run(() => subscriber.acknowledgeReceived(tid, package));
    }
  }

  global.TIDManagement? _getSubscriber(int tid) {
    for (var sb in subscribers) {
      if (sb.isMyTransaction(tid)) {
        return sb;
      }
    }

    return null;
  }

  void fileDownloadStarted(int sender, FilePartPackage filePartPackage) {
    var nd = global.itemsMan.get<NetDevice>(sender);
    if (nd == null) return;

    if (nd.typeName() == CPD.Name()) {
      global.imagePage.clearImage(filePartPackage.getCreationTime());
    } else if (nd.typeName() == CSD.Name()) {
      global.seismicPage.clearSeismic(filePartPackage.getCreationTime());

      if (filePartPackage.getType() == PackageType.SEISMIC_WAVE) {
        global.seismicPage.setADPCMMode(false);
      } else if (filePartPackage.getType() == PackageType.ADPCM_SEISMIC_WAVE) {
        global.seismicPage.setADPCMMode(true);
      }
    }
  }

  void filePartReceived(FilePartPackage fp) {
    var type = fp.getType();

    if (type == PackageType.PHOTO) {
      if (global.imagePage.isImageEmpty) {
        global.imagePage.setImageSize(fp.getFileSize());
      }

      global.imagePage.addImagePart(fp.getPartData());
      global.imagePage.redrawImage();
    } else if (type == PackageType.SEISMIC_WAVE || type == PackageType.ADPCM_SEISMIC_WAVE) {
      global.seismicPage.addSeismicPart(fp.getPartData());
      global.seismicPage.plot();
    }
  }

  void fileDownloaded(int sender) {
    var nd = global.itemsMan.get<NetDevice>(sender);
    if (nd == null) return;

    if (nd.typeName() == CPD.Name()) {
      global.imagePage.lastPartCome();
    } else if (nd.typeName() == CSD.Name()) {
      global.seismicPage.lastPartCome();
      print('Seismic downloaded');
    }
  }

  void messageReceived(FilePartPackage message) {
    print(message.getPartData());
  }

  void _requestReceived(BasePackage request) {
    var nd = global.itemsMan.get<NetDevice>(request.getSender());
    if (nd != null) nd.confirmIsActiveNow();

    //var tid = global.postManager.getRequestTransactionId(request.getInvId());
    //global.pollManager.packageReceived(request, tid); // TODO: uncomment when PollManager implemented

    if (request.getType() == PackageType.GET_TIME) {
      var time = TimePackage();
      time.setType(PackageType.TIME);
      time.setTime(DateTime.now());
      time.setResponseId(request);
      time.setSender(RoutesManager.getLaptopAddress());
      time.setReceiver(request.getSender());

      // Because of problem with determining whether it is request package,
      // or acknowledge for response to request package
      // now we send response only once as if it is acknowledge
      global.postManager.sendPackage(time, PostType.Response, 1);
    }
  }

  void _unpackPackage(BasePackage package) {
    var type = package.getType();
    var partner = package.getPartner();

    var nd = global.itemsMan.get<NetDevice>(partner);
    if (nd == null) return;

    global.pageWithMap.activateMapMarker(nd.id);

    if (package is VersionPackage) {
      nd.firmwareVersion = package.getVersion();
      global.sendingState[partner]?[global.ParametersGroup.firmwareVersion] = global.SendingState.defaultState;
    } else if (package is TimePackage) {
      nd.time = package.getTime();
      global.sendingState[partner]?[global.ParametersGroup.dateTime] = global.SendingState.defaultState;
    } else if (package is AllInformationPackage && nd is RT) {
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
    } else if (package is CoordinatesPackage) {
      nd.setStoredCoordinates(package.getLatitude(), package.getLongitude());
      nd.setCoordinates(nd.storedLatitude, nd.storedLongitude);
      global.sendingState[partner]?[global.ParametersGroup.coordinates] = global.SendingState.defaultState;
    } else if (package is InformationPackage && nd is RT) {
      nd.RSSI = package.getRssi();
      global.sendingState[partner]?[global.ParametersGroup.signalStrength] = global.SendingState.defaultState;
    } else if (package is HopsPackage && (type == PackageType.ALLOWED_HOPS || type == PackageType.SET_ALLOWED_HOPS)) {
      if (nd is RT) {
        nd.allowedHops = package.getHops();
        global.sendingState[partner]?[global.ParametersGroup.allowedHops] = global.SendingState.defaultState;
        global.sendingState[partner]?[global.ParametersGroup.rebroadcastToEveryone] = global.SendingState.defaultState;
      } else if (nd is MCD) {
        var rtMode = RoutesManager.getRtMode(package.getHops());
        nd.priority = rtMode == RtMode.ToAll;
        global.sendingState[partner]?[global.ParametersGroup.priority] = global.SendingState.defaultState;
      }
    } else if (package is HopsPackage && (type == PackageType.UNALLOWED_HOPS || type == PackageType.SET_UNALLOWED_HOPS) && nd is RT) {
      nd.unallowedHops = package.getHops();
      global.sendingState[partner]?[global.ParametersGroup.unallowedHops] = global.SendingState.defaultState;
    } else if (package is ModemFrequencyPackage) {
      nd.modemFrequency = package.getModemFrequency();
      global.sendingState[partner]?[global.ParametersGroup.signalStrength] = global.SendingState.defaultState;
    } else if (package is StatePackage) {
      if (nd is RT) {
        nd.stateMask = package.getStateMask();
        global.sendingState[partner]?[global.ParametersGroup.onOffInDev] = global.SendingState.defaultState;
      } else if (nd is AIRS){
        nd.stateMask = package.getStateMask();
        global.sendingState[partner]?[global.ParametersGroup.onOffInDev] = global.SendingState.defaultState;
      }
    } else if (package is PeripheryMaskPackage) {
      if (nd is RT) {
        nd.peripheryMask = package.getPeripheryMask();
        global.sendingState[partner]?[global.ParametersGroup.deviceStatus] = global.SendingState.defaultState;
      } else if (nd is AIRS) {
        nd.peripheryMask = package.getPeripheryMask();
        global.sendingState[partner]?[global.ParametersGroup.deviceStatus] = global.SendingState.defaultState;
      }
    } else if (package is ExternalPowerPackage) {
      if (nd is RT) {
        nd.extPower = package.getExternalPowerState();
        global.sendingState[partner]?[global.ParametersGroup.switchingBreak] = global.SendingState.defaultState;
      } else if (nd is MCD) {
        nd.GPSState = package.getExternalPowerState() == ExternalPower.ON;
        global.sendingState[partner]?[global.ParametersGroup.gps] = global.SendingState.defaultState;
      }
    } else if (package is BatteryMonitorPackage) {
      if (nd is RT) {
        nd.setBatMonParameters(package.getResidue(), package.getUsedCapacity(), package.getVoltage(), package.getCurrent(),
            package.getTemperature(), package.getElapsedTime());
        global.sendingState[partner]?[global.ParametersGroup.powerSupply] = global.SendingState.defaultState;
      } else if (nd is MCD) {
        nd.setBatMonParameters(package.getVoltage(), package.getTemperature());
        global.sendingState[partner]?[global.ParametersGroup.powerSupply] = global.SendingState.defaultState;
      } else if (nd is AIRS){
        nd.batMonVoltage = package.getVoltage();
        global.sendingState[partner]?[global.ParametersGroup.powerSupply] = global.SendingState.defaultState;
      }
    }
    // TODO: add Battery state
    else if (package is BatteryStatePackage && nd is RT) {
      var isWeakBattery = package.getBatteryState() == BatteryState.BAD;

      if (isWeakBattery && !nd.weakBattery) {
        //AlarmWeakBattery(nd.id());
      } else if (!isWeakBattery && nd.weakBattery) {
        //DeviceSettingsEvent(nd.id(), BatteryChanged);
      }
      nd.weakBattery = isWeakBattery;
      //deviceBatteryStateChanged(rt.id(), isWeakBattery);
    } else if (package is AlarmReasonMaskPackage && nd is CSD) {
      nd.alarmReasonMask = package.getAlarmReasonMask();
      global.sendingState[partner]?[global.ParametersGroup.humanTransport] = global.SendingState.defaultState;
    } else if (package is SeismicSignalSwingPackage && nd is CSD) {
      nd.signalSwing = package.getSignalSwing();
      global.sendingState[partner]?[global.ParametersGroup.ratioSign] = global.SendingState.defaultState;
    } else if (package is HumanSensitivityPackage) {
      if (nd is CSD) {
        nd.humanSensitivity = package.getHumanSensitivity();
        global.sendingState[partner]?[global.ParametersGroup.humSens] = global.SendingState.defaultState;
      } else if (nd is AIRS) {
        nd.sensitivity = package.getHumanSensitivity();
        global.sendingState[partner]?[global.ParametersGroup.tresholdIRS] = global.SendingState.defaultState;
      }
    } else if (package is HumanFreqThresholdPackage && nd is CSD) {
      nd.humanFreqThreshold = package.getHumanFreqThresholdPackage();
    } else if (package is TransportSensitivityPackage && nd is CSD) {
      nd.transportSensitivity = package.getTransportSensitivity();
      global.sendingState[partner]?[global.ParametersGroup.autoSens] = global.SendingState.defaultState;
    } else if (package is CriterionFilterPackage && nd is CSD) {
      nd.criterionFilter = package.getCriterionFilter();
      global.sendingState[partner]?[global.ParametersGroup.critFilter] = global.SendingState.defaultState;
    } else if (package is SignalToNoiseRatioPackage && nd is CSD) {
      nd.snr = package.getSignalToNoiseRatio();
      global.sendingState[partner]?[global.ParametersGroup.snr] = global.SendingState.defaultState;
    } else if (package is CriterionRecognitionPackage && nd is CSD) {
      nd.recognitionParameters = package.getCriteria();
      global.sendingState[partner]?[global.ParametersGroup.recogParam] = global.SendingState.defaultState;
    } else if (package is PhotoParametersPackage && nd is CPD) {
      nd.setCameraParameters(package.getInvLightSensitivity(), package.getCompress());
      global.sendingState[partner]?[global.ParametersGroup.cameraSettings] = global.SendingState.defaultState;
    } else if (package is PhototrapPackage && nd is CPD) {
      nd.targetSensor = package.getCrossDevicesList().first;
    } else if (package is EEPROMFactorsPackage && nd is RT) {
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
      global.sendingState[partner]?[global.ParametersGroup.alarmFilter] = global.SendingState.defaultState;
    } else if (package is PhototrapFilesPackage && nd is CPD) {
      nd.phototrapFiles = package.getPhototrapFiles();
    } else if (package is ExternalPowerSafetyCatchPackage && nd is RT) {
      nd.extPowerSafetyCatchState = package.getSafetyCatchState();
      global.sendingState[partner]?[global.ParametersGroup.safetyCatch] = global.SendingState.defaultState;
    } else if (package is AutoExternalPowerPackage && nd is RT) {
      nd.autoExtPowerActivationDelaySec = package.getActivationDelay();
      nd.extPowerImpulseDurationSec = package.getImpulseDuration();
      nd.autoExtPowerState = package.getAutoExternalPowerModeState();
      global.sendingState[partner]?[global.ParametersGroup.switchingBreak] = global.SendingState.defaultState;
    }
  }

  void ranOutOfSendAttempts(BasePackage? pb, int transactionId) {
    //global.globalMapMarker[id].markerData.deviceAvailable = false;
    if (pb == null) return;
    var type = pb.getType();
    var partner = pb.getPartner();

    var nd = global.itemsMan.get<NetDevice>(partner);
    if (nd == null) return;

    if (pb is VersionPackage || type == PackageType.GET_VERSION) {
      global.sendingState[partner]?[global.ParametersGroup.firmwareVersion] = global.SendingState.notAnswerState;
    } else if (pb is TimePackage || type == PackageType.GET_TIME) {
      global.sendingState[partner]?[global.ParametersGroup.dateTime] = global.SendingState.notAnswerState;
    } else if (pb is CoordinatesPackage || type == PackageType.GET_COORDINATE) {
      global.sendingState[partner]?[global.ParametersGroup.coordinates] = global.SendingState.notAnswerState;
    } else if (pb is InformationPackage && nd is RT || type == PackageType.GET_INFORMATION) {
      global.sendingState[partner]?[global.ParametersGroup.signalStrength] = global.SendingState.notAnswerState;
    } else if (pb is HopsPackage &&
        (type == PackageType.ALLOWED_HOPS || type == PackageType.SET_ALLOWED_HOPS || type == PackageType.GET_ALLOWED_HOPS)) {
      if (nd is RT) {
        global.sendingState[partner]?[global.ParametersGroup.allowedHops] = global.SendingState.notAnswerState;
      } else if (nd is MCD) {
        global.sendingState[partner]?[global.ParametersGroup.priority] = global.SendingState.notAnswerState;
      }
    } else if (pb is HopsPackage && (type == PackageType.UNALLOWED_HOPS || type == PackageType.SET_UNALLOWED_HOPS) && nd is RT) {
      global.sendingState[partner]?[global.ParametersGroup.unallowedHops] = global.SendingState.notAnswerState;
    } else if (pb is ModemFrequencyPackage || type == PackageType.GET_MODEM_FREQUENCY) {
      global.sendingState[partner]?[global.ParametersGroup.signalStrength] = global.SendingState.notAnswerState;
    } else if (pb is StatePackage || type == PackageType.GET_STATE) {
      global.sendingState[partner]?[global.ParametersGroup.onOffInDev] = global.SendingState.notAnswerState;
    } else if (pb is PeripheryMaskPackage || type == PackageType.GET_PERIPHERY) {
      global.sendingState[partner]?[global.ParametersGroup.deviceStatus] = global.SendingState.notAnswerState;
    } else if (pb is ExternalPowerPackage || type == PackageType.GET_EXTERNAL_POWER) {
      if (nd is RT) {
        global.sendingState[partner]?[global.ParametersGroup.switchingBreak] = global.SendingState.notAnswerState;
      } else if (nd is MCD) {
        global.sendingState[partner]?[global.ParametersGroup.gps] = global.SendingState.notAnswerState;
      }
    } else if (pb is BatteryMonitorPackage || type == PackageType.GET_BATTERY_MONITOR) {
      global.sendingState[partner]?[global.ParametersGroup.powerSupply] = global.SendingState.notAnswerState;
    }
    // TODO: add Battery state
    else if (pb is AlarmReasonMaskPackage && nd is CSD || type == PackageType.GET_ALARM_REASON_MASK) {
      global.sendingState[partner]?[global.ParametersGroup.humanTransport] = global.SendingState.notAnswerState;
    } else if (pb is SeismicSignalSwingPackage && nd is CSD || type == PackageType.GET_SIGNAL_SWING) {
      global.sendingState[partner]?[global.ParametersGroup.ratioSign] = global.SendingState.notAnswerState;
    } else if (pb is HumanSensitivityPackage && nd is CSD || type == PackageType.GET_HUMAN_SENSITIVITY) {
      global.sendingState[partner]?[global.ParametersGroup.humSens] = global.SendingState.notAnswerState;
    } else if (pb is HumanSensitivityPackage && nd is AIRS || type == PackageType.GET_HUMAN_SENSITIVITY) {
      global.sendingState[partner]?[global.ParametersGroup.tresholdIRS] = global.SendingState.notAnswerState;
    } else if (pb is TransportSensitivityPackage && nd is CSD || type == PackageType.GET_TRANSPORT_SENSITIVITY) {
      global.sendingState[partner]?[global.ParametersGroup.autoSens] = global.SendingState.notAnswerState;
    } else if (pb is CriterionFilterPackage && nd is CSD || type == PackageType.GET_CRITERION_FILTER) {
      global.sendingState[partner]?[global.ParametersGroup.critFilter] = global.SendingState.notAnswerState;
    } else if (pb is SignalToNoiseRatioPackage && nd is CSD || type == PackageType.GET_SIGNAL_TO_NOISE_RATIO) {
      global.sendingState[partner]?[global.ParametersGroup.snr] = global.SendingState.notAnswerState;
    } else if (pb is CriterionRecognitionPackage && nd is CSD || type == PackageType.GET_CRITERION_RECOGNITION) {
      global.sendingState[partner]?[global.ParametersGroup.recogParam] = global.SendingState.notAnswerState;
    } else if (pb is PhotoParametersPackage && nd is CPD || type == PackageType.GET_PHOTO_PARAMETERS) {
      global.sendingState[partner]?[global.ParametersGroup.cameraSettings] = global.SendingState.notAnswerState;
    } else if (pb is EEPROMFactorsPackage && nd is RT || type == PackageType.GET_EEPROM_FACTORS) {
      global.sendingState[partner]?[global.ParametersGroup.alarmFilter] = global.SendingState.notAnswerState;
    } else if (pb is ExternalPowerSafetyCatchPackage && nd is RT || type == PackageType.GET_SAFETY_CATCH) {
      global.sendingState[partner]?[global.ParametersGroup.safetyCatch] = global.SendingState.notAnswerState;
    } else if (pb is AutoExternalPowerPackage && nd is RT || type == PackageType.GET_AUTO_EXT_POWER) {
      global.sendingState[partner]?[global.ParametersGroup.switchingBreak] = global.SendingState.notAnswerState;
    } else if (pb is ExternalPowerPackage && nd is RT || type == PackageType.GET_EXTERNAL_POWER) {
      global.sendingState[partner]?[global.ParametersGroup.power] = global.SendingState.notAnswerState;
    }
    global.pollManager.packageNotSent(pb, transactionId);
    global.deviceParametersPage.ranOutOfSendAttempts(transactionId, pb);
  }

  void packageSendingAttempt(PackageSendingStatus sendingStatus) {
    global.statusBarString = ("#${sendingStatus.transactionId}: ${sendingStatus.attemptNumber}/"
        "${sendingStatus.totalAttemptNumber} -> #${sendingStatus.receiver}");
    timerClearStatusBar();
  }

  void timerClearStatusBar() {
    if (global.timer != null) {
      global.timer!.cancel();
      global.timer = Timer(const Duration(seconds: 5), () {
        global.statusBarString = " ";
      });
    } else {
      global.timer = Timer(const Duration(seconds: 5), () {
        global.statusBarString = " ";
      });
    }
  }
}
