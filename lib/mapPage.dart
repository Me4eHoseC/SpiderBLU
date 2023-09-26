import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:projects/NetPackagesDataTypes.dart';
import 'package:projects/RoutesManager.dart';
import 'package:projects/core/Device.dart';
import 'package:projects/main.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'AllEnum.dart';
import 'NetPhotoPackages.dart';
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
      deviceExternalPower,
      deviceHumanSensitivity,
      deviceTransportSensitivity;
  LatLng? deviceCord;
  DateTime? deviceTime, deviceLastAlarmTime;
  AlarmType? deviceLastAlarmType;
  AlarmReason? deviceLastAlarmReason;
  double? deviceVoltage, deviceTemperature, deviceBattery, deviceSignalSwing;
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
      humanAlarm = false,
      transportAlarm = false,
      deviceAlarm = false;
  Color backColor = Colors.blue;
  Timer? timer;
  //var
}

class Example {
  Example(this.time, this.seisma);
  final int time, seisma;
}

class MapMarker extends Marker {
  _mapPage? parent;
  int markerId = -1;
  MarkerData markerData;
  Color colorBack = Colors.blue;
  String deviceId;
  String deviceType;
  Timer? timer;

  MapMarker(this.parent, this.markerId, this.markerData, LatLng cord,
      this.deviceId, this.deviceType, this.timer, this.colorBack)
      : super(
            rotate: true,
            height: 50,
            width: 50,
            point: cord,
            builder: (ctx) => TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: markerData.backColor,
                  ),
                  onPressed: () => {
                    parent?.selectMapMarker(
                        markerId, cord, deviceId, deviceType)
                  },
                  onLongPress: () => {
                    parent?.askDeleteMapMarker(
                        markerId, cord, int.parse(deviceId))
                  },
                  child: Text(
                    '$deviceId\n$deviceType',
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ));
}

class mapPage extends StatefulWidget {
  mapPage({super.key});

  late _mapPage _page;
  int markerOnMapIndex = 0;

  void CreateMapMarker(int id, String type, MarkerData data, int? posInList) {
    var value = Device();
    for(int i = 0; i < DeviceType.values.length; i++){
      if (DeviceType.values[i].name == type){
        value.type = DeviceType.values[i];
        break;
      }
    }
    value.id = id;

    if (type == DeviceType.STD) {
      global.flagCheckSPPU = true;
    }

    if (posInList == null) {
      var localMarker = MapMarker(
          _page,
          markerOnMapIndex,
          data,
          data.deviceCord!,
          data.deviceId.toString(),
          data.deviceType!,
          null,
          data.backColor);

      global.globalDeviceList.add(value);
      global.globalMapMarker.add(localMarker);
      markerOnMapIndex++;
    }else{
      var localMarker = MapMarker(
          _page,
          posInList,
          data,
          data.deviceCord!,
          data.deviceId.toString(),
          data.deviceType!,
          null,
          data.backColor);

      global.globalDeviceList.insert(posInList, value);
      global.globalMapMarker.insert(posInList, localMarker);
    }

    global.testPage.addDeviceInDropdown(value.id, value.type.name);
  }

  void ChangeMapMarker(int oldDevId, int newDevID, int newDevTypePos,
      Device device, int devPosInList) {
    if (int.parse(global.globalMapMarker[devPosInList].deviceId) == oldDevId) {
      DeleteMapMarker(oldDevId);
      _page.markerData[devPosInList].deviceId = newDevID;
      _page.markerData[devPosInList].deviceType = DeviceType.values[newDevTypePos].name;
      CreateMapMarker(newDevID, DeviceType.values[newDevTypePos].name, _page.markerData[devPosInList], devPosInList);
    }
  }

  void DeleteMapMarker(int id) {
    for (int i = 0; i < global.globalDeviceList.length; i++) {
      if (global.globalDeviceList[i].id == id) {
        if (global.globalDeviceList[i].type == DeviceType.STD) {
          global.flagCheckSPPU = false;
        }
        if (i == global.selectedDeviceID){
          global.mainBottomSelectedDev = Text(
            '',
            textScaleFactor: 1.4,
          );
        }

        if (i < global.globalDeviceList.length-1) {
          global.selectedDeviceID = i;
        } else {
          global.selectedDeviceID -= 1;
        }

        global.globalDeviceList.removeAt(i);
        global.testPage.deleteDeviceInDropdown(id);
        global.globalMapMarker.removeAt(i);
        break;
      }
    }
  }

  void MapMarkerAlarm(int devId) {
    for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (int.parse(global.globalMapMarker[i].deviceId) == devId) {
        global.globalMapMarker[i].markerData.deviceAlarm = true;
        global.globalMapMarker[i].markerData.deviceAvailable = true;
        MapMarkerActivate(devId);
        global.globalMapMarker[i].markerData.backColor = Colors.red;
        break;
      }
    }
  }

  void MapMarkerActivate(int devId) {
    for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (int.parse(global.globalMapMarker[i].deviceId) == devId) {
        global.globalMapMarker[i].markerData.backColor = Colors.green;
        print(global.globalMapMarker[i].colorBack);
        if (global.globalMapMarker[i].timer != null) {
          global.globalMapMarker[i].timer!.cancel();
        }
        global.globalMapMarker[i].markerData.deviceAvailable = true;
        global.globalMapMarker[i].timer =
            Timer(const Duration(minutes: 1), () => MapMarkerDeactivate(devId));
        break;
      }
    }
  }

  void MapMarkerDeactivate(int devId) {
    for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (int.parse(global.globalMapMarker[i].deviceId) == devId) {
        if (global.globalMapMarker[i].markerData.deviceAlarm != true) {
          global.globalMapMarker[i].markerData.backColor = Colors.blue;
          global.globalMapMarker[i].markerData.deviceAvailable = false;
        } else {
          global.globalMapMarker[i].markerData.deviceAvailable = false;
        }
        break;
      }
    }
  }

  @override
  State createState() {
    _page = _mapPage();
    return _page;
  }
}

class _mapPage extends State<mapPage>
    with AutomaticKeepAliveClientMixin<mapPage> {
  @override
  bool get wantKeepAlive => true;

  int markerIndex = -1, alarmMarkerIndex = -1, markerIdForCheck = -1;

  Location location = Location();
  LatLng? myCords, currentLocation, alarmLocation;
  MapController mapController = MapController();
  List<MarkerData> markerData = [];
  List<int> idMarkersForCheck = List<int>.empty(growable: true),
      idMarkersFromBluetooth = List<int>.empty(growable: true),
      markerIDDeletedList = List<int>.empty(growable: true),
      alarmList = List<int>.empty(growable: true);
  Widget bottomBarWidget = Container(height: 0);
  Timer? timer;
  Widget? photoWindow;
  List<Example> testListExample = List<Example>.empty(growable: true);

  bool flagSenderDevice = false, flagAddMarkerCheck = false;
  MapMarker? bufferMarker;
  String? chooseDeviceType;
  Marker? myLocalPosition;


  @override
  void initState() {
    createTestExample();
    chooseDeviceType = DeviceType.STD.name;
    super.initState();

    timer = Timer.periodic(Duration.zero, (timer) {
      setState(() {
        if (global.deviceIDChanged != -1) {
          global.selectedDeviceID;
          changeMapMarker(global.deviceIDChanged,
              global.globalMapMarker[global.deviceIDChanged].markerData);
          global.deviceIDChanged = -1;
        }
      });
    });
    Timer.periodic(const Duration(seconds: 5), (timer) {
      location.getLocation().then((p) {
        myCords = LatLng(p.latitude!, p.longitude!);
        myLocalPosition = Marker(point: myCords!, builder: (ctx) => const Icon(Icons.navigation));
      });
    });
  }

  void createTestExample() {
    for (int i = 0; i < 10000; i++) {
      testListExample.add(Example(i, i));
    }
  }

  void changeMapRotation() {
    setState(() {
      mapController.rotate(0.0);
    });
  }

  void findMyPosition() {
    setState(() {
      location.getLocation().then((p) {
        myCords = LatLng(p.latitude!, p.longitude!);
        mapController.moveAndRotate(myCords!, 17, 0.0);
      });
    });
  }

  void findMarkerPosition() {
    setState(() {
      print(global.selectedDeviceID);
      if (global.selectedDeviceID > -1) {
        mapController.moveAndRotate(
            global.globalMapMarker[global.selectedDeviceID].point, 17, 0.0);
      }
    });
  }

  void selectMapMarker(
      int markerId, LatLng cord, String string, String deviceType) {
    changeBottomBarWidget(1, markerId, cord, string, deviceType);
  }

  void askDeleteMapMarker(int markerId, LatLng cord, int deviceId) {
    setState(() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Подтвердите удаление устройства"),
            actions: [
              TextButton(
                  onPressed: () {
                    deleteMapMarker(markerId, cord, deviceId);
                    Navigator.pop(context);
                  },
                  child: const Text('Подтвердить')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Отменить')),
            ],
          );
        },
      );
    });
  }

  void getPhoto(PhotoImageSize photoImageSize, int deviceId) {
    var photoComp = PhotoImageCompression.HIGH;
    //var imageSize = PhotoImageSize.IMAGE_160X120;

    global.fileManager
        .setCameraImageProperty(deviceId, photoImageSize, photoComp);

    var cc = PhotoRequestPackage();
    cc.setType(PackageType.GET_NEW_PHOTO);
    cc.setParameters(140, photoComp, photoImageSize);
    cc.setBlackAndWhite(false);
    cc.setReceiver(deviceId);
    cc.setSender(RoutesManager.getLaptopAddress());

    var tid = global.postManager.sendPackage(cc);
  }

  void deleteMapMarker(int markerId, LatLng cord, int deviceId) {
    int index = 0;

    for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (global.globalMapMarker[i].markerId == markerId) {
        index = i;
        markerIDDeletedList.add(markerId);
        break;
      }
    }

    widget.DeleteMapMarker(deviceId);
    print('Marker deleted');
  }

  void openBottomMenu(var tap, LatLng cord) {
    setState(() {
      changeBottomBarWidget(0, null, null, null, null);
      currentLocation = cord;
    });
  }

  void clearBottomMenu(var tap, LatLng cord) {
    setState(() {
      changeBottomBarWidget(-1, null, null, null, null);
    });
  }

  void changeMapMarker(int id, MarkerData markerData) {
    setState(() {
      global.mainBottomSelectedDev = Text(
        '${markerData.deviceType!} #${markerData.deviceId}',
        textScaleFactor: 1.4,
      );
      global.globalMapMarker.removeAt(id);
      Color colorBack = Colors.blue;
      var localMarker = MapMarker(
          this,
          id,
          markerData,
          markerData.deviceCord!,
          markerData.deviceId.toString(),
          markerData.deviceType!,
          null,
          colorBack);
      global.globalMapMarker.insert(id, localMarker);
    });
  }

  void createNewMapMarker(int id, String deviceType) {
    setState(() {

      if (markerIDDeletedList.isEmpty) {
        markerIndex++;
        createMarkerData(id, deviceType);
        widget.CreateMapMarker(id, deviceType, markerData[markerIndex], null);
        changeBottomBarWidget(-1, null, null, null, null);
      } else {
        changeMarkerData(id, deviceType, markerIDDeletedList.first);
        widget.CreateMapMarker(id, deviceType, markerData[markerIDDeletedList.first], markerIDDeletedList.first);
        markerIDDeletedList.removeAt(0);
        changeBottomBarWidget(-1, null, null, null, null);
      }
    });
  }

  void changeMarkerData(int id, String deviceType, int index) {
    setState(() {
      markerData[index].deviceId = id;
      markerData[index].deviceCord = currentLocation;
      markerData[index].deviceType = deviceType;
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

  void showError(String? string) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(string!),
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
  }

  void checkCorrectID(int num) {
    setState(() {
      bool flag = false;
      flagAddMarkerCheck = false;
      if (markerIdForCheck > 0 && markerIdForCheck < 256) {
        if (global.globalMapMarker.isEmpty || !global.flagCheckSPPU) {
          if (chooseDeviceType != global.deviceTypeList[0]) {
            showError("Нанесите СППУ на карту!!!");
          }

          if (chooseDeviceType == global.deviceTypeList[0]) {
            createNewMapMarker(markerIdForCheck, chooseDeviceType!);
            global.mainBottomSelectedDev = Text(
              '${chooseDeviceType!} #$markerIdForCheck',
              textScaleFactor: 1.4,
            );
            global.selectedDeviceID = 0;
            global.flagCheckSPPU = true;
          }
        } else {
          for (int i = 0; i < global.globalMapMarker.length; i++) {
            if (global.globalMapMarker[i].markerData.deviceId ==
                markerIdForCheck) {
              flag = false;
              showError('Такой ИД уже существует');
              break;
            }
            if (chooseDeviceType == global.deviceTypeList[0]) {
              if (global.flagCheckSPPU == true) {
                flag = false;
                showError("СППУ уже нанесен на карту");
                break;
              }
              global.flagCheckSPPU = true;
            }
            if (i + 1 == global.globalMapMarker.length) {
              flag = true;
              global.selectedDeviceID = i + 1;
            }
          }
          if (flag) {
            createNewMapMarker(markerIdForCheck, chooseDeviceType!);
            global.mainBottomSelectedDev = Text(
              '${chooseDeviceType!} #$markerIdForCheck',
              textScaleFactor: 1.4,
            );
          }
        }
      } else {
        showError("Неверный ИД \n"
            "ИД может быть от 1 до 255");
      }
    });
  }

  void addNewDeviceOnMap() {
    setState(() {
      bottomBarWidget = SizedBox(
        height: 100,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          SizedBox(
            height: 100,
            width: 200,
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              maxLength: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.developer_board),
                labelText: 'Device ID',
                hintText: '',
                helperText: 'Input device ID',
              ),
              onChanged: (num) => markerIdForCheck = int.parse(num),
              onSubmitted: (num) => markerIdForCheck = int.parse(num),
            ),
          ),
          DropdownButton<String>(
            icon: const Icon(Icons.keyboard_double_arrow_down),
            onChanged: (String? value) {
              chooseDeviceType = value!;
              addNewDeviceOnMap();
            },
            value: chooseDeviceType,
            items: global.deviceTypeList
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          TextButton(
              onPressed: () => checkCorrectID(markerIdForCheck),
              child: const Text('Add device'))
        ]),
      );
    });
  }

  void changeBottomBarWidget(int counter, int? markerId, LatLng? cord,
      String? string, String? deviceType) {
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
        global.testPage.selectDeviceInDropdown(int.parse(string!));
        global.selectedDevice = string!;
        if (markerIDDeletedList.isNotEmpty){
          for(int i = 0; i < global.globalMapMarker.length; i++){
            if (global.globalDeviceList[i].id.toString() == global.selectedDevice){
              global.selectedDeviceID = i;
              break;
            }
          }
        }else{
          global.selectedDeviceID = markerId!;
        }
        global.mainBottomSelectedDev = Text(
          '${deviceType!} #$string',
          textScaleFactor: 1.4,
        );
        if (deviceType == global.deviceTypeList[0]) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              children: [
                Text(global.globalMapMarker[markerId!].markerData.deviceTime
                    .toString()),
                Text(global.globalMapMarker[markerId!].markerData.deviceType
                    .toString()),
                IconButton(
                    onPressed: () => {
                          changeBottomBarWidget(-1, null, null, null, null),
                          global.globalMapMarker[markerId].markerData
                              .deviceAlarm = false,
                        },
                    icon: const Icon(Icons.power_settings_new))
              ],
            ),
          );
        }
        if (deviceType == global.deviceTypeList[3]) {}
        if (deviceType == global.deviceTypeList[1]) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () => {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Сейсмограмма"),
                          actions: [
                            Container(
                              width: 150,
                              height: 150,
                              child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                series: <LineSeries<Example, String>>[
                                  LineSeries<Example, String>(
                                    dataSource: testListExample,
                                    xValueMapper: (Example ex, _) =>
                                        ex.time.toString(),
                                    yValueMapper: (Example ex, _) => ex.seisma,
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Ok'))
                          ],
                        );
                      },
                    )
                  },
                  icon: const Icon(Icons.show_chart),
                ),
                IconButton(
                  onPressed: () => {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Сейсмограмма"),
                          actions: [
                            Container(
                              width: 150,
                              height: 150,
                              child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                series: <LineSeries<Example, String>>[
                                  LineSeries<Example, String>(
                                    dataSource: <Example>[
                                      Example(1, -80),
                                      Example(2, -100),
                                      Example(3, 200),
                                      Example(4, 100),
                                      Example(5, -80),
                                      Example(6, -100),
                                      Example(7, 200),
                                    ],
                                    xValueMapper: (Example ex, _) =>
                                        ex.time.toString(),
                                    yValueMapper: (Example ex, _) => ex.seisma,
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Ok'))
                          ],
                        );
                      },
                    )
                  },
                  icon: const Icon(
                    Icons.show_chart,
                    color: Colors.red,
                  ),
                ),
                IconButton(
                  onPressed: () => {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Список сейсмограмм"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Ok'))
                          ],
                        );
                      },
                    )
                  },
                  icon: const Icon(Icons.file_download),
                ),
                IconButton(
                  onPressed: () => {
                    changeBottomBarWidget(-1, null, null, null, null),
                    global.globalMapMarker[markerId!].markerData.deviceAlarm =
                        false,
                    global.globalMapMarker[markerId].markerData
                        .deviceReturnCheck = true,
                    print(global
                            .globalMapMarker[markerId].markerData.deviceAlarm
                            .toString() +
                        ' ' +
                        global.globalMapMarker[markerId].markerData.deviceId
                            .toString()),
                  },
                  icon: const Icon(Icons.power_settings_new),
                ),
              ],
            ),
          );
        }
        if (deviceType == global.deviceTypeList[2]) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () => {
                    getPhoto(PhotoImageSize.IMAGE_160X120,
                        global.globalMapMarker[markerId!].markerData.deviceId!),
                    global.globalKey.currentState?.changePage(3),
                  },
                  icon: const Icon(Icons.photo_size_select_small),
                ),
                IconButton(
                  onPressed: () => {
                    getPhoto(PhotoImageSize.IMAGE_320X240,
                        global.globalMapMarker[markerId!].markerData.deviceId!),
                    global.globalKey.currentState?.changePage(3),
                  },
                  icon: const Icon(Icons.photo_size_select_large),
                ),
                IconButton(
                  onPressed: () => {
                    getPhoto(PhotoImageSize.IMAGE_640X480,
                        global.globalMapMarker[markerId!].markerData.deviceId!),
                    global.globalKey.currentState?.changePage(3),
                  },
                  icon: const Icon(Icons.photo_size_select_actual),
                ),
                IconButton(
                  onPressed: () => {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Список фото"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Ok'))
                          ],
                        );
                      },
                    )
                  },
                  icon: const Icon(Icons.photo_album_outlined),
                ),
                IconButton(
                  onPressed: () => {
                    changeBottomBarWidget(-1, null, null, null, null),
                    global.globalMapMarker[markerId!].markerData.deviceAlarm =
                        false,
                  },
                  icon: const Icon(Icons.power_settings_new),
                ),
              ],
            ),
          );
        }
      }
    });
  }

  Widget build(BuildContext context) {
    if (myCords == null) {
      return Container();
    }

    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: myCords,
          zoom: 17.0,
          maxZoom: 18.0,
          minZoom: 1.0,
          onLongPress: openBottomMenu,
          onTap: clearBottomMenu,
        ),
        mapController: mapController,
        layers: [
          TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          MarkerLayerOptions(markers: global.globalMapMarker),
          MarkerLayerOptions(markers: [myLocalPosition!]),
        ],
      ),
      floatingActionButton: Builder(builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              child: Opacity(
                opacity: 0.8,
                child: IconButton(
                  onPressed: findMarkerPosition,
                  icon: const Icon(
                    Icons.crop_free,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 60,
              child: Opacity(
                opacity: 0.8,
                child: IconButton(
                  onPressed: changeMapRotation,
                  icon: const Icon(
                    Icons.arrow_upward,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 60,
              child: Opacity(
                opacity: 0.8,
                child: IconButton(
                  onPressed: findMyPosition,
                  icon: const Icon(
                    Icons.location_searching,
                    color: Colors.red,
                  ),
                ),
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
