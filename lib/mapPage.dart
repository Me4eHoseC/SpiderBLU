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

class Example {
  Example(this.time, this.seisma);
  final int time, seisma;
}

class MapMarker extends Marker {
  _mapPage? parent;
  int markerId = -1;
  MarkerData markerData;
  Color colorBack = Colors.blue;

  MapMarker(this.parent, this.markerId, this.markerData, LatLng cord,
      String deviceId, String deviceType, this.colorBack)
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
                  onLongPress: () =>
                      {parent?.askDeleteMapMarker(markerId, cord)},
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
  // @override
  // createState() => _mapPage();

  late _mapPage _page;

  @override
  State createState() {
    _page = _mapPage();
    return _page;
  }

  void fuck() {
    _page.displayPhoto();
  }
}

class _mapPage extends State<mapPage>
    with AutomaticKeepAliveClientMixin<mapPage> {
  @override
  bool get wantKeepAlive => true;

  int markerIndex = -1, alarmMarkerIndex = -1, markerIdForCheck = -1;

  Location location = Location();
  LatLng? myCords, currentLocation, alarmLocation;
  Timer? timer;
  MapController mapController = MapController();
  List<MarkerData> markerData = [];
  List<int> idMarkersForCheck = List<int>.empty(growable: true),
      idMarkersFromBluetooth = List<int>.empty(growable: true),
      markerIDDeletedList = List<int>.empty(growable: true),
      alarmList = List<int>.empty(growable: true);
  Widget bottomBarWidget = Container(height: 0);
  
  Widget? photoWindow;

  bool flagSenderDevice = false, flagAddMarkerCheck = false;
  MapMarker? bufferMarker;
  String? chooseDeviceType;

  @override
  void initState() {
    chooseDeviceType = global.deviceTypeList[0];
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (global.deviceIDChanged != -1) {
          global.selectedDeviceID;
          changeMapMarker(global.deviceIDChanged,
              global.globalMapMarker[global.deviceIDChanged].markerData);

          global.deviceIDChanged = -1;
        }
        for (int i = 0; i < global.globalMapMarker.length; i++) {
          if (global.globalMapMarker[i].markerData.deviceAlarm) {
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
          myCords = LatLng(p.latitude!, p.longitude!);
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
      mapController.moveAndRotate(myCords!, 17, 0.0);
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

  void askDeleteMapMarker(int markerId, LatLng cord) {
    setState(() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Подтвердите удаление устройства"),
            actions: [
              TextButton(
                  onPressed: () {
                    deleteMapMarker(markerId, cord);
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

    global.fileManager.setCameraImageProperty(deviceId, photoImageSize, photoComp);

    var cc = PhotoRequestPackage();
    cc.setType(PackageType.GET_NEW_PHOTO);
    cc.setParameters(140, photoComp, photoImageSize);
    cc.setBlackAndWhite(false);
    cc.setReceiver(deviceId);
    cc.setSender(RoutesManager.getLaptopAddress());

    var tid = global.postManager.sendPackage(cc);
  }

  void displayPhoto() {
    setState(() {
      if (photoWindow != null) {
        Navigator.pop(context);
        photoWindow = null;

        MemoryImage(global.photoTest.data()).evict();
      }

      photoWindow = AlertDialog(
          content: Image.memory(global.photoTest.data()),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  photoWindow = null;
                },
                child: const Text('Подтвердить')),
          ]);

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return photoWindow!;
          });
    });
  }

  void deleteMapMarker(int markerId, LatLng cord) {
    int index = 0;

    for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (global.globalMapMarker[i].markerId == markerId) {
        index = i;
        markerIDDeletedList.add(markerId);
        break;
      }
    }

    if (index + 1 == global.globalMapMarker.length) {
      global.selectedDevice =
          global.globalMapMarker[index - 1].markerData.deviceId.toString();
      print('selected');
    }

    if (global.selectedDeviceID > markerId) {
      global.selectedDeviceID -= 1;
    }

    global.globalDevicesListFromMap.removeAt(index);
    global.globalMapMarker.removeAt(index);
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

  void changeMapMarker(int id, MarkerData _markerData) {
    setState(() {
      global.mainBottomSelectedDev = Text(
        '${_markerData.deviceType!} #${_markerData.deviceId}',
        textScaleFactor: 1.4,
      );
      global.globalMapMarker.removeAt(id);
      Color colorBack = Colors.blue;
      var localMarker = MapMarker(
          this,
          id,
          _markerData,
          _markerData.deviceCord!,
          _markerData.deviceId.toString(),
          _markerData.deviceType!,
          colorBack);
      global.globalMapMarker.insert(id, localMarker);
    });
  }

  void createNewMapMarker(int id, String deviceType) {
    setState(() {
      if (markerIDDeletedList.isEmpty) {
        markerIndex++;
        createMarkerData(id, deviceType);
        Color colorBack = Colors.blue;
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
        changeBottomBarWidget(-1, null, null, null, null);
      } else {
        changeMarkerData(id, deviceType, markerIDDeletedList.first);
        Color colorBack = Colors.blue;
        var localMarker = MapMarker(
            this,
            markerIDDeletedList.first,
            markerData[markerIDDeletedList.first],
            markerData[markerIDDeletedList.first].deviceCord!,
            markerData[markerIDDeletedList.first].deviceId.toString(),
            markerData[markerIDDeletedList.first].deviceType!,
            colorBack);
        markerIDDeletedList.removeAt(0);
        global.globalMapMarker.add(localMarker);
        global.globalDevicesListFromMap.add(id.toString());
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
        if (global.globalMapMarker.isEmpty) {
          createNewMapMarker(markerIdForCheck, chooseDeviceType!);
          global.mainBottomSelectedDev = Text(
            '${chooseDeviceType!} #$markerIdForCheck',
            textScaleFactor: 1.4,
          );
          global.selectedDeviceID = 0;
          if (chooseDeviceType == global.deviceTypeList[0]) {
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
        global.selectedDevice = string!;
        global.selectedDeviceID = markerId!;
        global.mainBottomSelectedDev = Text(
          '${deviceType!} #$string',
          textScaleFactor: 1.4,
        );
        if (deviceType == global.deviceTypeList[0]) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              children: [
                Text(global.globalMapMarker[markerId].markerData.deviceTime
                    .toString()),
                Text(global.globalMapMarker[markerId].markerData.deviceType
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
        if (deviceType == global.deviceTypeList[1]) {}
        if (deviceType == global.deviceTypeList[2]) {
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
                                    dataSource: <Example>[
                                      Example(1, 80),
                                      Example(2, -100),
                                      Example(3, 200),
                                      Example(4, 100)
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
                    global.globalMapMarker[markerId].markerData.deviceAlarm =
                        false,
                  },
                  icon: const Icon(Icons.power_settings_new),
                ),
              ],
            ),
          );
        }
        if (deviceType == global.deviceTypeList[3]) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () => {
                    getPhoto(PhotoImageSize.IMAGE_160X120, global.globalMapMarker[markerId].markerData.deviceId!)
                  },
                  icon: const Icon(Icons.photo_size_select_small),
                ),
                IconButton(
                  onPressed: () => {
                    getPhoto(PhotoImageSize.IMAGE_320X240, global.globalMapMarker[markerId].markerData.deviceId!),
                  },
                  icon: const Icon(Icons.photo_size_select_large),
                ),
                IconButton(
                  onPressed: () => {
                    getPhoto(PhotoImageSize.IMAGE_640X480, global.globalMapMarker[markerId].markerData.deviceId!),

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
                    global.globalMapMarker[markerId].markerData.deviceAlarm =
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
