import 'package:projects/core/NetDevice.dart';

import 'Marker.dart';

class MCD extends NetDevice {
  bool _priority = true;
  bool _gpsState = false;
  double _batMonVoltage = 0;
  double _batMonTemperature = 0;

  @override
  void copyFrom(Marker other) {
    super.copyFrom(other);
    if (other is! MCD) {
      return;
    }
    _priority = other._priority;
    _gpsState = other._gpsState;
    _batMonVoltage = other._batMonVoltage;
    _batMonTemperature = other._batMonTemperature;
  }

  @override
  Marker clone() {
    var marker = MCD();
    marker.copyFrom(this);
    return marker;
  }

  static String Name() {
    return "MCD";
  }

  @override
  String typeName() {
    return MCD.Name();
  }

  bool get priority => _priority;
  set priority(bool isPriorityOn) => _priority = isPriorityOn;

  bool get GPSState => _gpsState;
  set GPSState(bool isGPSState) => _gpsState = isGPSState;

  double get batMonVoltage => _batMonVoltage;
  double get batMonTemperature => _batMonTemperature;

  void setBatMonParameters(double voltage, temperature) {
    _batMonVoltage = voltage;
    _batMonTemperature = temperature;
  }
}
