import 'package:projects/core/Marker.dart';

enum NDState {
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

abstract class NetDevice extends Marker {
  DateTime _timeS = DateTime.fromMillisecondsSinceEpoch(0);
  int _firmwareVersion = 0;
  bool _stdMode = false;
  NDState _state = NDState.Offline;
  DateTime? _wasActiveDateTime;
  int _modemFrequency = 0;

  @override
  void copyFrom(Marker other) {
    super.copyFrom(other);
    if (other is! NetDevice) {
      return;
    }
    _modemFrequency = other._modemFrequency;
    _stdMode = other._stdMode;
    _state = other._state;
    _wasActiveDateTime = other._wasActiveDateTime;
    _timeS = other._timeS;
    _firmwareVersion = other._firmwareVersion;
  }

  static String Name([bool isTr = false]) {
    return isTr ? "NetDevice" : "NetDevice";
  }

  int get modemFrequency => _modemFrequency;
  set modemFrequency(int freq) => _modemFrequency = freq;

  bool get stdMode => _stdMode;
  set stdMode(bool isStdMode) => _stdMode = isStdMode;

  bool get isOnline => _state != NDState.Offline;

  NDState get state => _state;
  set state(NDState state) => _state = state;

  void confirmIsActiveNow() {
    _wasActiveDateTime = DateTime.now();
  }

  bool wasActiveDuringMs(int interval) {
    if (_wasActiveDateTime == null) return false;

    var diffMs = DateTime.now().millisecondsSinceEpoch - _wasActiveDateTime!.millisecondsSinceEpoch;

    return diffMs < interval;
  }

  DateTime get time => _timeS.toLocal();
  set time(DateTime time) => _timeS = time.toLocal();

  int get firmwareVersion => _firmwareVersion;
  set firmwareVersion(int version) => _firmwareVersion = version;

}
