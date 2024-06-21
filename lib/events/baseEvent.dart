// WARNING: do not change values, because they are used for DB IO

import 'package:flutter/cupertino.dart';
import 'package:projects/localizations/app_localizations.dart';

const int uInt32ErrorValue = 0xFFFFFFFF;

enum BaseEventType {
  Undefined, //= 0,
// substructures codes below
  Command, //= 1,
  Alarm, //= 2,
  System, //= 3,
  OperatorReport, //= 4,
  DeviceStatus, //= 5,
  STDConnectStatus, //= 6,
}

class BaseEvent {
/*/// Serialize inner and parent data to stream
virtual void serializeTo(QDataStream& stream) {
stream << static_cast<std::uint32_t>(type) << dateTime;
}

/// Deserialize ONLY inner data from stream
virtual void deserializeFrom(QDataStream& stream) {
std::uint32_t t;
stream >> t >> dateTime;
type = static_cast<BaseEvent::Type>(t);
}*/

  /// Copy inner and parent data from other event
  void copyFrom(BaseEvent other) {
    type = other.type;
    dateTime = other.dateTime;
  }

  /// Create deep copy of this object as root type
  BaseEvent clone() {
    var event = BaseEvent();
    event.copyFrom(this);
    return event;
  }

  /// Get string representation of event based on user access
  String message(BuildContext context) {
    return "";
  }

  BaseEventType type = BaseEventType.Undefined;
  DateTime dateTime = DateTime.now();
}

class OperatorEventInfo {
  String getShortName(BuildContext context) {
    var apContext = AppLocalizations.of(context);

    if (apContext == null) return '';
//: First letter of name
    var nn = name.isEmpty ? "" : apContext.operatorEventInfoNameAndLastName(name[0]);

//: First letter of last name
    var ln = lastName.isEmpty ? "" : apContext.operatorEventInfoNameAndLastName(lastName[0]);

//: Surname, first letter of name, first letter of lastName
    String shortName = apContext.operatorEventInfoShortName(surname, nn, ln);

    return shortName.trim();
  }

  String getFullName(BuildContext context) {
    var apContext = AppLocalizations.of(context);
    if (apContext == null) return '';
    //: Surname, name, last name
    var fullName = apContext.operatorEventInfoFullName(surname, name, lastName);
    return fullName.trim();
  }

/*
inline QDataStream& operator<<(QDataStream& stream, const OperatorEventInfo& info) {
stream << info.name << info.surname << info.lastName << info.position;
return stream;
}

inline QDataStream& operator>>(QDataStream& stream, OperatorEventInfo& info) {
stream >> info.name >> info.surname >> info.lastName >> info.position;
return stream;}*/

  String name = '';
  String surname = '';
  String lastName = '';
  String position = '';
}
