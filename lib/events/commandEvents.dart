import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:projects/radionet/RoutesManager.dart';

import '../localizations/app_localizations.dart';
import '../radionet/NetPackagesDataTypes.dart';
import 'baseEvent.dart';

import 'package:projects/global.dart' as global;

// WARNING: do not change values, because they are written in file

enum CommandEventType {
  Undefined,

  TimeSynchronised,
  BatteryChanged,

  ExternalPowerOn,
  ExternalPowerOff,

  DeviceRebooted,
  SettingsStored,
  SettingsReset,

  ExtPowerSafetyCatchOff,
  ExtPowerSafetyCatchOn,

// substructures codes below

  Coordinates,
  InternalDevices,
  RadioChannel,

  CameraParameters,
  PhototrapTrigger,

  RecognitnionClasses,
  Threshold,
  HumanFrequency,
  CriterionFilter,
  CriterionRecognition,
  AlarmsFilter,
  SNR,

  AutoExtPower,
  RadiationThreshold,
}

enum CommandEventOperatorType {
  LocalOperator,
  RemoteOperator,
  Automatics,
}

class CommandEvent extends BaseEvent {
  CommandEvent() {
    type = BaseEventType.Command;
  }

/*void serializeTo(QDataStream& stream) override {
BaseEvent::serializeTo(stream);

stream << static_cast<std::uint32_t>(commandType);
stream << operatorId << deviceId;
stream << static_cast<std::uint32_t>(isSended);
stream << static_cast<std::uint32_t>(operatorType);
}

void deserializeFrom(QDataStream& stream) override {
std::uint32_t ct, is, ot;
stream >> ct >> operatorId >> deviceId >> is >> ot;

commandType = static_cast<CommandEvent::Type>(ct);
isSended = static_cast<bool>(is);
operatorType = static_cast<CommandEvent::OperatorType>(ot);
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! CommandEvent) {
      return;
    }

    commandType = other.commandType;
    operatorId = other.operatorId;
    deviceId = other.deviceId;
    isSended = other.isSended;
    operatorType = other.operatorType;
  }

  @override
  BaseEvent clone() {
    var event = CommandEvent();
    event.copyFrom(this);
    return event;
  }

  String message(BuildContext context) {
    var tr = AppLocalizations.of(context)!;
    if (commandType == CommandEventType.Undefined) return "";

    if (commandType == CommandEventType.TimeSynchronised) {
//: Translate as command name
      return tr.commandEventTypeTimeSynchronised;
    } else if (commandType == CommandEventType.BatteryChanged) {
//: Translate as command name
      return tr.commandEventTypeBatteryChanged;
    } else if (commandType == CommandEventType.ExternalPowerOn) {
//: Translate as command name
      return tr.commandEventTypeExternalPowerOn;
    } else if (commandType == CommandEventType.ExternalPowerOff) {
//: Translate as command name
      return tr.commandEventTypeExternalPowerOff;
    } else if (commandType == CommandEventType.DeviceRebooted) {
//: Translate as command name
      return tr.commandEventTypeDeviceRebooted;
    } else if (commandType == CommandEventType.SettingsStored) {
//: Translate as command name
      return tr.commandEventTypeSettingsStored;
    } else if (commandType == CommandEventType.SettingsReset) {
//: Translate as command name
      return tr.commandEventTypeSettingsReset;
    } else if (commandType == CommandEventType.ExtPowerSafetyCatchOn) {
//: Translate as command name
      return tr.commandEventTypeExtPowerSafetyCatchOn;
    } else if (commandType == CommandEventType.ExtPowerSafetyCatchOff) {
//: Translate as command name
      return tr.commandEventTypeExtPowerSafetyCatchOff;
    }

    return "";
  }

  String commandStatus(BuildContext context) {
    var myId = RoutesManager.getLaptopAddress();

    var loc = NumberFormat.decimalPattern();
    var max = uInt32ErrorValue;

    var tr = AppLocalizations.of(context)!;

    var oid = operatorId != max ? loc.format(operatorId) : tr.questionSign;

    if (isSended) {
      if (operatorType == CommandEventOperatorType.LocalOperator) {
        if (myId == operatorId) {
          return "";
        } else {
          return tr.commandEventOperatorTypeLocalOperatorSent(oid);
        }
      } else if (operatorType == CommandEventOperatorType.RemoteOperator) {
        return tr.commandEventOperatorTypeRemoteOperatorSent(oid);
      } else if (operatorType == CommandEventOperatorType.Automatics) {
        return tr.commandEventOperatorTypeAutomaticsSent;
      } else {
        return "";
      }
    } else {
      var text = tr.failedToSendCommand;

      if (operatorType == CommandEventOperatorType.LocalOperator) {
        if (myId != operatorId) {
          text += " ${tr.commandEventOperatorTypeLocalOperatorFailed(oid)}";
        }
      } else if (operatorType == CommandEventOperatorType.RemoteOperator) {
        text += " ${tr.commandEventOperatorTypeRemoteOperatorFailed(oid)}";
      } else if (operatorType == CommandEventOperatorType.Automatics) {
        text += " ${tr.commandEventOperatorTypeAutomaticsFailed}";
      }

      return text;
    }
  }

  String commandDeviceIdToString(BuildContext context) {
    var loc = NumberFormat.decimalPattern();
    var max = uInt32ErrorValue;

    var tr = AppLocalizations.of(context)!;

    var rid = deviceId != max ? loc.format(deviceId) : tr.questionSign;
    return rid;
  }

  CommandEventType commandType = CommandEventType.Undefined;

// Command status information below. Do not use in message method
  var operatorId = uInt32ErrorValue;
  var deviceId = uInt32ErrorValue;
  bool isSended = true;
  CommandEventOperatorType operatorType = CommandEventOperatorType.LocalOperator;
}

class CoordinatesCommandEvent extends CommandEvent {
  CoordinatesCommandEvent() {
    commandType = CommandEventType.Coordinates;
  }

/*void serializeTo(QDataStream& stream) override {
CommandEvent::serializeTo(stream);

stream << latitude << longitude;
}

void deserializeFrom(QDataStream& stream) override {
stream >> latitude >> longitude;
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! CoordinatesCommandEvent) {
      return;
    }

    latitude = other.latitude;
    longitude = other.longitude;
  }

  @override
  BaseEvent clone() {
    var event = CoordinatesCommandEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var loc = NumberFormat.decimalPattern();
    var max = uInt32ErrorValue;
    var tr = AppLocalizations.of(context)!;

    var lat = latitude != max ? loc.format(latitude) : tr.questionSign;
    var lon = longitude != max ? loc.format(longitude) : tr.questionSign;

    return tr.coordinatesEvents(lat, lon);

//return tr("Coordinates");
  }

  double latitude = double.maxFinite;
  double longitude = double.maxFinite;
}

class InternalDevicesCommandEventState {
  int Undefined = 0, Breakline1 = 1 << 0, Breakline2 = 1 << 1, PhototrapBreakline = 1 << 2, Geophone = 1 << 3;
}

class InternalDevicesCommandEvent extends CommandEvent {
  InternalDevicesCommandEvent() {
    commandType = CommandEventType.InternalDevices;
  }

/*void serializeTo(QDataStream& stream) override {
CommandEvent::serializeTo(stream);

stream << state;
}

void deserializeFrom(QDataStream& stream) override {
stream >> state;
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! InternalDevicesCommandEvent) {
      return;
    }

    state = other.state;
  }

  @override
  BaseEvent clone() {
    var event = InternalDevicesCommandEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var max = uInt32ErrorValue;
    var tr = AppLocalizations.of(context)!;

    List<String> modeList = [];
    if (max == state) {
      modeList.add(tr.questionSign);
    } else {
      var ST = InternalDevicesCommandEventState();

      if (state & ST.Breakline1 != 0) modeList.add(tr.internalDevicesCommandEventStateBreakline1);
      if (state & ST.Breakline2 != 0) modeList.add(tr.internalDevicesCommandEventStateBreakline2);
      if (state & ST.PhototrapBreakline != 0) modeList.add(tr.internalDevicesCommandEventStatePhototrapBreakline);
      if (state & ST.Geophone != 0) modeList.add(tr.internalDevicesCommandEventStateGeophone);

      if (modeList.isEmpty) modeList.add(tr.typeNo);
    }

    return tr.internalDevices(modeList.join(", "));
  }

  var state = uInt32ErrorValue;
}

class RadioChannelCommandEvent extends CommandEvent {
  RadioChannelCommandEvent() {
    commandType = CommandEventType.RadioChannel;
  }

/*void serializeTo(QDataStream& stream) override {
CommandEvent::serializeTo(stream);

stream << channelNumber;
}

void deserializeFrom(QDataStream& stream) override {
stream >> channelNumber;
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! RadioChannelCommandEvent) {
      return;
    }

    channelNumber = other.channelNumber;
  }

  @override
  BaseEvent clone() {
    var event = RadioChannelCommandEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var loc = NumberFormat.decimalPattern();
    var max = uInt32ErrorValue;
    var tr = AppLocalizations.of(context)!;

    var cn = channelNumber != max ? loc.format(channelNumber) : tr.questionSign;

    return tr.chanelNumber(cn);
  }

  var channelNumber = uInt32ErrorValue;
}

class CameraParametersCommandEvent extends CommandEvent {
  CameraParametersCommandEvent() {
    commandType = CommandEventType.CameraParameters;
  }

/*void serializeTo(QDataStream& stream) override {
CommandEvent::serializeTo(stream);

stream << lightThreshold << compression;
}

void deserializeFrom(QDataStream& stream) override {
stream >> lightThreshold >> compression;
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! CameraParametersCommandEvent) {
      return;
    }

    lightThreshold = other.lightThreshold;
    compression = other.compression;
  }

  @override
  BaseEvent clone() {
    var event = CameraParametersCommandEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var loc = NumberFormat.decimalPattern();
    var max = uInt32ErrorValue;
    var tr = AppLocalizations.of(context)!;

    var lt = lightThreshold != max ? loc.format(lightThreshold) : tr.questionSign;

    String cp;
    switch (castToCompression(compression)) {
      case PhotoImageCompression.MINIMUM:
        cp = tr.min;
        break;
      case PhotoImageCompression.LOW:
        cp = tr.low;
        break;
      case PhotoImageCompression.MEDIUM:
        cp = tr.med;
        break;
      case PhotoImageCompression.HIGH:
        cp = tr.high;
        break;
      case PhotoImageCompression.MAXIMUM:
        cp = tr.max;
        break;
    }

    if (compression == max) cp = tr.questionSign;

    return tr.cameraLightTresholdAndCompression(lt, cp);
  }

  var lightThreshold = uInt32ErrorValue;
  var compression = uInt32ErrorValue;
}

class PhototrapTriggerCommandEvent extends CommandEvent {
  PhototrapTriggerCommandEvent() {
    commandType = CommandEventType.PhototrapTrigger;
  }

/*void serializeTo(QDataStream& stream) override {
CommandEvent::serializeTo(stream);

stream << triggerDeviceId;
}

void deserializeFrom(QDataStream& stream) override {
stream >> triggerDeviceId;
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! PhototrapTriggerCommandEvent) {
      return;
    }
    triggerDeviceId = other.triggerDeviceId;
  }

  @override
  BaseEvent clone() {
    var event = PhototrapTriggerCommandEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var loc = NumberFormat.decimalPattern();
    var max = uInt32ErrorValue;
    var tr = AppLocalizations.of(context)!;

    var tdi = triggerDeviceId != max ? loc.format(triggerDeviceId) : tr.questionSign;

    return tr.phototrapTriggerID(tdi);
  }

  var triggerDeviceId = uInt32ErrorValue;
}

class RecognitionClassesCommandEventClass {
  var Undefined = 0, Human = 1 << 0, Transport = 1 << 1;
}

class RecognitionClassesCommandEvent extends CommandEvent {
  RecognitionClassesCommandEvent() {
    commandType = CommandEventType.RecognitnionClasses;
  }

/*void serializeTo(QDataStream& stream) override {
CommandEvent::serializeTo(stream);

stream << recognizedClasses;
}

void deserializeFrom(QDataStream& stream) override {
stream >> recognizedClasses;
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! RecognitionClassesCommandEvent) {
      return;
    }

    recognizedClasses = other.recognizedClasses;
  }

  @override
  BaseEvent clone() {
    var event = RecognitionClassesCommandEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var max = uInt32ErrorValue;
    var tr = AppLocalizations.of(context)!;

    List<String> recList = [];
    if (recognizedClasses == max) {
      recList.add(tr.questionSign);
    } else {
      var CL = RecognitionClassesCommandEventClass();

      if (recognizedClasses & CL.Human != 0) recList.add(tr.alarmEventSeriesHuman);
      if (recognizedClasses & CL.Transport != 0) recList.add(tr.alarmEventSeriesTransport);

      if (recList.isEmpty) recList.add(tr.typeNo);
    }

    return tr.recognitionClasses(recList.join(", "));
  }

  var recognizedClasses = uInt32ErrorValue;
}

enum ThresholdCommandEventType {
  Undefined,

  Human,
  Transport,

  IRS,
}

class ThresholdCommandEvent extends CommandEvent {
  ThresholdCommandEvent() {
    commandType = CommandEventType.Threshold;
  }

/*void serializeTo(QDataStream& stream) override {
CommandEvent::serializeTo(stream);

stream << static_cast<std::uint32_t>(channelType);
stream << threshold;
}

void deserializeFrom(QDataStream& stream) override {
std::uint32_t ct;
stream >> ct >> threshold;

channelType = static_cast<ThresholdCommandEvent::Type>(ct);
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! ThresholdCommandEvent) {
      return;
    }

    channelType = other.channelType;
    threshold = other.threshold;
  }

  @override
  BaseEvent clone() {
    var event = ThresholdCommandEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    String channel;
    var tr = AppLocalizations.of(context)!;
    if (channelType == ThresholdCommandEventType.Human) {
//: Will be used in phrase 'Human threshold'. Attention with capital letter
      channel = tr.alarmEventSeriesHuman;
    } else if (channelType == ThresholdCommandEventType.Transport) {
//: Will be used in phrase 'Transport threshold'. Attention with capital letter
      channel = tr.alarmEventSeriesTransport;
    } else if (channelType == ThresholdCommandEventType.IRS) {
//: Will be used in phrase 'A-IRS threshold'. Attention with capital letter
      channel = tr.airsName;
    } else {
//: Will be used in phrase 'Undefined threshold'. Attention with capital letter
      channel = tr.undefined;
    }

    var loc = NumberFormat.decimalPattern();
    var max = uInt32ErrorValue;

    var t = threshold != max ? loc.format(threshold) : tr.questionSign;

//: %1 - threshold name, %2 - threshold value
    return tr.thresholdNameAndValue(channel, t);
  }

  ThresholdCommandEventType channelType = ThresholdCommandEventType.Undefined;
  var threshold = uInt32ErrorValue;
}

//#ifdef FREQ_THRESHOLD
class HumanFreqThresholdCommandEvent extends CommandEvent {
  HumanFreqThresholdCommandEvent() {
    commandType = CommandEventType.HumanFrequency;
  }

/*void serializeTo(QDataStream& stream) override {
CommandEvent::serializeTo(stream);

stream << freqThreshold;
}

void deserializeFrom(QDataStream& stream) override {
stream >> freqThreshold;
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! HumanFreqThresholdCommandEvent) {
      return;
    }

    freqThreshold = other.freqThreshold;
  }

  @override
  BaseEvent clone() {
    var event = HumanFreqThresholdCommandEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var loc = NumberFormat.decimalPattern();
    var max = uInt32ErrorValue;
    var tr = AppLocalizations.of(context)!;

    var ft = freqThreshold != max ? loc.format(freqThreshold) : tr.questionSign;
    return tr.stepThreshold(ft);
  }

  var freqThreshold = uInt32ErrorValue;
}

enum CriterionFilterCommandEventCriterion {
  Undefined,
  Filter1of3,
  Filter2of3,
  Filter3of3,
  Filter2of4,
  Filter3of4,
  Filter4of4,
}

class CriterionFilterCommandEvent extends CommandEvent {
  CriterionFilterCommandEvent() {
    commandType = CommandEventType.CriterionFilter;
  }

/*void serializeTo(QDataStream& stream) override {
CommandEvent::serializeTo(stream);

stream << static_cast<std::uint32_t>(criterionFilter);
}

void deserializeFrom(QDataStream& stream) override {
std::uint32_t cf;
stream >> cf;

criterionFilter = static_cast<CriterionFilterCommandEvent::Criterion>(cf);
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! CriterionFilterCommandEvent) {
      return;
    }

    criterionFilter = other.criterionFilter;
  }

  @override
  BaseEvent clone() {
    var event = CriterionFilterCommandEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var tr = AppLocalizations.of(context)!;
    switch (criterionFilter) {
      case CriterionFilterCommandEventCriterion.Filter1of3:
        return '${tr.criterionFilter} ${tr.oneOfThree}';
      case CriterionFilterCommandEventCriterion.Filter2of3:
        return '${tr.criterionFilter} ${tr.twoOfThree}';
      case CriterionFilterCommandEventCriterion.Filter3of3:
        return '${tr.criterionFilter} ${tr.threeOfThree}';
      case CriterionFilterCommandEventCriterion.Filter2of4:
        return '${tr.criterionFilter} ${tr.twoOfFour}';
      case CriterionFilterCommandEventCriterion.Filter3of4:
        return '${tr.criterionFilter} ${tr.threeOfFour}';
      case CriterionFilterCommandEventCriterion.Filter4of4:
        return '${tr.criterionFilter} ${tr.fourOfFour}';
      default:
        return "${tr.criterionFilter} ${tr.questionSign}/${tr.questionSign}";
    }
  }

  CriterionFilterCommandEventCriterion criterionFilter = CriterionFilterCommandEventCriterion.Undefined;
}

class CriterionRecognitionCommandEvent extends CommandEvent {
  CriterionRecognitionCommandEvent() {
    commandType = CommandEventType.CriterionRecognition;
  }

/*void serializeTo(QDataStream& stream) override {
CommandEvent::serializeTo(stream);

stream << static_cast<std::uint32_t>(criterionRecognition.size());
for (var cr : criterionRecognition) stream << cr;
}

void deserializeFrom(QDataStream& stream) override {
std::uint32_t size;
stream >> size;

for (unsigned int i = 0; i < size; ++i) {
std::uint32_t cr;
stream >> cr;
criterionRecognition.push_back(cr);
}
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! CriterionRecognitionCommandEvent) {
      return;
    }

    criterionRecognition = other.criterionRecognition;
  }

  @override
  BaseEvent clone() {
    var event = CriterionRecognitionCommandEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var loc = NumberFormat.decimalPattern();
    var tr = AppLocalizations.of(context)!;

    List<String> sl = [];
    for (var cr in criterionRecognition) {
      sl.add(loc.format(cr));
    }

    if (sl.isEmpty) sl.add(tr.questionSign);

//: %1 - array of two integer values
    return tr.recognCrit(sl.join(", "));
  }

  List<int> criterionRecognition = [];
}

enum AlarmsFilterCommandEventInterval {
  Undefined,
  Count1Per10Secs,
  Count2Per20Secs,
  Count3Per30Secs,
}

class AlarmsFilterCommandEvent extends CommandEvent {
  AlarmsFilterCommandEvent() {
    commandType = CommandEventType.AlarmsFilter;
  }

/*void serializeTo(QDataStream& stream) override {
CommandEvent::serializeTo(stream);

stream << humanThreshold << static_cast<std::uint32_t>(humanIntervalsCount);
stream << transportThreshold << static_cast<std::uint32_t>(transportIntervalsCount);
}

void deserializeFrom(QDataStream& stream) override {
std::uint32_t hic, tic;
stream >> humanThreshold >> hic;
stream >> transportThreshold >> tic;

humanIntervalsCount = static_cast<AlarmsFilterCommandEvent::Interval>(hic);
transportIntervalsCount = static_cast<AlarmsFilterCommandEvent::Interval>(tic);
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! AlarmsFilterCommandEvent) {
      return;
    }

    humanThreshold = other.humanThreshold;
    humanIntervalsCount = other.humanIntervalsCount;
    transportThreshold = other.transportThreshold;
    transportIntervalsCount = other.transportIntervalsCount;
  }

  @override
  BaseEvent clone() {
    var event = AlarmsFilterCommandEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var loc = NumberFormat.decimalPattern();
    var max = uInt32ErrorValue;
    var tr = AppLocalizations.of(context)!;

    var ht = humanThreshold != max ? loc.format(humanThreshold) : tr.questionSign;
    var tt = transportThreshold != max ? loc.format(transportThreshold) : tr.questionSign;

    var intervalStr = (AlarmsFilterCommandEventInterval interval) {
      switch (interval) {
        case AlarmsFilterCommandEventInterval.Count1Per10Secs:
          return tr.onePerTen;
        case AlarmsFilterCommandEventInterval.Count2Per20Secs:
          return tr.twoPerTwenty;
        case AlarmsFilterCommandEventInterval.Count3Per30Secs:
          return tr.threePerThirty;
        default:
          return tr.questionSign;
      }
    };

//: H - Human, T - Transport
    return tr.filter(ht, intervalStr(humanIntervalsCount), tt, intervalStr(transportIntervalsCount));
  }

  int humanThreshold = uInt32ErrorValue;
  AlarmsFilterCommandEventInterval humanIntervalsCount = AlarmsFilterCommandEventInterval.Undefined;
  int transportThreshold = uInt32ErrorValue;
  AlarmsFilterCommandEventInterval transportIntervalsCount = AlarmsFilterCommandEventInterval.Undefined;
}

class SNRCommandEvent extends CommandEvent {
  SNRCommandEvent() {
    commandType = CommandEventType.SNR;
  }

/*void serializeTo(QDataStream& stream) override {
CommandEvent::serializeTo(stream);

stream << snrValue;
}

void deserializeFrom(QDataStream& stream) override {
stream >> snrValue;
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! SNRCommandEvent) {
      return;
    }
    snrValue = other.snrValue;
  }

  @override
  BaseEvent clone() {
    var event = SNRCommandEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
    var loc = NumberFormat.decimalPattern();
    var max = uInt32ErrorValue;
    var tr = AppLocalizations.of(context)!;

    var snr = snrValue != max ? loc.format(snrValue) : tr.questionSign;

    return tr.snr(snr);
  }

  int snrValue = uInt32ErrorValue;
}

//#ifdef ADV_EXT_POWER
class AutoExtPowerCommandEvent extends CommandEvent {
  AutoExtPowerCommandEvent() {
    commandType = CommandEventType.AutoExtPower;
  }
/*
void serializeTo(QDataStream& stream) override {
CommandEvent::serializeTo(stream);

stream << static_cast<std::uint32_t>(state);
stream << delay_s << duration_s << reserve;
}

void deserializeFrom(QDataStream& stream) override {
std::uint32_t st;
stream >> st >> delay_s >> duration_s >> reserve;

state = static_cast<bool>(st);
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! AutoExtPowerCommandEvent) {
      return;
    }

    state = other.state;
    delay_s = other.delay_s;
    duration_s = other.duration_s;
    reserve = other.reserve;
  }

  @override
  BaseEvent clone() {
    var event = AutoExtPowerCommandEvent();
    event.copyFrom(this);
    return event;
  }

  @override
  String message(BuildContext context) {
/*var loc = NumberFormat.decimalPattern();
var max = uInt32ErrorValue;*/
    var tr = AppLocalizations.of(context)!;

/*var dl = delay_s != max ? loc.format(delay_s) : tr.questionSign;
var dr = duration_s != max ? loc.format(duration_s) : tr.questionSign;*/

    return tr.extPower(state ? tr.on : tr.off);
  }

  bool state = false;
  int delay_s = uInt32ErrorValue;
  int duration_s = uInt32ErrorValue;
  int reserve = uInt32ErrorValue;
}

//#ifdef RADIATION_MODULE
class RadiationThresholdCommandEvent extends CommandEvent {
  RadiationThresholdCommandEvent() {
    commandType = CommandEventType.RadiationThreshold;
  }

/*void serializeTo(QDataStream& stream) override {
CommandEvent::serializeTo(stream);

stream << moduleId << threshold;
}

void deserializeFrom(QDataStream& stream) override {
stream >> moduleId >> threshold;
}*/

  @override
  void copyFrom(BaseEvent other) {
    super.copyFrom(other);
    if (other is! RadiationThresholdCommandEvent) {
      return;
    }

    moduleId = other.moduleId;
    threshold = other.threshold;
  }

  @override
  BaseEvent clone() {
    var event = RadiationThresholdCommandEvent();
    event.copyFrom(this);
    return event;
  }

  String message(BuildContext context) {
    var loc = NumberFormat.decimalPattern();
    var maxInt = uInt32ErrorValue;
    var maxDouble = uInt32ErrorValue;
    var tr = AppLocalizations.of(context)!;

    String mid = "";
    if (moduleId == maxInt) {
      mid = tr.questionSign;
    } else if (moduleId == 0) {
      mid = tr.all;
    } else {
      mid = "#${loc.format(moduleId)}";
    }

    var th = threshold != maxDouble ? loc.format(threshold) : tr.questionSign;

    return tr.radTreshold(mid, th);
  }

  int moduleId = uInt32ErrorValue;
  double threshold = double.maxFinite;
}
