library projects.globals;
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../std/ISTD.dart';
import '../std/STDConnectionManager.dart';

import '../core/ItemsManager.dart';

import '../radionet/FileManager.dart';
import '../radionet/PackagesParser.dart';
import '../radionet/PollManager.dart';
import '../radionet/PostManager.dart';
import '../radionet/BasePackage.dart';
import '../radionet/PackageProcessor.dart';

import '../pages/BluetoothPage.dart';
import '../pages/SeismicPage.dart';
import '../pages/DeviceParametersPage.dart';
import '../pages/ImagePage.dart';
import '../pages/PageWithMap.dart';

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

String deviceName = 'HC-05-DMRS1', STDNum = '195';
String statusBarString = '';

Text mainBottomSelectedDev = Text('');
Timer? timer;

Widget list = Container();

final BluetoothPage bluetoothPage = BluetoothPage();
final PageWithMap pageWithMap = PageWithMap();
final DeviceParametersPage deviceParametersPage = DeviceParametersPage();
final ImagePage imagePage = ImagePage();
final SeismicPage seismicPage = SeismicPage();


final List<StatefulWidget> pages = [
  bluetoothPage,
  pageWithMap,
  deviceParametersPage,
  imagePage,
  seismicPage,
];

PackageProcessor packageProcessor = PackageProcessor();
PackagesParser packagesParser = PackagesParser();

FileManager fileManager = FileManager();

PostManager postManager = PostManager();
STDConnectionManager stdConnectionManager = STDConnectionManager();

PollManager pollManager = PollManager();

ISTD? std;

class Pair<T1, T2> {
  T1 first;
  T2 second;

  Pair(this.first, this.second);
}

bool flagConnect = false, flagMapPage = true,
    flagCheckSPPU = false, flagMoveMarker = false, transLang = false;

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

const int baseFrequency = 432999960;         // Hz
const int channelFrequencyStep = 1999946;    // Hz
const int reserveFrequencyOffset = 2999980;  // Hz

Directory pathToProject = Directory('/storage/emulated/0/SpiderNet/com.example.projects/files');

void getPermission() async {
  var status1 = await Permission.storage.status;
  var status2 = await Permission.manageExternalStorage.status;
  if (!status1.isGranted || !status2.isGranted) {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }
}