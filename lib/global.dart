library projects.globals;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/BluetoothPage.dart';
import 'package:projects/PackagesParser.dart';
import 'package:projects/PostManager.dart';
import 'package:projects/TestPage.dart';
import 'package:projects/mapPage.dart';
import 'package:projects/ISTD.dart';
import 'package:projects/STDConnectionManager.dart';


const String deviceName = 'HC-05-DMRS1';

BluetoothPage bluetoothPage = BluetoothPage();
mapPage mapClass = mapPage();
TestPage testPage = TestPage();

List<StatefulWidget> pages = [
  bluetoothPage,
  mapClass,
  testPage
];

PackagesParser packagesParser = PackagesParser();
PostManager postManager = PostManager();
STDConnectionManager stdConnectionManager = STDConnectionManager();

ISTD? std;

class Pair<T1, T2> {
  T1 first;
  T2 second;

  Pair(this.first, this.second);
}

List<String> globalDevicesListFromMap = [];

bool flagConnect = false;

List<int> globalActiveDevices = List<int>.empty(growable: true),
    globalAlarmDevices = List<int>.empty(growable: true);

List<MapMarker> globalMapMarker = List<MapMarker>.empty(growable: true);
List<int> retransmissionRequests = List<int>.empty(growable: true);
