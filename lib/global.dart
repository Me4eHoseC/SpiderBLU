library projects.globals;
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/BluetoothPage.dart';
import 'package:projects/PackagesParser.dart';
import 'package:projects/PostManager.dart';
import 'package:projects/SeismicPage.dart';
import 'package:projects/DeviceParametersPage.dart';
import 'package:projects/ISTD.dart';
import 'package:projects/STDConnectionManager.dart';
import 'core/ItemsManager.dart';
import 'FileManager.dart';
import 'ImagePage.dart';
import 'PageWithMap.dart';
import 'main.dart';


String deviceName = 'HC-05-DMRS1', STDNum = '195';
String selectedPage = '', statusBarString = '', selectedDevice = '', deleteStr = '';

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

bool flagConnect = false, dataComeFlag = false, flagMapPage = true,
    flagCheckSPPU = false, allowedHopsCame = false, unallowedHopsCame = false,
    flagMoveMarker = false, transLang = false;

List<int> globalActiveDevices = List<int>.empty(growable: true),
    globalAlarmDevices = List<int>.empty(growable: true);

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

int testCounter = 0;