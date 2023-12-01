import 'dart:typed_data';

import 'package:projects/BasePackage.dart';
import 'package:projects/AllEnum.dart';
import 'package:projects/core/Device.dart';

import 'NetCommonFunctions.dart';
import 'NetPackagesDataTypes.dart';

class InformationPackage extends BasePackage {
  int _battery = 0, _rssi = 0;
  ObjState _state = ObjState.Offline;

  InformationPackage() {
    setType(PackageType.INFORMATION);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is InformationPackage) {
      _state = other._state;
      _battery = other._battery;
      _rssi = other._rssi;
    }
  }

  ObjState getState() {
    return _state;
  }

  double getBattery() {
    return _battery * 0.1;
  }

  int getRssi() {
    return _rssi;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var valueState = unpackMan.unpack<int>(1);
    var valueBattery = unpackMan.unpack<int>(1);
    var valueRssi = unpackMan.unpack<int>(1);
    success &= (valueState != null);
    success &= (valueBattery != null);
    success &= (valueRssi != null);
    if (success) {
      _state = ObjState.values[valueState!];
      _battery = valueBattery!;
      _rssi = valueRssi!;
    }
    return success;
  }
}

class AllInformationPackage extends BasePackage {
  DateTime? _time, _alarmTime;
  double _latitude = 0, _longitude = 0;
  int _alarmType = 0, _alarmReason = 0, _state = 0, _battery = 0;

  AllInformationPackage() {
    setType(PackageType.ALL_INFORMATION);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is AllInformationPackage) {
      _time = other._time;
      _alarmTime = other._alarmTime;
      _latitude = other._latitude;
      _longitude = other._longitude;
      _alarmType = other._alarmType;
      _alarmReason = other._alarmReason;
      _state = other._state;
      _battery = other._battery;
    }
  }

  DateTime getTime() {
    return _time!;
  }

  double getLatitude() {
    return _latitude;
  }

  double getLongitude() {
    return _longitude;
  }

  DateTime getLastAlarmTime() {
    return _alarmTime!;
  }

  AlarmType getLastAlarmType() {
    return AlarmType.values[_alarmType];
  }

  AlarmReason getLastAlarmReason() {
    return AlarmReason.values[_alarmReason];
  }

  int getStateMask() {
    return _state;
  }

  double getBattery() {
    return _battery * 0.1;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var valueTime = unpackMan.unpack<DateTime>(4);
    var valueLat = unpackMan.unpack<double>(4);
    var valueLong = unpackMan.unpack<double>(4);
    var valueAlarmTime = unpackMan.unpack<DateTime>(4);
    var valueAlarmType = unpackMan.unpack<int>(1);
    var valueAlarmReason = unpackMan.unpack<int>(1);
    var valueState = unpackMan.unpack<int>(1);
    var valueBattery = unpackMan.unpack<int>(1);

    success &= (valueTime != null);
    if (success) _time = valueTime!;

    success &= (valueLat != null);
    if (success) _latitude = valueLat!;

    success &= (valueLong != null);
    if (success) _longitude = valueLong!;

    success &= (valueAlarmTime != null);
    if (success) _alarmTime = valueAlarmTime!;

    success &= (valueAlarmType != null);
    if (success) _alarmType = valueAlarmType!;

    success &= (valueAlarmReason != null);
    if (success) _alarmReason = valueAlarmReason!;

    success &= (valueState != null);
    if (success) _state = valueState!;

    success &= (valueBattery != null);
    if (success) _battery = valueBattery!;

    return success;
  }
}

class StatePackage extends BasePackage {
  int _state = 0;

  StatePackage() {
    setType(PackageType.SET_STATE);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is StatePackage) {
      _state = other._state;
    }
  }

  int getStateMask() {
    return _state;
  }

  void setStateMask(int mask) {
    _state = mask;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(1);
    success &= (value != null);
    if (success) _state = value!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();
    success &= super.packHeader(packMan);
    success &= packMan.pack(_state, 1);
    if (!success) return Uint8List(0);
    var rawData = packMan.getRawData();
    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class ErrorCodePackage extends BasePackage {
  int _errorCode = 0;

  ErrorCodePackage() {
    setType(PackageType.ERROR_STAT);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is ErrorCodePackage) {
      _errorCode = other._errorCode;
    }
  }

  ErrorCodes getErrorCode() {
    return ErrorCodes.values[_errorCode];
  }

  void setErrorCode(ErrorCodes mask) {
    _errorCode = mask.index;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(2);
    success &= (value != null);
    if (success) _errorCode = value!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();
    success &= super.packHeader(packMan);
    success &= packMan.pack(_errorCode, 2);
    if (!success) return Uint8List(0);
    var rawData = packMan.getRawData();
    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class AlarmPackage extends BasePackage {
  DateTime? _alarmTime;
  int _alarmType = 0, _alarmReason = 0, _number = 0;

  AlarmPackage() {
    setType(PackageType.ALARM);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is AlarmPackage) {
      _alarmTime = other._alarmTime;
      _alarmType = other._alarmType;
      _alarmReason = other._alarmReason;
      _number = other._number; 
    }
  }

  DateTime getAlarmTime() {
    return _alarmTime!;
  }

  AlarmType getAlarmType() {
    return AlarmType.values[_alarmType];
  }

  AlarmReason getAlarmReason() {
    return AlarmReason.values[_alarmReason];
  }

  int getAlarmNumber() {
    return _number;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var valueAlarmTime = unpackMan.unpack<DateTime>(4);
    var valueAlarmType = unpackMan.unpack<int>(1);
    var valueAlarmReason = unpackMan.unpack<int>(1);
    var valueAlarmNumber = unpackMan.unpack<int>(1);

    success &= (valueAlarmTime != null);
    if (success) _alarmTime = valueAlarmTime!;

    success &= (valueAlarmType != null);
    if (success) _alarmType = valueAlarmType!;

    success &= (valueAlarmReason != null);
    if (success) _alarmReason = valueAlarmReason!;

    success &= (valueAlarmNumber != null);
    if (success) _number = valueAlarmNumber!;

    return success;
  }
}

class AlarmReasonMaskPackage extends BasePackage {
  int _mask = 0;

  AlarmReasonMaskPackage() {
    setType(PackageType.SET_ALARM_REASON_MASK);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is AlarmReasonMaskPackage) {
      _mask = other._mask;
    }
  }

  int getAlarmReasonMask() {
    return _mask;
  }

  void setAlarmReasonMask(int value) {
    _mask = value;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(1);

    success &= (value != null);
    if (success) _mask = value!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();
    success &= super.packHeader(packMan);
    success &= packMan.pack(_mask, 1);
    if (!success) return Uint8List(0);
    var rawData = packMan.getRawData();
    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class CoordinatesPackage extends BasePackage {
  double _latitude = 0, _longitude = 0;

  CoordinatesPackage() {
    setType(PackageType.SET_COORDINATE);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is CoordinatesPackage) {
      _latitude = other._latitude;
      _longitude = other._longitude;
    }
  }

  double getLatitude() {
    return _latitude;
  }

  void setLatitude(double value) {
    _latitude = value;
  }

  double getLongitude() {
    return _longitude;
  }

  void setLongitude(double value) {
    _longitude = value;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var valueLatitude = unpackMan.unpack<double>(4);
    var valueLongitude = unpackMan.unpack<double>(4);

    success &= (valueLatitude != null);
    if (success) _latitude = valueLatitude!;

    success &= (valueLongitude != null);
    if (success) _longitude = valueLongitude!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();
    success &= super.packHeader(packMan);
    success &= packMan.pack(_latitude, 4);
    success &= packMan.pack(_longitude, 4);
    if (!success) return Uint8List(0);
    var rawData = packMan.getRawData();
    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class TimePackage extends BasePackage {
  DateTime? _time;
  bool _autoUpdate = true;

  TimePackage() {
    setType(PackageType.SET_TIME);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is TimePackage) {
      _time = other._time;
      _autoUpdate = other._autoUpdate;
    }
  }

  void set_autoUpdate(bool do_autoUpdate) {
    _autoUpdate = do_autoUpdate;
  }

  DateTime getTime() {
    return _time!;
  }

  void setTime(DateTime dateTime) {
    _time = dateTime;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<DateTime>(4);
    success &= (value != null);
    if (success) _time = value!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    if (getType() == PackageType.SET_TIME && _autoUpdate) {
      setTime(DateTime.now());
    }

    bool success = true;
    PackMan packMan = PackMan();
    success &= super.packHeader(packMan);
    success &= packMan.pack(_time);
    if (!success) return Uint8List(0);
    var rawData = packMan.getRawData();
    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class VersionPackage extends BasePackage {
  int _version = 0;

  VersionPackage() {
    setType(PackageType.VERSION);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is VersionPackage) {
      _version = other._version;
    }
  }

  int getVersion() {
    return _version;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(4);
    success &= (value != null);
    if (success) _version = value!;

    return success;
  }
}

class ExternalPowerSafetyCatchPackage extends BasePackage {
  int _state = 1;

  ExternalPowerSafetyCatchPackage() {
    setType(PackageType.SET_SAFETY_CATCH);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is ExternalPowerSafetyCatchPackage) {
      _state = other._state;
    }
  }

  void setSafetyCatchState(bool isOn) {
    _state = isOn ? 1 : 0;
  }

  bool getSafetyCatchState() {
    return _state == 1;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(2);
    success &= (value != null);
    if (success) _state = value!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();
    success &= super.packHeader(packMan);
    success &= packMan.pack(_state, 2);
    if (!success) return Uint8List(0);
    var rawData = packMan.getRawData();
    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class AutoExternalPowerPackage extends BasePackage {
  int _activation_delay_s = 60; // seconds
  int _impulse_duration_s = 1; // 0 - unlimited
  int _aep_state = 0; // 0 – auto mode off, 1 – auto mode on
  int _reserve = 0; // unused for now

  AutoExternalPowerPackage() {
    setType(PackageType.SET_AUTO_EXT_POWER);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is AutoExternalPowerPackage) {
      _activation_delay_s = other._activation_delay_s;
      _impulse_duration_s = other._impulse_duration_s;
      _aep_state = other._aep_state;
      _reserve = other._reserve;
    }
  }

  /// Returns device auto external power mode activation delay (seconds)
  int getActivationDelay() { return _activation_delay_s; }

  /// Sets device auto external power mode activation delay (seconds)
  void setActivationDelay(int delayS) { _activation_delay_s = delayS; }

  /// Returns device external power impulse duration (seconds)
  int getImpulseDuration() { return _impulse_duration_s; }

  /// Sets device external power impulse duration (seconds)
  void setImpulseDuration(int durationS) { _impulse_duration_s = durationS; }

  /// Returns device auto extarnal power mode state
  bool getAutoExternalPowerModeState() { return _aep_state == 1; }

  /// Sets device auto extarnal power mode state
  void setAutoExternalPowerModeState(bool state) {
    _aep_state = state ? 1 : 0;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(2);
    success &= (value != null);
    if (success) _activation_delay_s = value!;
    value = unpackMan.unpack<int>(2);
    success &= (value != null);
    if (success) _impulse_duration_s = value!;
    value = unpackMan.unpack<int>(2);
    success &= (value != null);
    if (success) _aep_state = value!;
    value = unpackMan.unpack<int>(2);
    success &= (value != null);
    if (success) _reserve = value!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();
    success &= super.packHeader(packMan);
    success &= packMan.pack(_activation_delay_s, 2);
    success &= packMan.pack(_impulse_duration_s, 2);
    success &= packMan.pack(_aep_state, 2);
    success &= packMan.pack(_reserve, 2);
    if (!success) return Uint8List(0);
    var rawData = packMan.getRawData();
    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class ExternalPowerPackage extends BasePackage {
  int _state = 0;

  ExternalPowerPackage() {
    setType(PackageType.SET_EXTERNAL_POWER);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is ExternalPowerPackage) {
      _state = other._state;
    }
  }

  void setExternalPowerState(ExternalPower state) {
    _state = state.index;
  }

  ExternalPower getExternalPowerState() {
    return ExternalPower.values[_state];
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();
    success &= super.packHeader(packMan);
    success &= packMan.pack(_state, 1);
    if (!success) return Uint8List(0);
    var rawData = packMan.getRawData();
    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class BatteryMonitorPackage extends BasePackage {
  double _residue = 0,
      _usedCapacity = 0,
      _voltage = 0,
      _current = 0,
      _temperature = 0,
      _elapsedTime = 0;

  int _number = 0, _totalNumber = 0;

  BatteryMonitorPackage() {
    setType(PackageType.BATTERY_MONITOR);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is BatteryMonitorPackage) {
      _residue = other._residue;
      _usedCapacity = other._usedCapacity;
      _voltage = other._voltage;
      _current = other._current;
      _temperature = other._temperature;
      _elapsedTime = other._elapsedTime;
      _number = other._number;
      _totalNumber = other._totalNumber;
    }
  }

  double getResidue() {
    return _residue;
  }

  double getUsedCapacity() {
    return _usedCapacity;
  }

  double getVoltage() {
    return _voltage;
  }

  double getCurrent() {
    return _current;
  }

  double getTemperature() {
    return _temperature;
  }

  double getElapsedTime() {
    return _elapsedTime;
  }

  int getButteryId() {
    return _number;
  }

  int getBatteriesNumber() {
    return _totalNumber;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var valueResidue = unpackMan.unpack<double>(4);
    var valueUsedCapacity = unpackMan.unpack<double>(4);
    var valueVoltage = unpackMan.unpack<double>(4);
    var valueCurrent = unpackMan.unpack<double>(4);
    var valueTemperature = unpackMan.unpack<double>(4);
    var valueElapsedTime = unpackMan.unpack<double>(4);
    var valueNumber = unpackMan.unpack<int>(2);
    var valueTotalNumber = unpackMan.unpack<int>(2);

    success &= (valueResidue != null);
    if (success) _residue = valueResidue!;

    success &= (valueUsedCapacity != null);
    if (success) _usedCapacity = valueUsedCapacity!;

    success &= (valueVoltage != null);
    if (success) _voltage = valueVoltage!;

    success &= (valueCurrent != null);
    if (success) _current = valueCurrent!;

    success &= (valueTemperature != null);
    if (success) _temperature = valueTemperature!;

    success &= (valueElapsedTime != null);
    if (success) _elapsedTime = valueElapsedTime!;

    success &= (valueNumber != null);
    if (success) _number = valueNumber!;

    success &= (valueTotalNumber != null);
    if (success) _totalNumber = valueTotalNumber!;

    return success;
  }
}

class BatteryMonitorRequestPackage extends BasePackage {
  int _batteryId = 0;

  BatteryMonitorRequestPackage() {
    setType(PackageType.GET_BATTERY_MONITOR);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is BatteryMonitorRequestPackage) {
      _batteryId = other._batteryId;
    }
  }

  void setBatteryId(int id) {
    _batteryId = id;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);
    success &= packMan.pack(_batteryId, 2);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class BatteryStatePackage extends BasePackage {
  int _state = 0;

  BatteryStatePackage() {
    setType(PackageType.BATTERY_STATE);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is BatteryStatePackage) {
      _state = other._state;
    }
  }

  BatteryState getBatteryState() {
    return BatteryState.values[_state];
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(1);
    success &= (value != null);
    if (success) _state = value!;

    return success;
  }
}

class PeripheryMaskPackage extends BasePackage {
  int _mask = 0;

  PeripheryMaskPackage() {
    setType(PackageType.SET_PERIPHERY);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is PeripheryMaskPackage) {
      _mask = other._mask;
    }
  }

  int getPeripheryMask() {
    return _mask;
  }

  void setPeripheryMask(int value) {
    _mask = value;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(1);
    success &= (value != null);
    if (success) _mask = value!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);
    success &= packMan.pack(_mask, 1);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class EEPROMFactorsPackage extends BasePackage {
  int _wakeNetworkResendTimeMs = 0, //32bit
      _alarmResendTimeMs = 0,
      _seismicResendTimeMs = 0,
      _transportSignalsTreshold = 0,
      _photoResendTimeMs = 0;

  int _transportIntervalsCount = 0, //16bit
      _alarmTriesResend = 0,
      _seismicTriesResend = 0,
      _humanSignalsTreshold = 0,
      _photoTriesResend = 0;

  int _periodicSendTelemetryTime10S = 0, //8bit
      _afterSeismicAlarmPauseS = 0,
      _afterLineAlarmPauseS = 0,
      _humanIntervalsCount = 0;

  int _batteryPeriodicUpdate10Min = 0, //8bit
      _batteryVoltageThresholdAlarm100mV = 0,
      _batteryResidueThresholdAlarmPC = 0,
      _batteryPeriodicAlarmH = 0,
      _deviceType = 0;

  EEPROMFactorsPackage() {
    setType(PackageType.SET_EEPROM_FACTORS);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is EEPROMFactorsPackage) {
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
      _periodicSendTelemetryTime10S = other._periodicSendTelemetryTime10S;
      _afterSeismicAlarmPauseS = other._afterSeismicAlarmPauseS;
      _afterLineAlarmPauseS = other._afterLineAlarmPauseS;
      _humanIntervalsCount = other._humanIntervalsCount;
      _batteryPeriodicUpdate10Min = other._batteryPeriodicUpdate10Min;
      _batteryVoltageThresholdAlarm100mV = other._batteryVoltageThresholdAlarm100mV;
      _batteryResidueThresholdAlarmPC = other._batteryResidueThresholdAlarmPC;
      _batteryPeriodicAlarmH = other._batteryPeriodicAlarmH;
      _deviceType = other._deviceType;
    }
  }

  int getWakeNetworkResendTimeMs() {
    return _wakeNetworkResendTimeMs;
  }

  void setWakeNetworkResendTimeMs(int value) {
    _wakeNetworkResendTimeMs = value;
  }

  int getAlarmResendTimeMs() {
    return _alarmResendTimeMs;
  }

  void setAlarmResendTimeMs(int value) {
    _alarmResendTimeMs = value;
  }

  int getSeismicResendTimeMs() {
    return _seismicResendTimeMs;
  }

  void setSeismicResendTimeMs(int value) {
    _seismicResendTimeMs = value;
  }

  int getTransportSignalsTreshold() {
    return _transportSignalsTreshold;
  }

  void setTransportSignalsTreshold(int value) {
    _transportSignalsTreshold = value;
  }

  int getPhotoResendTimeMs() {
    return _photoResendTimeMs;
  }

  void setPhotoResendTimeMs(int value) {
    _photoResendTimeMs = value;
  }

  int getTransportIntervalsCount() {
    return _transportIntervalsCount;
  }

  void setTransportIntervalsCount(int value) {
    _transportIntervalsCount = value;
  }

  int getAlarmTriesResend() {
    return _alarmTriesResend;
  }

  void setAlarmTriesResend(int value) {
    _alarmTriesResend = value;
  }

  int getSeismicTriesResend() {
    return _seismicTriesResend;
  }

  void setSeismicTriesResend(int value) {
    _seismicTriesResend = value;
  }

  int getHumanSignalsTreshold() {
    return _humanSignalsTreshold;
  }

  void setHumanSignalsTreshold(int value) {
    _humanSignalsTreshold = value;
  }

  int getPhotoTriesResend() {
    return _photoTriesResend;
  }

  void setPhotoTriesResend(int value) {
    _photoTriesResend = value;
  }

  int getPeriodicSendTelemetryTime10S() {
    return _periodicSendTelemetryTime10S;
  }

  void setPeriodicSendTelemetryTime10S(int value) {
    _periodicSendTelemetryTime10S = value;
  }

  int getAfterSeismicAlarmPauseS() {
    return _afterSeismicAlarmPauseS;
  }

  void setAfterSeismicAlarmPauseS(int value) {
    _afterSeismicAlarmPauseS = value;
  }

  int getAfterLineAlarmPauseS() {
    return _afterLineAlarmPauseS;
  }

  void setAfterLineAlarmPauseS(int value) {
    _afterLineAlarmPauseS = value;
  }

  int getHumanIntervalsCount() {
    return _humanIntervalsCount;
  }

  void setHumanIntervalsCount(int value) {
    _humanIntervalsCount = value;
  }

  int getBatteryPeriodicUpdate10Min() {
    return _batteryPeriodicUpdate10Min;
  }

  void setBatteryPeriodicUpdate10Min(int value) {
    _batteryPeriodicUpdate10Min = value;
  }

  int getBatteryVoltageThresholdAlarm100mV() {
    return _batteryVoltageThresholdAlarm100mV;
  }

  void setBatteryVoltageThresholdAlarm100mV(int value) {
    _batteryVoltageThresholdAlarm100mV = value;
  }

  int getBatteryResidueThresholdAlarmPC() {
    return _batteryResidueThresholdAlarmPC;
  }

  void setBatteryResidueThresholdAlarmPC(int value) {
    _batteryResidueThresholdAlarmPC = value;
  }

  int getBatteryPeriodicAlarmH() {
    return _batteryPeriodicAlarmH;
  }

  void setBatteryPeriodicAlarmH(int value) {
    _batteryPeriodicAlarmH = value;
  }

  SlaveModel getDeviceType() {
    return SlaveModel.values[_deviceType];
  }

  void setDeviceType(SlaveModel value) {
    _deviceType = value.index;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var valueWakeNetworkResendTimeMs = unpackMan.unpack<int>(4);
    success &= (valueWakeNetworkResendTimeMs != null);
    if (success) _wakeNetworkResendTimeMs = valueWakeNetworkResendTimeMs!;
    var valueAlarmResendTimeMs = unpackMan.unpack<int>(4);
    success &= (valueAlarmResendTimeMs != null);
    if (success) _alarmResendTimeMs = valueAlarmResendTimeMs!;
    var valueSeismicResendTimeMs = unpackMan.unpack<int>(4);
    success &= (valueSeismicResendTimeMs != null);
    if (success) _seismicResendTimeMs = valueSeismicResendTimeMs!;
    var valueFilter1A = unpackMan.unpack<int>(4);
    success &= (valueFilter1A != null);
    if (success) _transportSignalsTreshold = valueFilter1A!;
    var valuePhotoResendTimeMs = unpackMan.unpack<int>(4);
    success &= (valuePhotoResendTimeMs != null);
    if (success) _photoResendTimeMs = valuePhotoResendTimeMs!;

    var valueFilter2A = unpackMan.unpack<int>(2);
    success &= (valueFilter2A != null);
    if (success) _transportIntervalsCount = valueFilter2A!;
    var valueAlarmTriesResend = unpackMan.unpack<int>(2);
    success &= (valueAlarmTriesResend != null);
    if (success) _alarmTriesResend = valueAlarmTriesResend!;
    var valueSeismicTriesResend = unpackMan.unpack<int>(2);
    success &= (valueSeismicTriesResend != null);
    if (success) _seismicTriesResend = valueSeismicTriesResend!;
    var valueFilter1H = unpackMan.unpack<int>(2);
    success &= (valueFilter1H != null);
    if (success) _humanSignalsTreshold = valueFilter1H!;
    var valuePhotoTriesResend = unpackMan.unpack<int>(2);
    success &= (valuePhotoTriesResend != null);
    if (success) _photoTriesResend = valuePhotoTriesResend!;

    var valuePeriodicSendTelemetryTime10S = unpackMan.unpack<int>(1);
    success &= (valuePeriodicSendTelemetryTime10S != null);
    if (success) {
      _periodicSendTelemetryTime10S = valuePeriodicSendTelemetryTime10S!;
    }
    var valueAfterSeismicAlarmPauseS = unpackMan.unpack<int>(1);
    success &= (valueAfterSeismicAlarmPauseS != null);
    if (success) _afterSeismicAlarmPauseS = valueAfterSeismicAlarmPauseS!;
    var valueAfterLineAlarmPauseS = unpackMan.unpack<int>(1);
    success &= (valueAfterLineAlarmPauseS != null);
    if (success) _afterLineAlarmPauseS = valueAfterLineAlarmPauseS!;
    var valueFilter2H = unpackMan.unpack<int>(1);
    success &= (valueFilter2H != null);
    if (success) _humanIntervalsCount = valueFilter2H!;

    var valueBatteryPeriodicUpdate10Min = unpackMan.unpack<int>(1);
    success &= (valueBatteryPeriodicUpdate10Min != null);
    if (success) _batteryPeriodicUpdate10Min = valueBatteryPeriodicUpdate10Min!;
    var valueBatteryVoltageThresholdAlarm100mV = unpackMan.unpack<int>(1);
    success &= (valueBatteryVoltageThresholdAlarm100mV != null);
    if (success) {
      _batteryVoltageThresholdAlarm100mV =
          valueBatteryVoltageThresholdAlarm100mV!;
    }
    var valueBatteryResidueThresholdAlarmPC = unpackMan.unpack<int>(1);
    success &= (valueBatteryResidueThresholdAlarmPC != null);
    if (success) {
      _batteryResidueThresholdAlarmPC = valueBatteryResidueThresholdAlarmPC!;
    }
    var valueBatteryPeriodicAlarmH = unpackMan.unpack<int>(1);
    success &= (valueBatteryPeriodicAlarmH != null);
    if (success) _batteryPeriodicAlarmH = valueBatteryPeriodicAlarmH!;

    var valueDeviceType = unpackMan.unpack<int>(1);
    success &= (valueDeviceType != null);
    if (success) _deviceType = valueDeviceType!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);

    success &= packMan.pack(_wakeNetworkResendTimeMs, 4);
    success &= packMan.pack(_alarmResendTimeMs, 4);
    success &= packMan.pack(_seismicResendTimeMs, 4);
    success &= packMan.pack(_transportSignalsTreshold, 4);
    success &= packMan.pack(_photoResendTimeMs, 4);

    success &= packMan.pack(_transportIntervalsCount, 2);
    success &= packMan.pack(_alarmTriesResend, 2);
    success &= packMan.pack(_seismicTriesResend, 2);
    success &= packMan.pack(_humanSignalsTreshold, 2);
    success &= packMan.pack(_photoTriesResend, 2);

    success &= packMan.pack(_periodicSendTelemetryTime10S, 1);
    success &= packMan.pack(_afterSeismicAlarmPauseS, 1);
    success &= packMan.pack(_afterLineAlarmPauseS, 1);
    success &= packMan.pack(_humanIntervalsCount, 1);

    success &= packMan.pack(_batteryPeriodicUpdate10Min, 1);
    success &= packMan.pack(_batteryVoltageThresholdAlarm100mV, 1);
    success &= packMan.pack(_batteryResidueThresholdAlarmPC, 1);
    success &= packMan.pack(_batteryPeriodicAlarmH, 1);

    success &= packMan.pack(_deviceType, 1);

    if (!success) return Uint8List(0);
    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class FilePartPackage extends BasePackage {
  int _fullSize = 0, _currentPosition = 0;
  late DateTime _creationTime;
  late Uint8List _part;

  FilePartPackage() {
    setType(PackageType.MESSAGE);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is FilePartPackage) {
      _fullSize = other._fullSize;
      _currentPosition = other._currentPosition;
      _creationTime = other._creationTime;
      _part = Uint8List(other._part.length);
      _part.setAll(0, other._part);
    }
  }

  DateTime getCreationTime() {
    return _creationTime;
  }

  void setCreationTime(DateTime dateTime) {
    _creationTime = dateTime;
  }

  int getFileSize() {
    return _fullSize;
  }

  void setFileSize(int fileSize) {
    _fullSize = fileSize;
  }

  int getPartSize()  {
    return _part.length;
  }

  int getCurrentPosition() {
    return _currentPosition;
  }

  void setCurrentPosition(int position) {
    _currentPosition = position;
  }

  bool isNextAfter(FilePartPackage prevPart) {
    return
      prevPart._currentPosition + prevPart.getPartSize() == _currentPosition;
  }

  bool isLastPart() {
    return _currentPosition + getPartSize() == getFileSize();
  }

  Uint8List getPartData(){
    return _part;
  }

  void setPartData(Uint8List data){
    _part = data;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var valueCreationTime = unpackMan.unpack<DateTime>(4);
    success &= (valueCreationTime != null);
    if (success) _creationTime = valueCreationTime!;

    var valueFullSize = unpackMan.unpack<int>(4);
    success &= (valueFullSize != null);
    if (success) _fullSize = valueFullSize!;

    var valueCurrentPosition = unpackMan.unpack<int>(4);
    success &= (valueCurrentPosition != null);
    if (success) _currentPosition = valueCurrentPosition!;

    int membersSize = 12;
    int partSize = getSize() - BasePackage.minExpectedSize - membersSize;
    int count = partSize;

    if (count < 0) count = 0;

    PackMan packMan = PackMan(partSize);
    for (int i = 0; i < count; ++i){
      var value = unpackMan.unpack<int>(1);
      success &= (value != null);

      if (!success) break;

      int byte = value!;
      packMan.pack(byte, 1);
    }

    _part = packMan.getRawData()!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);
    success &= packMan.pack(_creationTime, 4);
    success &= packMan.pack(_fullSize, 4);
    success &= packMan.pack(_currentPosition, 4);
    success &= packMan.packAll(_part, 1);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}
