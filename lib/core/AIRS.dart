import 'Marker.dart';
import 'NetDevice.dart';

class AIRS extends NetDevice{
  double _batMonVoltage = 0;
  double _batMonVTemperature = 0;

  int _peripheryMask = 0;
  int _stateMask = 0;

  int _sensitivity = 0;

  @override
  void copyFrom(Marker other) {
    super.copyFrom(other);
    if (other is! AIRS) {
      return;
    }
    _batMonVoltage = other._batMonVoltage;
    _batMonVTemperature = other._batMonVTemperature;
    _peripheryMask = other._peripheryMask;
    _stateMask = other._stateMask;
    _sensitivity = other._sensitivity;
  }

  @override
  Marker clone() {
    var marker = AIRS();
    marker.copyFrom(this);
    return marker;
  }

  static String Name([bool isTr = false]) {
    return isTr ? "AIRS" : "AIRS";
  }

  @override
  String typeName([bool isTr = false]) {
    return AIRS.Name(isTr);
  }

  double get batMonVoltage => _batMonVoltage;
  set batMonVoltage(double batMonVoltage) => _batMonVoltage = batMonVoltage;

  double get  batMonVTemperature => _batMonVTemperature;
  set batMonVTemperature(double batMonVTemperature) => _batMonVTemperature = batMonVTemperature;

  int get  peripheryMask => _peripheryMask;
  set peripheryMask(int peripheryMask) => _peripheryMask = peripheryMask;

  int get  stateMask => _stateMask;
  set stateMask(int stateMask) => _stateMask = stateMask;

  int get  sensitivity => _sensitivity;
  set sensitivity(int sensitivity) => _sensitivity = sensitivity;

}
