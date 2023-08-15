library projects.globals;
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/BluetoothPage.dart';
import 'package:projects/PackagesParser.dart';
import 'package:projects/PostManager.dart';
import 'package:projects/TestPage.dart';
import 'package:projects/core/Uint8Vector.dart';
import 'package:projects/mapPage.dart';
import 'package:projects/ISTD.dart';
import 'package:projects/STDConnectionManager.dart';

import 'FileManager.dart';
import 'ImagePage.dart';


const String deviceName = 'HC-05-DMRS1';
String selectedPage = '', statusBarString = '', selectedDevice = '', deleteStr = '';
int selectedDeviceID = -1, deviceIDChanged = -1, deleteId = -1;

Text mainBottomSelectedDev = Text('');
Timer? timer;

Widget list = Container();

final BluetoothPage bluetoothPage = BluetoothPage();
final mapPage mapClass = mapPage();
final TestPage testPage = TestPage();
ImagePage imagePage = ImagePage();

final List<StatefulWidget> pages = [
  bluetoothPage,
  mapClass,
  testPage,
  imagePage
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

List<String> globalDevicesListFromMap = [];

bool flagConnect = false, dataComeFlag = false, flagMapPage = false,
    flagCheckSPPU = false, allowedHopsCame = false, flagDeleteMarker = false;

List<int> globalActiveDevices = List<int>.empty(growable: true),
    globalAlarmDevices = List<int>.empty(growable: true);

List<MapMarker> globalMapMarker = List<MapMarker>.empty(growable: true);
List<int> retransmissionRequests = List<int>.empty(growable: true);
List<String> deviceTypeList = ["СППУ", "РТ", "КСД", "КФУ"];
var photoTest = Uint8Vector(0);
