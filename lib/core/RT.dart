import 'package:projects/core/NetDevice.dart';
import 'package:projects/core/Marker.dart';

import '../NetPackagesDataTypes.dart';

class RT extends NetDevice {
  int _rssi = 0;

  List<int> _allowedHops = [0];
  List<int> _unallowedHops = [0];
  int _peripheryMask = 0;
  int _stateMask = 0;

  bool _extPowerSafetyCatchState = false;
  int _autoExtPowerActivationDelaySec = 60;
  int _extPowerImpulseDurationSec = 1;
  bool _autoExtPowerState = false;

  ExternalPower _extPower = ExternalPower.OFF;

  bool _weakBatteryFlag = false;

  double _batMonResidue = 0;
  double _batMonUsedCapacity = 0;
  double _batMonVoltage = 0;
  double _batMonCurrent_mA = 0;
  double _batMonTemperature = 0;
  double _batMonElapsedTime = 0;

  bool _eepromInitialized = false; // zero EEPROM write protection

  // EEPROM factors
  int _wakeNetworkResendTimeMs = 0;
  int _alarmResendTimeMs = 0;
  int _seismicResendTimeMs = 0;

  int _transportSignalsTreshold = 0; // одиночные транспорт
  int _photoResendTimeMs = 0;
  int _transportIntervalsCount = 0; // серийные транспорт
  int _alarmTriesResend = 0;
  int _seismicTriesResend = 0;

  int _humanSignalsTreshold = 0; // одиночные человек
  int _photoTriesResend = 0;
  int _periodicSendTelemetryTime10s = 0;
  int _afterSeismicAlarmPauseS = 0;
  int _afterLineAlarmPauseS = 0;
  int _humanIntervalsCount = 0; // серийные человек

  // Battery section
  int _batteryPeriodicUpdate10min = 0;
  int _batteryVoltageThresholdAlarm100mV = 0;
  int _batteryPeriodicAlarmH = 0;
  int _batteryResidueThresholdAlarmPC = 0;

  SlaveModel _deviceType = SlaveModel.SENSOR;

  @override
  void copyFrom(Marker other) {
    super.copyFrom(other);
    if (other is! RT) {
      return;
    }
    _rssi = other._rssi;
    _allowedHops = other._allowedHops;
    _unallowedHops = other._unallowedHops;

    _peripheryMask = other._peripheryMask;
    _stateMask = other._stateMask;

    _extPowerSafetyCatchState = other._extPowerSafetyCatchState;
    _autoExtPowerActivationDelaySec = other._autoExtPowerActivationDelaySec;
    _extPowerImpulseDurationSec = other._extPowerImpulseDurationSec;
    _autoExtPowerState = other._autoExtPowerState;

    _extPower = other._extPower;

    _weakBatteryFlag = other._weakBatteryFlag;

    _batMonResidue = other._batMonResidue;
    _batMonUsedCapacity = other._batMonUsedCapacity;
    _batMonVoltage = other._batMonVoltage;
    _batMonCurrent_mA = other._batMonCurrent_mA;
    _batMonTemperature = other._batMonTemperature;
    _batMonElapsedTime = other._batMonElapsedTime;

    _eepromInitialized = other._eepromInitialized;

    //EEPROM factors
    _wakeNetworkResendTimeMs = other._wakeNetworkResendTimeMs;
    _alarmResendTimeMs = other._alarmResendTimeMs;
    _seismicResendTimeMs = other._seismicResendTimeMs;
    _transportSignalsTreshold = other._transportSignalsTreshold;
    _photoResendTimeMs = other._photoResendTimeMs;

    _transportIntervalsCount = other._transportIntervalsCount;
    _alarmTriesResend = other._alarmTriesResend;
    _seismicTriesResend = other._seismicTriesResend;
    _humanSignalsTreshold = other._humanSignalsTreshold;
    _photoTriesResend = other._photoTriesResend;

    _periodicSendTelemetryTime10s = other._periodicSendTelemetryTime10s;
    _afterSeismicAlarmPauseS = other._afterSeismicAlarmPauseS;
    _afterLineAlarmPauseS = other._afterLineAlarmPauseS;
    _humanIntervalsCount = other._humanIntervalsCount;

    // Battery section
    _batteryPeriodicUpdate10min = other._batteryPeriodicUpdate10min;
    _batteryVoltageThresholdAlarm100mV = other._batteryVoltageThresholdAlarm100mV;
    _batteryResidueThresholdAlarmPC = other._batteryResidueThresholdAlarmPC;
    _batteryPeriodicAlarmH = other._batteryPeriodicAlarmH;

    _deviceType = other._deviceType;
  }

  @override
  Marker clone() {
    var marker = RT();
    marker.copyFrom(this);
    return marker;
  }

  static String Name([bool isTr = false]) {
    return isTr ? "RT" : "RT";
  }

  @override
  String typeName([bool isTr = false]) {
    return RT.Name(isTr);
  }

  int get RSSI => _rssi;
  set RSSI(int rssi) => _rssi = rssi;

  List<int> get allowedHops => _allowedHops;
  set allowedHops(List<int> hops) => _allowedHops = hops;

  List<int> get unallowedHops => _unallowedHops;
  set unallowedHops(List<int> hops) => _unallowedHops = hops;

  int get peripheryMask => _peripheryMask;
  set peripheryMask(int peripheryMask) => _peripheryMask = peripheryMask;

  int get stateMask => _stateMask;
  set stateMask(int stateMask) => _stateMask = stateMask;

  ExternalPower get extPower => _extPower;
  set extPower(ExternalPower extPower) => _extPower = extPower;

  double get batMonResidue => _batMonResidue;
  double get batMonUsedCapacity => _batMonUsedCapacity;
  double get batMonVoltage => _batMonVoltage;
  double get batMonCurrentmA => _batMonCurrent_mA;
  double get batMonTemperature => _batMonTemperature;
  double get batMonElapsedTime => _batMonElapsedTime;

  set batMonVoltage(double voltage) => _batMonVoltage = voltage;

  void setBatMonParameters(
      double batMonResidue, batMonUsedCapacity, batMonVoltage, batMonCurrent_mA, batMonTemperature, batMonElapsedTime) {
    _batMonResidue = batMonResidue;
    _batMonUsedCapacity = batMonUsedCapacity;
    _batMonVoltage = batMonVoltage;
    _batMonCurrent_mA = batMonCurrent_mA;
    _batMonTemperature = batMonTemperature;
    _batMonElapsedTime = batMonElapsedTime;
  }

  bool get EEPROMInitialized => _eepromInitialized;
  set EEPROMInitialized(bool isInitialized) => _eepromInitialized = isInitialized;

  int get wakeNetworkResendTimeMs => _wakeNetworkResendTimeMs;
  set wakeNetworkResendTimeMs(int newWakeNetworkResendTimeMs) => _wakeNetworkResendTimeMs = newWakeNetworkResendTimeMs;

  int get alarmResendTimeMs => _alarmResendTimeMs;
  set alarmResendTimeMs(int newAlarmResendTimeMs) => _alarmResendTimeMs = newAlarmResendTimeMs;

  int get seismicResendTimeMs => _seismicResendTimeMs;
  set seismicResendTimeMs(int newSeismicResendTimeMs) => _seismicResendTimeMs = newSeismicResendTimeMs;

  int get transportSignalsTreshold => _transportSignalsTreshold;
  set transportSignalsTreshold(int newTransportSignalsTreshold) => _transportSignalsTreshold = newTransportSignalsTreshold;

  int get photoResendTimeMs => _photoResendTimeMs;
  set photoResendTimeMs(int newPhotoResendTimeMs) => _photoResendTimeMs = newPhotoResendTimeMs;

  int get transportIntervalsCount => _transportIntervalsCount;
  set transportIntervalsCount(int newTransportIntervalsCount) => _transportIntervalsCount = newTransportIntervalsCount;

  int get alarmTriesResend => _alarmTriesResend;
  set alarmTriesResend(int newAlarmTriesResend) => _alarmTriesResend = newAlarmTriesResend;

  int get seismicTriesResend => _seismicTriesResend;
  set seismicTriesResend(int newSeismicTriesResend) => _seismicTriesResend = newSeismicTriesResend;

  int get humanSignalsTreshold => _humanSignalsTreshold;
  set humanSignalsTreshold(int newHumanSignalsTreshold) => _humanSignalsTreshold = newHumanSignalsTreshold;

  int get photoTriesResend => _photoTriesResend;
  set photoTriesResend(int newPhotoTriesResend) => _photoTriesResend = newPhotoTriesResend;

  int get periodicSendTelemetryTime10s => _periodicSendTelemetryTime10s;
  set periodicSendTelemetryTime10s(int newPeriodicSendTelemetryTime10s) =>
      _periodicSendTelemetryTime10s = newPeriodicSendTelemetryTime10s;

  int get afterSeismicAlarmPauseS => _afterSeismicAlarmPauseS;
  set afterSeismicAlarmPauseS(int newAfterSeismicAlarmPauseS) => _afterSeismicAlarmPauseS = newAfterSeismicAlarmPauseS;

  int get afterLineAlarmPauseS => _afterLineAlarmPauseS;
  set afterLineAlarmPauseS(int newAfterLineAlarmPauseS) => _afterLineAlarmPauseS = newAfterLineAlarmPauseS;

  int get humanIntervalsCount => _humanIntervalsCount;
  set humanIntervalsCount(int newHumanIntervalsCount) => _humanIntervalsCount = newHumanIntervalsCount;

  int get batteryPeriodicUpdate10min => _batteryPeriodicUpdate10min;
  set batteryPeriodicUpdate10min(int newBatteryPeriodicUpdate10min) => _batteryPeriodicUpdate10min = newBatteryPeriodicUpdate10min;

  int get batteryVoltageThresholdAlarm100mV => _batteryVoltageThresholdAlarm100mV;
  set batteryVoltageThresholdAlarm100mV(int newBatteryVoltageThresholdAlarm100mV) =>
      _batteryVoltageThresholdAlarm100mV = newBatteryVoltageThresholdAlarm100mV;

  int get batteryResidueThresholdAlarmPC => _batteryResidueThresholdAlarmPC;
  set batteryResidueThresholdAlarmPC(int newBatteryResidueThresholdAlarmPC) =>
      _batteryResidueThresholdAlarmPC = newBatteryResidueThresholdAlarmPC;

  int get batteryPeriodicAlarmH => _batteryPeriodicAlarmH;
  set batteryPeriodicAlarmH(int newBatteryPeriodicAlarmH) => _batteryPeriodicAlarmH = newBatteryPeriodicAlarmH;

  SlaveModel get deviceType => _deviceType;
  set deviceType(SlaveModel newDeviceType) => _deviceType = newDeviceType;

  bool get weakBattery => _weakBatteryFlag;
  set weakBattery(bool weakBattery) => _weakBatteryFlag = weakBattery;

  bool get extPowerSafetyCatchState => _extPowerSafetyCatchState;
  set extPowerSafetyCatchState(bool catchState) => _extPowerSafetyCatchState = catchState;

  int get autoExtPowerActivationDelaySec => _autoExtPowerActivationDelaySec;
  set autoExtPowerActivationDelaySec(int delaySec) => _autoExtPowerActivationDelaySec = delaySec;

  int get extPowerImpulseDurationSec => _extPowerImpulseDurationSec;
  set extPowerImpulseDurationSec(int perAlarmH) => _extPowerImpulseDurationSec = perAlarmH;

  bool get autoExtPowerState => _autoExtPowerState;
  set autoExtPowerState(bool powerState) => _autoExtPowerState = powerState;
}

class STD extends RT {
  @override
  void copyFrom(Marker other) {
    super.copyFrom(other);
  }

  @override
  Marker clone() {
    var marker = STD();
    marker.copyFrom(this);
    return marker;
  }

  static String Name([bool isTr = false]) {
    return isTr ? "STD" : "STD";
  }

  @override
  String typeName([bool isTr = false]) {
    return STD.Name(isTr);
  }
}
