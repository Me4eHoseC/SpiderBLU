import 'package:flutter/cupertino.dart';
import 'package:projects/localizations/app_localizations.dart';

import 'baseEvent.dart';

class OperatorReportEvent extends BaseEvent {
  OperatorReportEvent() {
    type = BaseEventType.OperatorReport;
  }

/*void serializeTo(QDataStream& stream) override {
BaseEvent::serializeTo(stream);

stream << reportMessage << operatorInfo;
}

void deserializeFrom(QDataStream& stream) override {
stream >> reportMessage >> operatorInfo;
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! OperatorReportEvent) {
      return;
    }

    reportMessage = other.reportMessage;
    operatorInfo = other.operatorInfo;
  }

  @override
  BaseEvent clone() {
    var event = OperatorReportEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var tr = AppLocalizations.of(context);
    if (tr == null) return '';

    var operatorName = operatorInfo.getShortName(context);
//: Report[ from %1]:, where %1 - operator name
    var on = operatorName.isNotEmpty ? tr.variosEventsOperatorNameNotEmpty(operatorName) : "";

//: Report:\n%1, where %1 - report message
    var rm = reportMessage.isNotEmpty ? tr.variosEventsReportMessageNotEmpty(reportMessage) : "";

//: %1 - operator name, %2 - report message
    return tr.variosEventsReport(on, rm);
  }

  String reportMessage = "";
  OperatorEventInfo operatorInfo = OperatorEventInfo();
}

class DeviceStatusEvent extends BaseEvent {
  DeviceStatusEvent() {
    type = BaseEventType.DeviceStatus;
  }

/*void serializeTo(QDataStream& stream) override {
BaseEvent::serializeTo(stream);

stream << deviceId << static_cast<std::uint32_t>(status);
}
void deserializeFrom(QDataStream& stream) override {
std::uint32_t st;
stream >> deviceId >> st;
status = static_cast<bool>(st);
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! DeviceStatusEvent) {
      return;
    }

    deviceId = other.deviceId;
    status = other.status;
  }

  @override
  BaseEvent clone() {
    var event = DeviceStatusEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var tr = AppLocalizations.of(context);
    if (tr == null) return '';

    if (type == BaseEventType.DeviceStatus) {
      return status ? tr.statusOnline : tr.statusOffline;
    } else if (type == BaseEventType.STDConnectStatus) {
      return status ? tr.statusSTDConnected : tr.statusSTDDisconnected;
    } else {
      return "";
    }
  }

  int deviceId = uInt32ErrorValue;
  bool status = false;
}
