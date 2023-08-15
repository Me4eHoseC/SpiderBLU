import 'package:flutter/physics.dart';

import '../NetPackagesDataTypes.dart';
import 'Marker.dart';

class Device extends Marker {
  ObjState objState = ObjState.Offline;
  DateTime? wasActiveDateTime;

  bool get isOnline => (objState != ObjState.Offline);

  void confirmISActiveNow() {
    wasActiveDateTime = DateTime.now();
  }

  bool wasActiveDuringMs(int interval) {
    if (wasActiveDateTime == null) return false;

    var diffMs = DateTime.now().millisecondsSinceEpoch -
        wasActiveDateTime!.millisecondsSinceEpoch;

    return diffMs < interval;
  }

  DeviceType type = DeviceType.CSD;
  int timeS = 0;
  int firmwareVersion = 0;

  double storedLatitude = 0;
  double storedLongitude = 0;

  int rssi = 0;
  List<int> allowedHops = [];
  List<int> unallowedHops = [];

  int peripheryMask = 0;
  int stateMask = 0;

  bool extPowerSafetyCatchState = false;
  int autoExtPowerActivationDelaySec = 60;
  int extPowerImpulseDurationSec = 1;
  bool autoExtPowerState = false;

  ExternalPower extPower = ExternalPower.OFF;

  bool weakBatteryFlag = false;

  double batMonResidue = 0;
  double batMonUsedCapacity = 0;
  double batMonVoltage = 0;
  double batMonCurrentMA = 0;
  double batMonTemperature = 0;
  double batMonElapsedTime = 0;

  bool get isWeakBattery => weakBatteryFlag;

  // Camera parameters
  int cameraSensitivity = 140;
  PhotoImageCompression cameraCompression = PhotoImageCompression.HIGH;
  int targetSensor = 0;

  List<DateTime> phototrapFiles = [];

  bool isPhotoBlackAndWhite = false;

  // Seismic parameters
  int alarmReasonMask = 0;
  int humanSensitivity = 0;
  int transportSensitivity = 0;
  CriterionFilter criterionFilter = CriterionFilter.FILTER_1_FROM_3;
  int snr = 0;
  List<int> recognitionParameters = [];

  double signalSwing = 0;

  bool eepromInitialized = false; // zero EEPROM write protection

  // EEPROM factors
  int wake_network_resend_time_ms = 0;
  int alarm_resend_time_ms = 0;
  int seismic_resend_time_ms = 0;
  int transportSignalsTreshold = 0;
  int photo_resend_time_ms = 0;

  int transportIntervalsCount = 0;
  int alarm_tries_resend = 0;
  int seismic_tries_resend = 0;
  int humanSignalsTreshold = 0;
  int photo_tries_resend = 0;

  int  periodic_send_telemetry_time_10s = 0;
  int  after_seismic_alarm_pause_s = 0;
  int  after_line_alarm_pause_s = 0;
  int  humanIntervalsCount = 0;

  // Battery section
  int  battery_periodic_update_10min = 0;
  int  battery_voltage_threshold_alarm_100mV = 0;
  int  battery_residue_threshold_alarm_pc = 0;
  int  battery_periodic_alarm_h = 0;

  SlaveModel device_type = SlaveModel.SENSOR;

  bool get isEEPROMInitialized => eepromInitialized;

  bool seriesHumanFilterState = false;
  int seriesHumanFilterTreshold = 0;
  DateTime lastHumanAlarmDateTime = DateTime.now();
  int currentSeriesHumanIteration = 0;

  bool seriesTransportFilterState = false;
  int seriesTransportFilterTreshold = 0;
  DateTime lastTransportAlarmDateTime = DateTime.now();
  int currentSeriesTransportIteration = 0;

  bool isSeismicAlarmsMuted = false;
  bool isFirstSeismicAlarmMuted = false;

  bool doPostAlarmPollFlag = false;

}

enum DeviceType {
  STD,
  CSD,
  CPD,
  RT;
}

enum ObjState {
  Offline,
  Online,
  SeismicAlarm,
  BreaklineAlarm,
  LowBatteryAlarm,
  PhototrapAlarm,
  RadiationAlarm,

  ExternalPowerSafetyCatchOff,
  AutoExternalPowerTriggered;

/*WarningState = 1000,
WarningHumanState = 1001,
WarningTransportState = 1002,
WarningLFOState = 1003,
WarningBreaklineState = 1004,
WarningPhototrapState = 1005,
WarningRadiationState = 1006;*/
}
