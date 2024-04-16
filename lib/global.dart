library projects.globals;

import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projects/pages/DevicesTablePage.dart';
import 'package:projects/pages/ScanPage.dart';
import 'package:projects/radionet/PackageTypes.dart';

import '../std/ISTD.dart';
import '../std/STDConnectionManager.dart';

import '../core/ItemsManager.dart';

import '../radionet/FileManager.dart';
import '../radionet/PackagesParser.dart';
import '../radionet/PollManager.dart';
import '../radionet/PostManager.dart';
import '../radionet/BasePackage.dart';
import '../radionet/PackageProcessor.dart';

import '../pages/SettingsPage.dart';
import '../pages/SeismicPage.dart';
import '../pages/DeviceParametersPage.dart';
import '../pages/ImagePage.dart';
import '../pages/PageWithMap.dart';

import 'core/CPD.dart';
import 'core/NetDevice.dart';
import 'main.dart';

abstract class TIDManagement {
  final List<int> tits = [];
  Map<int, BasePackage> setRequests = {};

  bool isMyTransaction(int tid) {
    return tits.contains(tid);
  }

  void dataReceived(int tid, BasePackage basePackage) {}
  void acknowledgeReceived(int tid, BasePackage basePackage) {}

  void ranOutOfSendAttempts(int tid, BasePackage? pb) {}
}

String statusBarString = '';

Text mainBottomSelectedDev = Text('');
Timer? timer;

Widget list = Container();

final SettingsPage bluetoothPage = SettingsPage();
final PageWithMap pageWithMap = PageWithMap();
final DeviceParametersPage deviceParametersPage = DeviceParametersPage();
final ImagePage imagePage = ImagePage();
final SeismicPage seismicPage = SeismicPage();
final ScanPage scanPage = ScanPage();
final DevicesTablePage devicesTablePage = DevicesTablePage();

enum SendingState {
  defaultState,
  sendingState,
  notAnswerState,
}

enum ParametersGroup {
  //main
  dateTime,
  firmwareVersion,
  //coordinates
  coordinates,
  //radio
  signalStrength,
  allowedHops,
  unallowedHops,
  rebroadcastToEveryone,
  //connected devices
  onOffInDev,
  deviceStatus,
  //External power
  safetyCatch,
  switchingBreak,
  power,
  //power supply
  powerSupply,
  //camera
  cameraSettings,
  //seismic
  humanTransport,
  snr,
  humSens,
  autoSens,
  critFilter,
  ratioSign,
  recogParam,
  alarmFilter,
  //MCD
  priority,
  gps,
  //AIRS
  tresholdIRS,
  //TODO: save/reset settings???
}

//List<String> ParametersGroup = ['dateTime', 'firmwareVersion'];

Map<int, Map<ParametersGroup, SendingState>> sendingState = {};

void initSendingState(int devId) {
  Map<ParametersGroup, SendingState> init = {
    ParametersGroup.dateTime: SendingState.defaultState,
    ParametersGroup.firmwareVersion: SendingState.defaultState,
    ParametersGroup.coordinates: SendingState.defaultState,
    ParametersGroup.signalStrength: SendingState.defaultState,
    ParametersGroup.allowedHops: SendingState.defaultState,
    ParametersGroup.unallowedHops: SendingState.defaultState,
    ParametersGroup.rebroadcastToEveryone: SendingState.defaultState,
    ParametersGroup.onOffInDev: SendingState.defaultState,
    ParametersGroup.deviceStatus: SendingState.defaultState,
    ParametersGroup.safetyCatch: SendingState.defaultState,
    ParametersGroup.switchingBreak: SendingState.defaultState,
    ParametersGroup.power: SendingState.defaultState,
    ParametersGroup.powerSupply: SendingState.defaultState,
    ParametersGroup.cameraSettings: SendingState.defaultState,
    ParametersGroup.humanTransport: SendingState.defaultState,
    ParametersGroup.snr: SendingState.defaultState,
    ParametersGroup.humSens: SendingState.defaultState,
    ParametersGroup.autoSens: SendingState.defaultState,
    ParametersGroup.critFilter: SendingState.defaultState,
    ParametersGroup.ratioSign: SendingState.defaultState,
    ParametersGroup.recogParam: SendingState.defaultState,
    ParametersGroup.alarmFilter: SendingState.defaultState,
    ParametersGroup.priority: SendingState.defaultState,
    ParametersGroup.gps: SendingState.defaultState,
    ParametersGroup.tresholdIRS: SendingState.defaultState,
  };
  sendingState[devId] = init;
}

final List<StatefulWidget> pages = [
  bluetoothPage,
  pageWithMap,
  devicesTablePage,
  deviceParametersPage,
  imagePage,
  seismicPage,
  scanPage,
];

PackageProcessor packageProcessor = PackageProcessor();
PackagesParser packagesParser = PackagesParser();

FileManager fileManager = FileManager();

PostManager postManager = PostManager();
STDConnectionManager stdConnectionManager = STDConnectionManager();

PollManager pollManager = PollManager();

ISTD? std;
StdInfo stdInfo = StdInfo();

class Pair<T1, T2> {
  T1 first;
  T2 second;

  Pair(this.first, this.second);
}

bool flagConnect = false, flagMapPage = true, flagCheckSPPU = false, flagMoveMarker = false, transLang = false;

Map<int, MapMarker> listMapMarkers = {};

List<int> retransmissionRequests = [];
List<int> stdHopsCheckRequests = [];

List<int> delayList = [60, 180, 300];
List<int> impulseList = [1, 2, 3];
List<String> deviceTypeList = [];
List<String> photoCompression = ["Min", "Low", "Mid", "High", "Max"];
List<String> critFilter = ['1 of 3', '2 of 3', '3 of 3', '2 of 4', '3 of 4', '4 of 4'];
List<int> serialHuman = [1, 2, 3];
List<int> serialTransport = [1, 2, 3];
GlobalKey<HomePageState> globalKey = GlobalKey<HomePageState>();
ItemsManager itemsMan = ItemsManager();

const int baseFrequency = 432999960; // Hz
const int channelFrequencyStep = 1999946; // Hz
const int reserveFrequencyOffset = 2999980; // Hz

Directory pathToProject = Directory('/storage/emulated/0/SpiderNet/com.example.projects/files');

class SettingsForSave {
  bool btFlag = true;
  String? btMacAddressSave;

  bool serialFlag = true;
  String? serialManNameSave;
  int? serialVIDSave;

  bool tcpFlag = true;
  String? IPAddressSave;
  int? IPPortSave;

  SettingsForSave(this.btFlag, this.btMacAddressSave, this.serialFlag, this.serialManNameSave, this.serialVIDSave, this.tcpFlag,
      this.IPAddressSave, this.IPPortSave);

  factory SettingsForSave.fromJson(Map<String, Object?> jsonMap) {
    return SettingsForSave(
        jsonMap["btFlag"] as bool,
        jsonMap["btMacAddressSave"] as String,
        jsonMap["serialFlag"] as bool,
        jsonMap["serialManNameSave"] as String,
        jsonMap["serialVIDSave"] as int,
        jsonMap["tcpFlag"] as bool,
        jsonMap["IPAddressSave"] as String,
        jsonMap["IPPortSave"] as int);
  }

  Map toJson() => {
    'btFlag': btFlag,
    'btMacAddressSave': btMacAddressSave,
    'serialFlag': serialFlag,
    'serialManNameSave': serialManNameSave,
    'serialVIDSave': serialVIDSave,
    'tcpFlag': tcpFlag,
    'IPAddressSave': IPAddressSave,
    'IPPortSave': IPPortSave,
  };
}

void getPermission() async {
  var status1 = await Permission.storage.status;
  var status2 = await Permission.manageExternalStorage.status;
  if (!status1.isGranted || !status2.isGranted) {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }
}

void stopMedia() {
  print('CANCEL DOWNLOAD');
  var selected = itemsMan.getSelected<NetDevice>();
  if (selected == null) return;
  var type = PackageType.STOP_SEISMIC_WAVE;
  if (selected is CPD) {
    type = PackageType.STOP_PHOTO;
  }
  var tid = postManager.sendPackage(BasePackage.makeBaseRequest(selected.id, type));
  if (tid == -1) return;
}
