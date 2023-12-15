library projects.globals;
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/BluetoothPage.dart';
import 'package:projects/PackagesParser.dart';
import 'package:projects/PostManager.dart';
import 'package:projects/TestPage.dart';
import 'package:projects/core/Device.dart';
import 'package:projects/ISTD.dart';
import 'package:projects/STDConnectionManager.dart';
import 'core/ItemsManager.dart';
import 'FileManager.dart';
import 'ImagePage.dart';
import 'PageWithMap.dart';
import 'main.dart';


const String deviceName = 'HC-05-DMRS1';
String selectedPage = '', statusBarString = '', selectedDevice = '', deleteStr = '';
//int  selectedMapMarkerIndex = -1;

Text mainBottomSelectedDev = Text('');
Timer? timer;

Widget list = Container();

final BluetoothPage bluetoothPage = BluetoothPage();
final PageWithMap pageWithMap = PageWithMap();
final TestPage testPage = TestPage();
final ImagePage imagePage = ImagePage();

//final AlarmCounterPage alarmCounterPage = AlarmCounterPage();

final List<StatefulWidget> pages = [
  bluetoothPage,
  pageWithMap,
  testPage,
  imagePage,
];

PackagesParser packagesParser = PackagesParser();

FileManager fileManager = FileManager();

PostManager postManager = PostManager();
STDConnectionManager stdConnectionManager = STDConnectionManager();

ISTD? std;

class Pair<T1, T2> {
  T1 first;
  T2 second;

  Pair(this.first, this.second);
}

//List<String> globalDevicesListFromMap = [];

bool flagConnect = false, dataComeFlag = false, flagMapPage = false,
    flagCheckSPPU = false, allowedHopsCame = false, unallowedHopsCame = false,
    flagMoveMarker = false;

List<int> globalActiveDevices = List<int>.empty(growable: true),
    globalAlarmDevices = List<int>.empty(growable: true);

Map<int, MapMarker> listMapMarkers = {};

//List<MapMarker> globalMapMarker = List<MapMarker>.empty(growable: true);
List<int> retransmissionRequests = List<int>.empty(growable: true);
List<int> delayList = [60, 180, 300];
List<int> impulseList = [1, 2, 3];
List<String> deviceTypeList = ["STD", "CSD", "CPD", "RT"];
List<String> photoCompression = ["Min", "Low", "Mid", "High", "Max"];
List<int> serialHuman = [1, 2, 3];
List<int> serialTransport = [1, 2, 3];
GlobalKey<HomePageState> globalKey = GlobalKey<HomePageState>();
Device bufDevice = Device();
ItemsManager itemsManager = ItemsManager();

int testCounter = 0;