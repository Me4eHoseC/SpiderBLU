
class DeviceState {
  static const int MONITOR_SEISMIC = 1 << 0;
  static const int MONITORING_LINE1 = 1 << 1;
  static const int MONITORING_LINE2 = 1 << 2;
  static const int LINES_CAMERA_TRAP = 1 << 3;
  static const int SEISMIC_CAMERA_TRAP = 1 << 4;
  static const int MODEM_AMPLIFIER = 1 << 5;
  static const int DEBUGGER = 1 << 6;
  static const int PLAYER = 1 << 7;
}

enum AlarmType{
  NO,
  SEISMIC,
  LINE1,
  LINE2,
  BATTERY,
  TRAP,
  RADIATION;
}

enum AlarmReason{
  UNKNOWN,
  INTERFERENCE,
  FAR_TARGET,
  HUMAN,
  AUTO,
  BATTERY,

  NUM,
  LFO,
}

class AlarmReasonMask {
  static final int UNKNOWN = 1 << AlarmReason.UNKNOWN.index;
  static final int INTERFERENCE = 1 << AlarmReason.INTERFERENCE.index;
  static final int FAR_TARGET = 1 << AlarmReason.FAR_TARGET.index;
  static final int HUMAN = 1 << AlarmReason.HUMAN.index;
  static final int AUTO = 1 << AlarmReason.AUTO.index;
  static final int BATTERY = 1 << AlarmReason.BATTERY.index;
}

enum ExternalPower{
  OFF,
  ON;
}

enum BatteryState{
  BAD,
  NORMAL;
}

class PeripheryMask{
  static const int LINE1 = 1 << 0;
  static const int LINE2 = 1 << 0;
  static const int AUDIO = 1 << 0;
  static const int CAMERA = 1 << 0;
}

class YellowAlarm{
  static const int NUMBER_MIN = 2;
  static const int NUMBER_MAX = 30;
  static const int TIME_MIN = 1;
  static const int TIME_MAX = 60;
}

enum PhotoImageSize{
  IMAGE_160X120,
  IMAGE_320X240,
  IMAGE_640X480,
  IMAGE_SIZE_TRAP;
}

enum CriterionFilter{
  FILTER_1_FROM_3,
  FILTER_2_FROM_3,
  FILTER_3_FROM_3,
  FILTER_2_FROM_4,
  FILTER_3_FROM_4,
  FILTER_4_FROM_4;
}

enum DeviceType{
  SENSOR,
  MASTER;
}