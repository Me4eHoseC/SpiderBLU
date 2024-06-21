import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:projects/localizations/app_localizations.dart';

import 'baseEvent.dart';

// WARNING: do not change values, because they are written in file
enum AlarmEventType {
  Undefined,
  WeakBattery,
  ExtPowerSafetyCatchOff,
  AutoExtPowerFired,
// subclassures codes below
  Breakline,
  Human,
  Transport,
  BreaklineSeries,
  HumanSeries,
  TransportSeries,
  LFO,
  Phototrap,
  Radiation,
}

// WARNING: do not change values, because they are written in file
enum AlarmStatus {
  Unregistered,
  Registered,
  Skipped,
}

enum Direction {
  Undefined,
  RightToLeft,
  LeftToRight,
}

class AlarmEvent extends BaseEvent {
  AlarmEvent() {
    type = BaseEventType.Alarm;
  }

/*void serializeTo(QDataStream& stream) override {
BaseEvent::serializeTo(stream);

stream << static_cast<int>(alarmType)
<< deviceId
<< static_cast<int>(isWarning)
<< static_cast<int>(status);

if (status == AlarmEvent::AlarmStatus::Registered) {
stream << operatorInfo << alarmCause << takenActions;
}
}

void deserializeFrom(QDataStream& stream) override {
int at, isWarn, st;

stream >> at >> deviceId >> isWarn >> st;

alarmType = static_cast<AlarmEventType>(at);
isWarning = static_cast<bool>(isWarn);
status = static_cast<AlarmEvent::AlarmStatus>(st);

if (status == AlarmEvent::AlarmStatus::Registered) {
stream >> operatorInfo >> alarmCause >> takenActions;
}
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! AlarmEvent) {
      return;
    }

    alarmType = other.alarmType;
    deviceId = other.deviceId;
    isWarning = other.isWarning;
    status = other.status;
    operatorInfo = other.operatorInfo;
    alarmCause = other.alarmCause;
    takenActions = other.takenActions;
  }

  @override
  BaseEvent clone() {
    var event = AlarmEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    if (alarmType == AlarmEventType.Undefined) return "";

    if (alarmType == AlarmEventType.WeakBattery) {
      return AppLocalizations.of(context)!.weakBattery;
    }

    if (alarmType == AlarmEventType.ExtPowerSafetyCatchOff) {
      return AppLocalizations.of(context)!.safetyCatchOff;
    }

    if (alarmType == AlarmEventType.AutoExtPowerFired) {
      return AppLocalizations.of(context)!.autoExtPower;
    }

    return "";
  }

  String alarmDescription(BuildContext context) {
    if (status != AlarmStatus.Registered) return "";

    String res = "";
    if (alarmCause.isNotEmpty) {
      res += AppLocalizations.of(context)!.checkResult(alarmCause);
    }

    if (takenActions.isNotEmpty) {
      if (res.isNotEmpty) res += "\n";
      res += AppLocalizations.of(context)!.actionsTaken(takenActions);
    }

    var name = operatorInfo.getFullName(context);
    if (name.isNotEmpty) {
      if (res.isNotEmpty) res += "\n";
      res += AppLocalizations.of(context)!.operatorName(takenActions);
    }

    if (operatorInfo.position.isNotEmpty) {
      if (res.isNotEmpty) res += "\n";
      res += AppLocalizations.of(context)!.operatorPosition(operatorInfo.position);
    }

    return res;
  }

  String alarmDeviceIdToString(BuildContext context) {
    if (alarmType == AlarmEventType.LFO) return "";

    var loc = NumberFormat.decimalPattern();

    var did = deviceId != uInt32ErrorValue ? AppLocalizations.of(context)!.numSign(loc.format(deviceId)) : AppLocalizations.of(context)!.questionSign;
    return did;
  }

  AlarmEventType alarmType = AlarmEventType.Undefined;

  int deviceId = uInt32ErrorValue;

  bool isWarning = false;

// Alarm description argument below. Do not use in message method
  AlarmStatus status = AlarmStatus.Unregistered;
  OperatorEventInfo operatorInfo = OperatorEventInfo();
  String alarmCause = "";
  String takenActions = "";
}

class SeismicAlarmEvent extends AlarmEvent {
  SeismicAlarmEvent(AlarmEventType alarmType) {
    this.alarmType = alarmType;
  }

/*void serializeTo(QDataStream& stream) override {
AlarmEvent::serializeTo(stream);

stream << signalsAmount;
}

void deserializeFrom(QDataStream& stream) override {
stream >> signalsAmount;
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! SeismicAlarmEvent) {
      return;
    }

    signalsAmount = other.signalsAmount;
  }

  @override
  BaseEvent clone() {
    var event = SeismicAlarmEvent(alarmType);
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var loc = NumberFormat.decimalPattern();

    var sa = signalsAmount != uInt32ErrorValue ? loc.format(signalsAmount) : AppLocalizations.of(context)!.questionSign;

    String text = "";
    if (alarmType == AlarmEventType.Human) {
      text = AppLocalizations.of(context)!.alarmEventTypeHuman(sa);
    } else if (alarmType == AlarmEventType.Transport) {
      text = AppLocalizations.of(context)!.alarmEventTypeTransport(sa);
    } else {
      return "";
    }

    return text;
  }

  int signalsAmount = uInt32ErrorValue;
}

class BreaklineAlarmEvent extends AlarmEvent {
  BreaklineAlarmEvent() {
    alarmType = AlarmEventType.Breakline;
  }

/*void serializeTo(QDataStream& stream) override {
AlarmEvent::serializeTo(stream);

stream << breaklineNumber << alarmSeqNumber;
stream << static_cast<int>(direction);
}

void deserializeFrom(QDataStream& stream) override {
stream >> breaklineNumber >> alarmSeqNumber;

int dc;
stream >> dc;
direction = static_cast<BreaklineAlarmEvent::Direction>(dc);
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! BreaklineAlarmEvent) {
      return;
    }

    breaklineNumber = other.breaklineNumber;
    alarmSeqNumber = other.alarmSeqNumber;
  }

  @override
  BaseEvent clone() {
    var event = BreaklineAlarmEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var loc = NumberFormat.decimalPattern();
    var app = AppLocalizations.of(context)!;

    String bn = breaklineNumber != uInt32ErrorValue ? loc.format(breaklineNumber) : app.questionSign;

    String d = "", asn = "";
    asn = alarmSeqNumber != uInt32ErrorValue ? app.numSign(alarmSeqNumber) : app.questionSign;

    if (direction == Direction.LeftToRight) {
      d = "→";
    } else if (direction == Direction.RightToLeft) {
      d = "←";
    } else {
      d = "-";
    }

//: bn - Breakline number, d - movement direction, asn - alarm number
    return app.alarmEventBreakline(bn, d, asn);
  }

  int breaklineNumber = uInt32ErrorValue;
  int alarmSeqNumber = uInt32ErrorValue;
  Direction direction = Direction.Undefined;
}

class SeriesAlarmEvent extends AlarmEvent {
  SeriesAlarmEvent(AlarmEventType alarmType) {
    this.alarmType = alarmType;
  }

/*void serializeTo(QDataStream& stream) override {
AlarmEvent::serializeTo(stream);

stream << totalAlarmsAmount << totalSignalsAmount;

int size = alarmsDateTimes.size();
stream << size;

for (var dt : alarmsDateTimes) stream << dt;
}

void deserializeFrom(QDataStream& stream) override {
stream >> totalAlarmsAmount >> totalSignalsAmount;

int size;
stream >> size;

for (unsigned int i = 0; i < size; ++i) {
QDateTime dt;
stream >> dt;
alarmsDateTimes.push_back(dt);
}
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! SeriesAlarmEvent) {
      return;
    }

    totalAlarmsAmount = other.totalAlarmsAmount;
    totalSignalsAmount = other.totalSignalsAmount;
    alarmsDateTimes = other.alarmsDateTimes;
  }

  @override
  BaseEvent clone() {
    var event = SeriesAlarmEvent(alarmType);
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    String type = "";
    var app = AppLocalizations.of(context)!;
    if (alarmType == AlarmEventType.HumanSeries) {
      type = app.alarmEventSeriesHuman;
    } else if (alarmType == AlarmEventType.TransportSeries) {
      type = app.alarmEventSeriesTransport;
    } else if (alarmType == AlarmEventType.BreaklineSeries) {
      type = app.alarmEventTypeBreakline;
    } else {
      return "";
    }

    var loc = NumberFormat.decimalPattern();
    var max = uInt32ErrorValue;

    var taa = totalAlarmsAmount != max ? loc.format(totalAlarmsAmount) : app.questionSign;
    var tsa = totalSignalsAmount != max ? loc.format(totalSignalsAmount) : app.questionSign;

    return app.alarmEventTypeSeries(type, taa, tsa);
  }

  int totalAlarmsAmount = uInt32ErrorValue;
  int totalSignalsAmount = uInt32ErrorValue;
  List<DateTime> alarmsDateTimes = [];
}

class LfoAlarmEvent extends AlarmEvent {
  LfoAlarmEvent() {
    alarmType = AlarmEventType.LFO;
  }
/*

void serializeTo(QDataStream& stream) override {
AlarmEvent::serializeTo(stream);

stream << clusterId;

stream << static_cast<int>(devicesIds.size());
for (int id : devicesIds) stream << id;
}

void deserializeFrom(QDataStream& stream) override {
stream >> clusterId;

int size;
stream >> size;

for (unsigned int i = 0; i < size; ++i) {
int id;
stream >> id;
devicesIds.push_back(id);
}
}
*/

  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! LfoAlarmEvent) {
      return;
    }

    clusterId = other.clusterId;
    devicesIds = other.devicesIds;
  }

  @override
  BaseEvent clone() {
    var event = LfoAlarmEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var loc = NumberFormat.decimalPattern();

    List<String> list = [];
    for (var id in devicesIds) {
      list.add(loc.format(id).toString());
    }

    return AppLocalizations.of(context)!.alarmEventTypeLfo(list.join(", "));
  }

  int clusterId = uInt32ErrorValue;
  List<int> devicesIds = [];
}

class PhototrapAlarmEvent extends AlarmEvent {
  PhototrapAlarmEvent() {
    alarmType = AlarmEventType.Phototrap;
  }

/*void serializeTo(QDataStream& stream) override {
AlarmEvent::serializeTo(stream);

stream << triggeredDeviceId;
}

void deserializeFrom(QDataStream& stream) override {
stream >> triggeredDeviceId;
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! PhototrapAlarmEvent) {
      return;
    }
    triggeredDeviceId = other.triggeredDeviceId;
  }

  @override
  BaseEvent clone() {
    var event = PhototrapAlarmEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var app = AppLocalizations.of(context)!;
    if (triggeredDeviceId == deviceId) {
      return app.phototrap;
    }

    var loc = NumberFormat.decimalPattern();
    var max = uInt32ErrorValue;

    var tdid = triggeredDeviceId != max ? loc.format(triggeredDeviceId) : app.questionSign;

    return app.alarmEventTypePhototrap(tdid);
  }

  int triggeredDeviceId = uInt32ErrorValue;
}

class RadiationAlarmEvent extends AlarmEvent {
  RadiationAlarmEvent() {
    alarmType = AlarmEventType.Radiation;
  }

/*void serializeTo(QDataStream& stream) override {
AlarmEvent::serializeTo(stream);

stream << exceeding << moduleNumber;
}

void deserializeFrom(QDataStream& stream) override {
stream >> exceeding >> moduleNumber;
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! RadiationAlarmEvent) {
      return;
    }

    exceeding = other.exceeding;
    moduleNumber = other.moduleNumber;
  }

  @override
  BaseEvent clone() {
    var event = RadiationAlarmEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var loc = NumberFormat.decimalPattern();
    var max = uInt32ErrorValue;
    var app = AppLocalizations.of(context)!;

    var mn = moduleNumber != max ? loc.format(moduleNumber) : app.questionSign;

    String exc;
    if (exceeding < 2) {
      exc = app.alarmEventTypeRadiationLess;
    } else if (exceeding >= 255) {
      exc = app.alarmEventTypeRadiationMore;
    } else if (exceeding == double.maxFinite) {
      exc = app.questionSign;
    } else {
      exc = "x${loc.format(exceeding)}";
    }

    return app.alarmEventTypeRadiation(mn, exc);
  }

  double exceeding = double.maxFinite;
  int moduleNumber = uInt32ErrorValue;
}
