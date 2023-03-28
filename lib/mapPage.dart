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
  int? deviceId,
      alarmCounter,
      deviceVersion,
      deviceStateMask,
      deviceState,
      deviceRssi,
      deviceMaskExtDevice,
      deviceMaskPeriphery,
      deviceExternalPower;
  LatLng? deviceCord;
  DateTime? deviceTime, deviceLastAlarmTime;
  AlarmType? deviceLastAlarmType;
  AlarmReason? deviceLastAlarmReason;
  double? deviceVoltage, deviceTemperature, deviceBattery;
  List<int>? deviceAllowedHops, deviceRetransmissionToAll, deviceUnallowedHops;
  String? deviceType;
  bool extDevice1 = false,
      extDevice2 = false,
      devicePhototrap = false,
      deviceGeophone = false,
      seismicAlarmsMuted = false,
      firstSeismicAlarmMuted = false,
      deviceExtDev1State = false,
      deviceExtDev2State = false,
      deviceExtPhototrapState = false,
      deviceAvailable = false,
      deviceReturnCheck = false,
      deviceAlarm = false;
  Color backColor = Colors.blue;
  Timer? timer;
  //var
}

class MapMarker extends Marker {
  _mapPage? parent;
  int markerId = -1;
  MarkerData markerData;
  Color colorBack = Colors.blue;

  MapMarker(this.parent, this.markerId, this.markerData, LatLng cord,
      String string, String deviceType, this.colorBack)
      : super(
            height: 50,
            width: 50,
            point: cord,
            builder: (ctx) => TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: markerData.backColor,
                  ),
                  onPressed: () =>
                      {parent?.selectMapMarker(markerId, cord, string)},
                  child: Text(
                    string + '\n' + deviceType,
                    style: TextStyle(
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ));
}

class mapPage extends StatefulWidget {
  @override
  createState() => _mapPage();
}

class _mapPage extends State<mapPage>
    with AutomaticKeepAliveClientMixin<mapPage> {

  @override
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
  List<String> deviceTypeList = ["СППУ", "РТ", "КСД", "КФУ"];
  Widget bottomBarWidget = Container(height: 0);
  bool flagSenderDevice = false;
  MapMarker? bufferMarker;
  String? chooseDeviceType;


  @override
  void initState() {
    chooseDeviceType = deviceTypeList[0];
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        for (int i = 0; i < global.globalMapMarker.length; i++) {
          if (global.globalMapMarker[i].markerData.deviceAlarm){
            global.globalMapMarker[i].markerData.backColor = Colors.red;
            global.globalMapMarker[i].markerData.deviceAvailable = true;
            global.globalMapMarker[i].markerData.timer!.cancel();
          }
          if (global.globalMapMarker[i].markerData.deviceAvailable &&
              global.globalMapMarker[i].markerData.deviceAlarm == false &&
              global.globalMapMarker[i].markerData.timer == null) {
            global.globalMapMarker[i].markerData.backColor = Colors.green;
            startTimer(i);
          }
          if (global.globalMapMarker[i].markerData.deviceAvailable &&
              global.globalMapMarker[i].markerData.deviceAlarm == false &&
              global.globalMapMarker[i].markerData.timer != null &&
              global.globalMapMarker[i].markerData.deviceReturnCheck == true) {
            global.globalMapMarker[i].markerData.backColor = Colors.green;
            global.globalMapMarker[i].markerData.timer!.cancel();
            startTimer(i);
          }
        }
        location.getLocation().then((p) {
          myCoords = LatLng(p.latitude!, p.longitude!);
        });
      });
    });
  }

  void startTimer(int id) {
    setState(() {
      global.globalMapMarker[id].markerData.deviceReturnCheck = false;
        global.globalMapMarker[id].markerData.timer =
            Timer(Duration(seconds: 10), () {
              global.globalMapMarker[id].markerData.backColor = Colors.blue;
              global.globalMapMarker[id].markerData.deviceAvailable = false;
              global.globalMapMarker[id].markerData.deviceReturnCheck = false;
              global.globalMapMarker[id].markerData.timer = null;
            });
    });
  }

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

  void createNewMapMarker(int id, bool flag, String deviceType) {
    setState(() {
      markerIndex++;
      createMarkerData(id, deviceType);
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
          markerData[markerIndex].deviceType!,
          colorBack);
      global.globalMapMarker.add(localMarker);
      global.globalDevicesListFromMap.add(id.toString());
      changeBottomBarWidget(-1, null, null, null);
    });
  }

  void createMarkerData(int id, String deviceType) {
    setState(() {
      MarkerData data = MarkerData();
      markerData.add(data);
      markerData[markerIndex].deviceId = id;
      markerData[markerIndex].deviceCord = currentLocation;
      markerData[markerIndex].deviceType = deviceType;
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
          createNewMapMarker(id, flagSenderDevice, chooseDeviceType!);
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
            createNewMapMarker(id, flagSenderDevice, chooseDeviceType!);
          }
        }
        //for (int i = 0; i < idMarkersFromBluetooth )
      } else {
        showError();
      }
    });
  }

  void addNewDeviceOnMap() {
    setState(() {
      bottomBarWidget = SizedBox(
        height: 150,
        child: Column(children: [
          SizedBox(
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
          ),
          DropdownButton<String>(
            icon: const Icon(Icons.keyboard_double_arrow_down),
            onChanged: (String? value) {
              chooseDeviceType = value!;
              print(chooseDeviceType);
              addNewDeviceOnMap();
            },
            value: chooseDeviceType,
            items: deviceTypeList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ]),
      );
    });
  }

  void changeBottomBarWidget(
      int counter, int? markerId, LatLng? cord, String? string) {
    setState(() {
      if (counter == 0) {
        addNewDeviceOnMap();
      }

      if (counter == -1) {
        bottomBarWidget = Container(
          height: 0.0,
        );
      }

      if (counter == 1) {
        bottomBarWidget = Container(
          height: 80,
          child: Row(
            children: [
              Text(global.globalMapMarker[markerId!].markerData.deviceTime
                  .toString()),
              Text(global.globalMapMarker[markerId].markerData.deviceType
                  .toString()),
              IconButton(
                  onPressed: () => {
                        changeBottomBarWidget(-1, null, null, null),
                        global.globalMapMarker[markerId].markerData
                            .deviceAlarm = false,
                      },
                  icon: Icon(Icons.power_settings_new))
            ],
          ),
        );
      }
    });
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
          minZoom: 1.0,
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
      floatingActionButton: Builder(builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Icon(
                Icons.menu,
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
            FloatingActionButton(
              onPressed: changeMapRotation,
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.red,
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: BottomAppBar(
        child: bottomBarWidget,
      ),
    );
  }
}
