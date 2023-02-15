import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import 'global.dart' as global;

class MarkerData {
  int? deviceId;
  int? alarmCounter;
  LatLng? deviceCord;
}

