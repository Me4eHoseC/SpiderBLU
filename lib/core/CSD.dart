import '../radionet/NetPackagesDataTypes.dart';
import 'Marker.dart';
import 'RT.dart';

class CSD extends RT {
  int _alarmReasonMask = 0;
  int _humanSensitivity = 0;
  int _humanFreqThreshold = 50;
  int _transportSensitivity = 0;
  CriterionFilter _criterionFilter = CriterionFilter.FILTER_1_FROM_3;
  int _snr = 0;
  List<int> _recognitionParameters = [0, 0];

  bool _doPostAlarmPollFlag = false;

  double signalSwing = 0;

  bool seriesHumanFilterState = false;
  int seriesHumanFilterTreshold = 1;
  DateTime lastHumanAlarmDateTime = DateTime.now();
  int currentSeriesHumanIteration = 0;

  bool seriesTransportFilterState = false;
  int seriesTransportFilterTreshold = 1;
  DateTime lastTransportAlarmDateTime = DateTime.now();
  int currentSeriesTransportIteration = 0;

  bool isSeismicAlarmsMuted = false;
  bool isFirstSeismicAlarmMuted = false;

  @override
  void copyFrom(Marker other) {
    super.copyFrom(other);
    if (other is! CSD) {
      return;
    }
    _alarmReasonMask = other._alarmReasonMask;
    _humanSensitivity = other._humanSensitivity;
    _humanFreqThreshold = other._humanFreqThreshold;
    _transportSensitivity = other._transportSensitivity;
    _criterionFilter = other._criterionFilter;
    _snr = other._snr;
    _recognitionParameters = other._recognitionParameters;

    _doPostAlarmPollFlag = other._doPostAlarmPollFlag;

    signalSwing = other.signalSwing;

    seriesHumanFilterState = other.seriesHumanFilterState;
    seriesHumanFilterTreshold = other.seriesHumanFilterTreshold;
    lastHumanAlarmDateTime = other.lastHumanAlarmDateTime;
    currentSeriesHumanIteration = other.currentSeriesHumanIteration;

    seriesTransportFilterState = other.seriesTransportFilterState;
    seriesTransportFilterTreshold = other.seriesTransportFilterTreshold;
    lastTransportAlarmDateTime = other.lastTransportAlarmDateTime;
    currentSeriesTransportIteration = other.currentSeriesTransportIteration;

    isSeismicAlarmsMuted = other.isSeismicAlarmsMuted;
    isFirstSeismicAlarmMuted = other.isFirstSeismicAlarmMuted;
  }

  @override
  Marker clone() {
    var marker = CSD();
    marker.copyFrom(this);
    return marker;
  }

  static String Name([bool isTr = false]) {
    return isTr ? "CSD" : "CSD";
  }

  @override
  String typeName([bool isTr = false]) {
    return CSD.Name(isTr);
  }

  String criterionFilterName(CriterionFilter filter, bool isTr) {
    switch (filter) {
      case CriterionFilter.FILTER_1_FROM_3:
        return isTr ? "1 of 3" : "1 of 3";
      case CriterionFilter.FILTER_2_FROM_3:
        return isTr ? "2 of 3" : "2 of 3";
      case CriterionFilter.FILTER_3_FROM_3:
        return isTr ? "3 of 3" : "3 of 3";
      case CriterionFilter.FILTER_2_FROM_4:
        return isTr ? "2 of 4" : "2 of 4";
      case CriterionFilter.FILTER_3_FROM_4:
        return isTr ? "3 of 4" : "3 of 4";
      case CriterionFilter.FILTER_4_FROM_4:
        return isTr ? "4 of 4" : "4 of 4";
    }
  }

  int get alarmReasonMask => _alarmReasonMask;
  set alarmReasonMask(int alarmReasonMask) => _alarmReasonMask = alarmReasonMask;

  int get humanSensitivity => _humanSensitivity;
  set humanSensitivity(int humanSensitivity) => _humanSensitivity = humanSensitivity;

  int get humanFreqThreshold => _humanFreqThreshold;
  set humanFreqThreshold(int humanFreqThreshold) => _humanFreqThreshold = humanFreqThreshold;

  int get transportSensitivity => _transportSensitivity;
  set transportSensitivity(int transportSensitivity) => _transportSensitivity = transportSensitivity;

  CriterionFilter get criterionFilter => _criterionFilter;
  set criterionFilter(CriterionFilter filter) => _criterionFilter = filter;

  int get snr => _snr;
  set snr(int snr) => _snr = snr;

  List<int> get recognitionParameters => _recognitionParameters;
  set recognitionParameters(List<int> parameters) => _recognitionParameters = parameters;

  bool get doPostAlarmPollFlag => _doPostAlarmPollFlag;
  set doPostAlarmPollFlag(bool doPostAlarmPollFlag) => _doPostAlarmPollFlag = doPostAlarmPollFlag;
}
