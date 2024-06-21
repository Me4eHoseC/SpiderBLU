import 'package:projects/core/Marker.dart';

import '/global.dart' as global;

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
  int _channel = 0;
  bool _isMain = false;

  @override
  void copyFrom(Marker other) {
    super.copyFrom(other);
    if (other is! NetDevice) {
      return;
    }
    _channel = other._channel;
    _isMain = other._isMain;
    _modemFrequency = other._modemFrequency;
    _stdMode = other._stdMode;
    _state = other._state;
    _wasActiveDateTime = other._wasActiveDateTime;
    _timeS = other._timeS;
    _firmwareVersion = other._firmwareVersion;
  }

  static String Name() {
    return "NetDevice";
  }

  int get modemFrequency => _modemFrequency;
  set modemFrequency(int frequency) {
    _modemFrequency = frequency;

    var frequencyDiff = frequency - global.baseFrequency;
    var c = frequencyDiff / global.channelFrequencyStep;

    _isMain = c - c.floor() == 0;

    _channel = 0;
    if (isMain) {
      _channel = frequencyDiff ~/ global.channelFrequencyStep + 5;
    } else {
      _channel = (frequencyDiff - global.reserveFrequencyOffset) ~/ global.channelFrequencyStep + 5;
    }
  }

  int get channel => _channel;

  bool get isMain => _isMain;

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
