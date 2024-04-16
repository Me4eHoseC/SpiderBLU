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

enum AlarmType {
  NO,
  SEISMIC,
  LINE1,
  LINE2,
  BATTERY,
  TRAP,
  RADIATION,
  EXT_POWER_SAFETY_CATCH_OFF,
  AUTO_EXT_POWER_TRIGGERED;
}

enum AlarmReason {
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

enum ExternalPower {
  OFF,
  ON;
}

enum BatteryState {
  BAD,
  NORMAL;
}

class PeripheryMask {
  static const int LINE1 = 1 << 0;
  static const int LINE2 = 1 << 1;
  static const int AUDIO = 1 << 2;
  static const int CAMERA = 1 << 3;
  static const int IRS = 1 << 4;
}

class YellowAlarm {
  static const int NUMBER_MIN = 2;
  static const int NUMBER_MAX = 30;
  static const int TIME_MIN = 1;
  static const int TIME_MAX = 60;
}

enum PhotoImageSize {
  IMAGE_160X120,
  IMAGE_320X240,
  IMAGE_640X480,
  IMAGE_SIZE_TRAP;
}

enum PhotoImageCompression {
  MINIMUM,
  LOW,
  MEDIUM,
  HIGH,
  MAXIMUM;
}

int castFromCompression(PhotoImageCompression compression, PhotoImageSize size) {
  switch (compression) {
    case PhotoImageCompression.MINIMUM: return size == PhotoImageSize.IMAGE_640X480 ? 40 : 0;
    case PhotoImageCompression.LOW: return 80;
    case PhotoImageCompression.MEDIUM: return 130;
    case PhotoImageCompression.HIGH: return 180;
    case PhotoImageCompression.MAXIMUM: return 255;
    default: return 180;
  }
}

PhotoImageCompression castToCompression(int compression) {
  if (compression <= 40) return PhotoImageCompression.MINIMUM;
  else if (compression <= 80) return PhotoImageCompression.LOW;
  else if (compression <= 130) return PhotoImageCompression.MEDIUM;
  else if (compression <= 180) return PhotoImageCompression.HIGH;
  else return PhotoImageCompression.MAXIMUM;
}

enum CriterionFilter {
  FILTER_1_FROM_3,
  FILTER_2_FROM_3,
  FILTER_3_FROM_3,
  FILTER_2_FROM_4,
  FILTER_3_FROM_4,
  FILTER_4_FROM_4;
}

enum SlaveModel {
  SENSOR,
  MASTER;
}

enum ErrorCodes {
  AEP_SAFETY_CATCH_BLOCKED,
  AEP_NO_BRAKELINES,
  AEP_BRAKELINES_STATE,
  AEP_EXT_POW_DISABLE,
  AEP_CHANGING_DISABLE,
  AEP_AEP_ONLY_SAFETY_CATCHED;
}
