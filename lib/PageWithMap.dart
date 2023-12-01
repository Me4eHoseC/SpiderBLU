import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:projects/NetPackagesDataTypes.dart';
import 'package:projects/RoutesManager.dart';
import 'package:projects/core/Device.dart';
import 'package:projects/core/ItemsManager.dart';

import 'AllEnum.dart';
import 'NetPhotoPackages.dart';
import 'global.dart' as global;

class HomeNotifier with ChangeNotifier {
  HomeNotifier();
  String imageName = '.png';
  String imageStatus = 'offline';
  String imageSelected = '';

  bool _active = false;
  bool get active => _active;

  bool _selected = false;
  bool get selected => _selected;

  bool _alarm = false;
  bool get alarm => _alarm;

  bool _warning = false;
  bool get warning => _warning;

  void changeActive() {
    if (_active) {
      _active = false;
      imageStatus = 'offline';
    } else {
      _active = true;
      imageStatus = 'online';
      notifyListeners();
    }
  }

  void changeSelected() {
    if (_selected) {
      _selected = false;
      imageSelected = '';
    } else {
      _selected = true;
      imageSelected = ' selected';
      notifyListeners();
    }
  }

  void changeAlarm() {
    if (_alarm) {
      _alarm = false;
      imageStatus = 'online';
    } else {
      _alarm = true;
      imageStatus = 'alarm';
      notifyListeners();
    }
  }

  void changeAlarmBreakline(){
    if (_alarm) {
      _alarm = false;
      imageStatus = 'online';
    } else {
      _alarm = true;
      imageStatus = 'alarm breakline';
      notifyListeners();
    }
  }

  void changeAlarmHuman(){
    if (_alarm) {
      _alarm = false;
      imageStatus = 'online';
    } else {
      _alarm = true;
      imageStatus = 'alarm human';
      notifyListeners();
    }
  }

  void changeAlarmTransport(){
    if (_alarm) {
      _alarm = false;
      imageStatus = 'online';
    } else {
      _alarm = true;
      imageStatus = 'alarm transport';
      notifyListeners();
    }
  }

  void changeWarning() {
    if (_warning) {
      _warning = false;
      imageStatus = 'online';
    } else {
      _warning = true;
      imageStatus = 'warning';
      notifyListeners();
    }
  }

  void changeActiveWithAlarm() {
    if (_active) {
      _active = false;
      imageStatus = 'offline';
    } else {
      _active = true;
      imageStatus = 'online';
    }
  }

  void checkStatus() {
    notifyListeners();
  }
}

class MarkerData {
  int? id;
  LatLng? cord;
  String? type;
  bool downloadPhoto = false;
  HomeNotifier notifier = HomeNotifier();
}

class MapMarker extends Marker {
  _PageWithMap? parent;
  int markerId = -1;
  MarkerData markerData;
  String id;
  String type;
  Timer? timer;
  String imageTypePackage;

  MapMarker(this.parent, this.markerId, this.markerData, LatLng cord, this.id, this.type, this.timer, this.imageTypePackage)
      : super(
          rotate: true,
          height: 75,
          width: 75,
          point: cord,
          builder: (ctx) => TextButton(
            onPressed: () => {parent?.selectMapMarker(markerId, cord, id, type)},
            onLongPress: () => {parent?.askDeleteMapMarker(markerId, cord, int.parse(id))},
            child: ListenableBuilder(
              listenable: markerData.notifier,
              builder: (context, child) => Ink.image(
                width: 70,
                height: 70,
                image: Image.asset(
                  markerData.notifier.imageStatus + markerData.notifier.imageSelected + markerData.notifier.imageName,
                  package: imageTypePackage,
                ).image,
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    id,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );
}

class PageWithMap extends StatefulWidget {
  PageWithMap({super.key});

  late _PageWithMap _page;
  int selectedMapMarker = 0, indexMapMarker = 0;
  String? bufferDeviceType;

  String SetImagePackage(String type) {
    if (type == DeviceType.STD.name) {
      return 'assets/devices/std';
    }
    if (type == DeviceType.CSD.name) {
      return 'assets/devices/csd';
    }
    if (type == DeviceType.CPD.name) {
      return 'assets/devices/cpd';
    }
    if (type == DeviceType.RT.name) {
      return 'assets/devices/rt';
    } else {
      return '';
    }
  }

  void CreateMapMarker(int id, String type, MarkerData data, int? posInList) {
    var value = Device();
    bufferDeviceType = SetImagePackage(type);

    value.id = id;
    for (int i = 0; i < DeviceType.values.length; i++) {
      if (DeviceType.values[i].name == type) {
        value.type = DeviceType.values[i];
        break;
      }
    }

    if (selectedMapMarker > 0) {
      UnselectedMapMarker(selectedMapMarker);
    }
    selectedMapMarker = value.id;

    if (type == DeviceType.STD.name) {
      global.flagCheckSPPU = true;
    }

    if (posInList == null) {
      var localMarker = MapMarker(_page, indexMapMarker, data, data.cord!, data.id.toString(), data.type!, null, bufferDeviceType!);

      global.globalDeviceList.add(value);
      global.globalMapMarker.add(localMarker);
      global.itemsManager.createItem(Device,id,value.type);
      global.itemsManager.itemAdded = AddItem;

      global.selectedMapMarkerIndex = indexMapMarker;
      indexMapMarker++;
    } else {
      var localMarker = MapMarker(_page, posInList, data, data.cord!, data.id.toString(), data.type!, null, bufferDeviceType!);

      global.globalDeviceList.insert(posInList, value);
      global.globalMapMarker.insert(posInList, localMarker);
      //global.itemsManager.changeItemId(indexMapMarker,value.type);

      global.selectedMapMarkerIndex = posInList;
    }
    global.testPage.addDeviceInDropdown(value.id, value.type.name, null);
    SelectedMapMarker(selectedMapMarker);
  }

  void AddItem(int id, CommonItemType type){
    print(global.itemsManager.getDevice(195)?.id);
    print('$id ${type.name}');
    print (global.itemsManager.getSelectedDevice()?.id);
  }

  void ChangeMapMarker(int oldId, int newId, String oldType, String newType, Device device, int posInList) {
    if (global.globalDeviceList[posInList].id == oldId && global.globalDeviceList[posInList].type.name == oldType) {
      global.globalDeviceList[posInList].id = newId;
      if (oldType != newType && oldType == DeviceType.STD.name && global.flagCheckSPPU == true) {
        global.flagCheckSPPU = false;
      }
      if (oldType != newType && newType == DeviceType.STD.name && global.flagCheckSPPU == false) {
        global.flagCheckSPPU = true;
      }
      for (int i = 0; i < DeviceType.values.length; i++) {
        if (DeviceType.values[i].name == newType) {
          global.globalDeviceList[posInList].type = DeviceType.values[i];
          break;
        }
      }
      global.globalMapMarker[posInList].id = newId.toString();
      global.globalMapMarker[posInList].markerData.id = newId;
      global.globalMapMarker[posInList].markerData.type = newType;
      global.globalMapMarker[posInList].type = newType;
      global.globalMapMarker[posInList].imageTypePackage = SetImagePackage(newType);

      var localMarker = MapMarker(_page, posInList, global.globalMapMarker[posInList].markerData,
          global.globalMapMarker[posInList].markerData.cord!, newId.toString(),
          newType, null, global.globalMapMarker[posInList].imageTypePackage);
      global.globalMapMarker.removeAt(posInList);
      global.globalMapMarker.insert(posInList, localMarker);
      SelectedMapMarker(newId);
      global.testPage.changeDeviceInDropdown(newId, newType, oldId.toString(), posInList);
    }
  }

  void DeleteMapMarker(int id) {
    for (int i = 0; i < global.globalDeviceList.length; i++) {
      if (global.globalDeviceList[i].id == id) {
        if (selectedMapMarker == id) {
          UnselectedMapMarker(selectedMapMarker);
          selectedMapMarker = 0;
          global.selectedMapMarkerIndex = -1;
        }
        if (global.globalDeviceList[i].type == DeviceType.STD) {
          global.flagCheckSPPU = false;
        }
        global.globalDeviceList.removeAt(i);
        global.globalMapMarker.removeAt(i);
        global.testPage.deleteDeviceInDropdown(id);
        break;
      }
    }
  }

  void SelectedMapMarker(int id) {
    global.itemsManager.setSelectedItem(id);
    if (selectedMapMarker != id) {
      UnselectedMapMarker(selectedMapMarker);
    }
    for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (global.globalDeviceList[i].id == id) {
        if (!global.globalMapMarker[i].markerData.notifier.selected) {
          global.globalMapMarker[i].markerData.notifier.changeSelected();
        }
        selectedMapMarker = id;
        global.selectedMapMarkerIndex = i;
        global.mainBottomSelectedDev = Text(
          '${global.globalMapMarker[i].markerData.type} #$id',
          textScaleFactor: 1.4,
        );
        global.testPage.selectDeviceInDropdown(id);
        break;
      }
    }
  }

  void UnselectedMapMarker(int id) {
    for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (global.globalDeviceList[i].id == id) {
        if (global.globalMapMarker[i].markerData.notifier.selected) {
          global.globalMapMarker[i].markerData.notifier.changeSelected();
          global.selectedMapMarkerIndex = -1;
          break;
        }
      }
    }
  }

  void AlarmMapMarker(int id, AlarmReason reason) {
    for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (global.globalDeviceList[i].id == id) {
        if (reason == AlarmReason.HUMAN){
          if (!global.globalMapMarker[i].markerData.notifier.alarm) {
            global.globalMapMarker[i].markerData.notifier.changeAlarmHuman();
          }
        }
        if (reason == AlarmReason.AUTO){
          if (!global.globalMapMarker[i].markerData.notifier.alarm) {
            global.globalMapMarker[i].markerData.notifier.changeAlarmTransport();
          }
        }
        if (reason == AlarmReason.UNKNOWN){
          if (!global.globalMapMarker[i].markerData.notifier.alarm) {
            global.globalMapMarker[i].markerData.notifier.changeAlarm();
          }
        }
        break;
      }
    }
  }

  void ActivateMapMarker(int id) {
    for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (global.globalDeviceList[i].id == id) {
        if (global.globalMapMarker[i].timer != null) {
          global.globalMapMarker[i].timer!.cancel();
        }
        if (!global.globalMapMarker[i].markerData.notifier.alarm && !global.globalMapMarker[i].markerData.notifier.active) {
          global.globalMapMarker[i].markerData.notifier.changeActive();
        }
        global.globalMapMarker[i].timer = Timer(const Duration(minutes: 1), () => DeactivateMapMarker(id));
        break;
      }
    }
  }

  void DeactivateMapMarker(int id) {
    for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (global.globalDeviceList[i].id == id) {
        if (global.globalMapMarker[i].markerData.notifier.alarm) {
          global.globalMapMarker[i].markerData.notifier.changeActiveWithAlarm();
        } else {
          global.globalMapMarker[i].markerData.notifier.changeActive();
        }
        break;
      }
    }
  }

  @override
  State createState() {
    _page = _PageWithMap();
    return _page;
  }
}

class _PageWithMap extends State<PageWithMap> with AutomaticKeepAliveClientMixin<PageWithMap> {
  @override
  bool get wantKeepAlive => true;
  Marker? myLocalPosition;
  Location location = Location();
  LatLng? myCords, currentLocation;
  MapController mapController = MapController();
  List<int> markerIDDeletedList = List<int>.empty(growable: true);
  Widget bottomBarWidget = Container(height: 0);
  int bufferId = 195;
  String bufferType = DeviceType.STD.name;

  void initState() {
    super.initState();
    Timer.periodic(Duration.zero, (timer) {
      setState(() {});
    });
    Timer.periodic(const Duration(seconds: 5), (timer) {
      location.getLocation().then((p) {
        myCords = LatLng(p.latitude!, p.longitude!);
        myLocalPosition = Marker(point: myCords!, builder: (ctx) => const Icon(Icons.navigation));
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
      location.getLocation().then((p) {
        myCords = LatLng(p.latitude!, p.longitude!);
        mapController.moveAndRotate(myCords!, 17, 0.0);
      });
    });
  }

  void findMarkerPosition() {
    setState(() {
      if (widget.selectedMapMarker > 0) {
        for (int i = 0; i < global.globalMapMarker.length; i++) {
          if (global.globalDeviceList[i].id == widget.selectedMapMarker) {
            mapController.moveAndRotate(global.globalMapMarker[i].point, 17, 0.0);
            break;
          }
        }
      }
    });
  }

  void selectMapMarker(int markerId, LatLng cord, String id, String type) {
    widget.SelectedMapMarker(int.parse(id));
    changeBottomBarWidget(1, markerId, cord, id, type);
  }

  void askDeleteMapMarker(int markerId, LatLng cord, int id) {
    setState(() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Подтвердите удаление устройства"),
              actions: [
                TextButton(
                    onPressed: () {
                      deleteMapMarker(markerId, cord, id);
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
          });
    });
  }

  void deleteMapMarker(int markerId, LatLng cord, int id) {
    for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (global.globalMapMarker[i].markerId == markerId && global.globalMapMarker[i].id == id.toString()) {
        markerIDDeletedList.add(markerId);
        break;
      }
    }
    widget.DeleteMapMarker(id);
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

  void createNewMapMarker(int id, String type) {
    setState(() {
      if (markerIDDeletedList.isEmpty) {
        widget.CreateMapMarker(id, type, createMarkerData(id, type), null);
        changeBottomBarWidget(-1, null, null, null, null);
      } else {
        changeMarkerData(id, type, markerIDDeletedList.first);
        widget.CreateMapMarker(id, type, global.globalMapMarker[markerIDDeletedList.first].markerData, markerIDDeletedList.first);
        changeBottomBarWidget(-1, null, null, null, null);
      }
    });
  }

  void changeMarkerData(int id, String type, int index) {
    setState(() {
      global.globalMapMarker[index].markerData.id = id;
      global.globalMapMarker[index].markerData.type = type;
      global.globalMapMarker[index].markerData.cord = currentLocation;
      global.globalMapMarker[index].markerData.notifier = HomeNotifier();
    });
  }

  MarkerData createMarkerData(int id, String type) {
    MarkerData markerData = MarkerData();
    markerData.id = id;
    markerData.type = type;
    markerData.cord = currentLocation;
    return markerData;
  }

  void getPhoto(PhotoImageSize photoImageSize, int id) {
    for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (global.globalDeviceList[i].id == id) {
        var photoComp = PhotoImageCompression.HIGH;
        global.globalMapMarker[i].markerData.downloadPhoto = true;

        global.fileManager.setCameraImageProperty(id, photoImageSize, photoComp);

        var cc = PhotoRequestPackage();
        cc.setType(PackageType.GET_NEW_PHOTO);
        cc.setParameters(140, photoComp, photoImageSize);
        cc.setBlackAndWhite(false);
        cc.setReceiver(id);
        cc.setSender(RoutesManager.getLaptopAddress());

        var tid = global.postManager.sendPackage(cc);
        break;
      }
    }
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

  void checkCorrectIdAndType(int idForCheck, String typeForCheck) {
    setState(() {
      if (idForCheck > 0 && idForCheck < 256) {
        if (global.globalMapMarker.isEmpty || !global.flagCheckSPPU) {
          if (typeForCheck != DeviceType.STD.name) {
            showError("Нанесите СППУ на карту!!!");
          }

          if (typeForCheck == DeviceType.STD.name) {
            createNewMapMarker(idForCheck, typeForCheck);
            global.mainBottomSelectedDev = Text(
              '${typeForCheck} #$idForCheck',
              textScaleFactor: 1.4,
            );
            global.flagCheckSPPU = true;
          }
        } else {
          for (int i = 0; i < global.globalMapMarker.length; i++) {
            if (global.globalDeviceList[i].id == idForCheck) {
              showError('Такой ИД уже существует');
              break;
            }
            if (typeForCheck == DeviceType.STD.name) {
              if (global.flagCheckSPPU == true) {
                showError("СППУ уже нанесен на карту");
                break;
              } else {
                global.flagCheckSPPU = true;
                continue;
              }
            }
            if (i + 1 == global.globalMapMarker.length) {
              createNewMapMarker(idForCheck, typeForCheck);
              global.mainBottomSelectedDev = Text(
                '${typeForCheck} #$idForCheck',
                textScaleFactor: 1.4,
              );
              break;
            }
          }
        }
      } else {
        showError("Неверный ИД \n"
            "ИД может быть от 1 до 255");
      }
    });
  }

  void addNewDeviceOnMap(){
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.developer_board),
                labelText: 'Device ID',
                hintText: '',
                helperText: 'Input device ID',
              ),
              onChanged: (num) => bufferId = int.parse(num),
              onSubmitted: (num) => bufferId = int.parse(num),
            ),
          ),
          DropdownButton<String>(
            icon: const Icon(Icons.keyboard_double_arrow_down),
            onChanged: (String? value) {
              bufferType = value!;
              addNewDeviceOnMap();
            },
            value: bufferType,
            items: global.deviceTypeList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          TextButton(onPressed: () => checkCorrectIdAndType(bufferId, bufferType), child: const Text('Add device'))
        ]),
      );
    });
  }

  void changeBottomBarWidget(int counter, int? markerId, LatLng? cord, String? id, String? type){
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
        //global.testPage.selectDeviceInDropdown(int.parse(id!));
        widget.SelectedMapMarker(int.parse(id!));
        global.mainBottomSelectedDev = Text(
          '${type!} #$id',
          textScaleFactor: 1.4,
        );
        if (type == DeviceType.STD.name) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              children: [
                Text(global.globalDeviceList[markerId!].timeS.toString()),
                Text(global.globalMapMarker[markerId].type.toString()),
                IconButton(
                    onPressed: () => {
                      changeBottomBarWidget(-1, null, null, null, null),
                      if (global.globalMapMarker[markerId].markerData.notifier.alarm) {
                        global.globalMapMarker[markerId].markerData.notifier.changeAlarm()
                      }
                    },
                    icon: const Icon(Icons.power_settings_new))
              ],
            ),
          );
        }
        if (type == DeviceType.RT.name) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              children: [
                Text(global.globalDeviceList[markerId!].firmwareVersion.toString()),
                Text(global.globalMapMarker[markerId].id.toString()),
                IconButton(
                    onPressed: () => {
                      changeBottomBarWidget(-1, null, null, null, null),
                      if (global.globalMapMarker[markerId].markerData.notifier.alarm) {
                        global.globalMapMarker[markerId].markerData.notifier.changeAlarm()
                      }
                    },
                    icon: const Icon(Icons.power_settings_new))
              ],
            ),
          );
        }
        if (type == DeviceType.CSD.name) {
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
                              /*child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                series: <LineSeries<Example, String>>[
                                  LineSeries<Example, String>(
                                    dataSource: testListExample,
                                    xValueMapper: (Example ex, _) => ex.time.toString(),
                                    yValueMapper: (Example ex, _) => ex.seisma,
                                  ),
                                ],
                              ),*/
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
                              /*child: SfCartesianChart(
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
                                    xValueMapper: (Example ex, _) => ex.time.toString(),
                                    yValueMapper: (Example ex, _) => ex.seisma,
                                  ),
                                ],
                              ),*/
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
                    if (global.globalMapMarker[markerId!].markerData.notifier.alarm) {
                      global.globalMapMarker[markerId].markerData.notifier.changeAlarm()
                    }
                  },
                  icon: const Icon(Icons.power_settings_new),
                ),
              ],
            ),
          );
        }
        if (type == global.deviceTypeList[2]) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () => {
                    global.globalMapMarker[markerId!].markerData.downloadPhoto == true
                        ? null
                        : {
                      getPhoto(PhotoImageSize.IMAGE_160X120, global.globalDeviceList[markerId].id),
                      global.globalKey.currentState?.changePage(3),
                    }
                  },
                  icon: const Icon(Icons.photo_size_select_small),
                ),
                IconButton(
                  onPressed: () => {
                    global.globalMapMarker[markerId!].markerData.downloadPhoto == true
                        ? null
                        : {
                      getPhoto(PhotoImageSize.IMAGE_320X240, global.globalDeviceList[markerId].id),
                      global.globalKey.currentState?.changePage(3),
                    }
                  },
                  icon: const Icon(Icons.photo_size_select_large),
                ),
                IconButton(
                  onPressed: () => {
                    global.globalMapMarker[markerId!].markerData.downloadPhoto == true
                        ? null
                        : {
                      getPhoto(PhotoImageSize.IMAGE_640X480, global.globalDeviceList[markerId].id),
                      global.globalKey.currentState?.changePage(3),
                    }
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
                    if (global.globalMapMarker[markerId!].markerData.notifier.alarm) {
                      global.globalMapMarker[markerId].markerData.notifier.changeAlarm()
                    }
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
          TileLayerOptions(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: ['a', 'b', 'c']),
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
