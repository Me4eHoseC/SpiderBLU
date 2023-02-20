import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:projects/NetPackagesDataTypes.dart';

import 'global.dart' as global;

class MarkerData {
  int? deviceId, alarmCounter, deviceVersion, deviceStateMask, deviceState,
      deviceRssi;
  LatLng? deviceCord;
  DateTime? deviceTime, deviceLastAlarmTime;
  AlarmType? deviceLastAlarmType;
  AlarmReason? deviceLastAlarmReason;
  double? deviceBattery;
  List<int>? deviceAllowedHops, deviceUnallowedHops;
  //var
}

class MapMarker extends Marker {
  _mapPage? parent;
  int markerId = -1;
  MarkerData markerData;
  Color colorBack = Colors.blue;

  MapMarker(this.parent, this.markerId, this.markerData, LatLng cord,
      String string, this.colorBack)
      : super(
            height: 40,
            width: 40,
            point: cord,
            builder: (ctx) => TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: colorBack,
                  ),
                  onPressed: () =>
                      {parent?.selectMapMarker(markerId, cord, string)},
                  child: Text(string),
                ));
}

class mapPage extends StatefulWidget {
  @override
  createState() => _mapPage();
}

class _mapPage extends State<mapPage>
    with AutomaticKeepAliveClientMixin<mapPage> {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  int markerIndex = -1, alarmMarkerIndex = -1;

  Location location = Location();
  LatLng? myCoords, currentLocation, alarmLocation;
  Timer? timer;
  MapController mapController = MapController();
  List<MarkerData> markerData = [];
  List<int> idMarkersForCheck = List<int>.empty(growable: true),
      idMarkersFromBluetooth = List<int>.empty(growable: true),
      alarmList = List<int>.empty(growable: true);
  Widget bottomBarWidget = Container(height: 0);
  bool flagSenderDevice = false;
  MapMarker? bufferMarker;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        location.getLocation().then((p) {
          myCoords = LatLng(p.latitude!, p.longitude!);
        });
      });
    });
  }

  void dispose() {
    timer!.cancel();
  }

  /*void checkAlarm() {
    setState(() {
      if (alarmList.isNotEmpty) {
        for (int i = 0; i < alarmList.length; i++) {
          for (int j = 0; j < marker.length; j++) {
            if (marker[j].markerData.deviceId == alarmList[i]) {
              alarmLocation = marker[j].markerData.deviceCord;
              alarmMarkerIndex = marker[j].markerId;
              marker.removeAt(alarmMarkerIndex);
              marker.insert(
                  alarmMarkerIndex,
                  MapMarker(
                      this,
                      alarmMarkerIndex,
                      markerData[alarmMarkerIndex],
                      alarmLocation!,
                      markerData[alarmMarkerIndex].deviceId.toString(),
                      Colors.red));
              alarmList.remove(alarmList[i]);
              break;
            }
          }
        }
      }
    });
  }*/

  void changeMapRotation() {
    setState(() {
      mapController.rotate(0.0);
    });
  }

  void findMyPosition() {
    setState(() {
      mapController.moveAndRotate(myCoords!, 17, 0.0);
    });
  }

  void selectMapMarker(int markerId, LatLng cord, String string) {
    changeBottomBarWidget(1, markerId, cord, string);
  }

  void openBottomMenu(var tap, LatLng cord) {
    setState(() {
      changeBottomBarWidget(0, null, null, null);
      currentLocation = cord;
    });
  }

  void createNewMapMarker(int id, bool flag) {
    setState(() {
      markerIndex++;
      createMarkerData(id);
      Color colorBack = Colors.blue;
      if (flag) {
        colorBack = Colors.green;
      } else {
        colorBack = Colors.blue;
      }
      var localMarker = MapMarker(
          this,
          markerIndex,
          markerData[markerIndex],
          markerData[markerIndex].deviceCord!,
          markerData[markerIndex].deviceId.toString(),
          colorBack);
      global.globalMapMarker.add(localMarker);
      global.globalDevicesListFromMap.add(id.toString());
      changeBottomBarWidget(-1, null, null, null);
    });
  }

  void createMarkerData(int id) {
    setState(() {
      MarkerData data = MarkerData();
      markerData.add(data);
      markerData[markerIndex].deviceId = id;
      markerData[markerIndex].deviceCord = currentLocation;
    });
  }

  void showError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Incorrect id'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'))
          ],
        );
      },
    );
    changeBottomBarWidget(-1, null, null, null);
  }

  void checkCorrectID(String num) {
    setState(() {
      flagSenderDevice = false;
      bool flag = false;
      int id = int.parse(num);
      if (id > 0 && id < 999) {
        if (global.globalMapMarker.isEmpty) {
          createNewMapMarker(id, flagSenderDevice);
        } else {
          for (int i = 0; i < global.globalMapMarker.length; i++) {
            if (global.globalMapMarker[i].markerData.deviceId == id) {
              flag = false;
              showError();
              break;
            }
            if (i + 1 == global.globalMapMarker.length) {
              flag = true;
            }
          }
          if (flag) {
            createNewMapMarker(id, flagSenderDevice);
          }
        }
        //for (int i = 0; i < idMarkersFromBluetooth )
      } else {
        showError();
      }
    });
  }

  void changeBottomBarWidget(
      int counter, int? markerId, LatLng? cord, String? string) {
    setState(() {
      if (counter == 0) {
        bottomBarWidget = SizedBox(
          height: 100,
          child: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              icon: Icon(Icons.developer_board),
              labelText: 'Device ID',
              hintText: '',
              helperText: 'Input device ID',
            ),
            onSubmitted: checkCorrectID,
          ),
        );
      }

      if (counter == -1) {
        bottomBarWidget = Container(
          height: 0.0,
        );
      }

      if (counter == 1) {
        bottomBarWidget = Container(
          height: 200,
          child: Row(
            children: [
              Text(global.globalMapMarker[markerId!].markerData.deviceTime
                  .toString()),
              IconButton(
                  onPressed: () =>
                      {changeBottomBarWidget(-1, null, null, null)},
                  icon: Icon(Icons.power_settings_new))
            ],
          ),
        );
      }
    });
  }

  void checkMarkerColor(int id) {
    for (int i = 0; i < idMarkersFromBluetooth.length; i++) {
      if (idMarkersFromBluetooth[i] == id) {
        flagSenderDevice = true;
        break;
      }
      if (i + 1 == idMarkersFromBluetooth.length) {
        flagSenderDevice = false;
      }
    }
  }

  Widget build(BuildContext context) {
    if (myCoords == null) {
      return Container();
    }

    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: myCoords,
          zoom: 17.0,
          maxZoom: 18.0,
          minZoom: 5.0,
          onLongPress: openBottomMenu,
        ),
        mapController: mapController,
        layers: [
          TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          MarkerLayerOptions(markers: global.globalMapMarker),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: changeMapRotation,
            child: const Icon(
              Icons.arrow_upward,
              color: Colors.red,
            ),
          ),
          FloatingActionButton(
            onPressed: findMyPosition,
            child: const Icon(
              Icons.location_searching,
              color: Colors.red,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: bottomBarWidget,
      ),
    );
  }
}
