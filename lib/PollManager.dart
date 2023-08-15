import 'dart:async';

import 'BasePackage.dart';
import 'NetCommonPackages.dart';

class PollManager {
  late void Function(PollType pollType) pollStarted;
  late void Function(PollType pollType) pollFinished;
  late void Function(int deviceId, bool isOnline) deviceStatusChanged;
  late void Function(int stdId) checkAndRebootStd;

  static const int _InitPollAttemptsNumber = 6,
      _SavePollAttemptsNumber = 12,
      _RegularPollAttemptsNumber = 12,
      _OfflineDevicesPollAttemptsNumber = 4,
      _AfterAlarmPollAttemptsNumber = 12,
      _StdPollAttemptsNumber = 4;

  Map<int, PollType> pollIds = {};

  Map<int,int> stdPollRounds = {};
  static const int StdPollRoundsNumber = 3;

  static const int deviceInactivityIntervalMs = 25 * 60 * 1000; // 25 minutes

  static const int stdPollIntervalMs = 30700; // 30.7 seconds
  static const int regularPollIntervalMs = 2 * 60 * 60 * 1000; // 2 hours
  static const int offlineDevicesPollIntervalMs = 20 * 60 * 1000; // 20 minutes

}

enum PollType {
  InitPoll,
  SavePoll,
  RegualrPoll,
  OfflineDevicesPoll,
  AfterAlarmPoll,
  StdPoll;
}

String pollTypeToName(PollType pollType) {
  switch (pollType) {
    case PollType.RegualrPoll:
      return "Regular poll";
    case PollType.InitPoll:
      return "Init poll";
    case PollType.SavePoll:
      return "Save poll";
    case PollType.AfterAlarmPoll:
      return "Alarm poll";
    case PollType.OfflineDevicesPoll:
      return "Offline poll";
    case PollType.StdPoll:
      return "STD poll";
    default:
      return "";
  }
}
