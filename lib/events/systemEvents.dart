import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:projects/localizations/app_localizations.dart';

import 'baseEvent.dart';

// WARNING: do not change values, because they are written in file
enum SystemEventType {
  Undefined, // = 0,

  ProgramLaunched, // = 1,
  ProgramClosed, // = 2,
  AdminModeEntered, // = 3,
  UserModeEntered, // = 4,
  NetworkTreeBuildingStarted, // = 5,
  NetworkTreeDestroyingStarted, // = 6,
  NetworkTreeOperationFinished, // = 7,
  HttpStart, // = 8,
  HttpStop, // = 9,
  HttpError, // = 10,
  PollStarted, // = 11,
  PollFinished, // = 12,

// substructures codes below

  AlarmsFilter, // = 13,
}

class SystemEvent extends BaseEvent {
  SystemEvent() {
    type = BaseEventType.System;
  }

/*void serializeTo(QDataStream& stream) override {
BaseEvent.serializeTo(stream);

stream << static_cast<std.uint32_t>(eventType);
}
void deserializeFrom(QDataStream& stream) override {
std.uint32_t st;
stream >> st;
eventType = static_cast<SystemEvent.Type>(st);
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! SystemEvent) {
      return;
    }

    eventType = other.eventType;
  }

  @override
  BaseEvent clone() {
    var event = SystemEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    if (eventType == SystemEventType.Undefined) return "";

    var tr = AppLocalizations.of(context);
    if (tr == null) return '';

    switch (eventType) {
      case SystemEventType.ProgramLaunched:
        return tr.applicationLaunched;
      case SystemEventType.ProgramClosed:
        return tr.applicationClosed;
      case SystemEventType.AdminModeEntered:
        return tr.adminMode;
      case SystemEventType.UserModeEntered:
        return tr.userMode;
      case SystemEventType.NetworkTreeBuildingStarted:
        return tr.netTreeBuilding;
      case SystemEventType.NetworkTreeDestroyingStarted:
        return tr.netTreeDestroying;
      case SystemEventType.NetworkTreeOperationFinished:
        return tr.netTreeChanged;
      case SystemEventType.HttpStart:
        return tr.httpOn;
      case SystemEventType.HttpStop:
        return tr.httpOff;
      case SystemEventType.HttpError:
        return tr.httpError;
      case SystemEventType.PollStarted:
        return tr.pollStarted;
      case SystemEventType.PollFinished:
        return tr.pollFinished;
      default:
        return "";
    }
  }

  SystemEventType eventType = SystemEventType.Undefined;
}

class AlarmsFilterSystemEvent extends SystemEvent {
  AlarmsFilterSystemEvent() {
    eventType = SystemEventType.AlarmsFilter;
  }

/*void serializeTo(QDataStream& stream){
SystemEvent.serializeTo(stream);

stream << humanSignalsCountThreshold << transportSignalsCountThreshold;
}
void deserializeFrom(QDataStream& stream) override {
stream >> humanSignalsCountThreshold >> transportSignalsCountThreshold;
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! AlarmsFilterSystemEvent) {
      return;
    }

    humanSignalsCountThreshold = other.humanSignalsCountThreshold;
    transportSignalsCountThreshold = other.transportSignalsCountThreshold;
  }

  @override
  BaseEvent clone() {
    var event = AlarmsFilterSystemEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var loc = NumberFormat.decimalPattern();
    var tr = AppLocalizations.of(context);
    if (tr == null) return '';

    var hs = humanSignalsCountThreshold != uInt32ErrorValue ? loc.format(humanSignalsCountThreshold) : tr.questionSign;
    var ts = transportSignalsCountThreshold != uInt32ErrorValue ? loc.format(transportSignalsCountThreshold) : tr.questionSign;

//: H - human, T - transport
    return tr.alarmsFilterSystemEvent(hs, ts);
  }

  int humanSignalsCountThreshold = uInt32ErrorValue;
  int transportSignalsCountThreshold = uInt32ErrorValue;
}
