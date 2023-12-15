import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:projects/BasePackage.dart';
import 'package:projects/NetPackagesDataTypes.dart';
import 'package:projects/RoutesManager.dart';
import 'package:projects/core/Device.dart';
import 'package:projects/core/ItemsManager.dart';
import 'package:projects/Application.dart';

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

  void changeAlarmBreakline() {
    if (_alarm) {
      _alarm = false;
      imageStatus = 'online';
    } else {
      _alarm = true;
      imageStatus = 'alarm breakline';
      notifyListeners();
    }
  }

  void changeAlarmHuman() {
    if (_alarm) {
      _alarm = false;
      imageStatus = 'online';
    } else {
      _alarm = true;
      imageStatus = 'alarm human';
      notifyListeners();
    }
  }

  void changeAlarmTransport() {
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
  DeviceType? type;
  bool downloadPhoto = false;
  HomeNotifier notifier = HomeNotifier();
}

class MapMarker extends Marker {
  _PageWithMap? parent;
  MarkerData markerData;
  String id;
  String type;
  Timer? timer;
  String imageTypePackage;

  MapMarker(this.parent, this.markerData, LatLng cord, this.id, this.type, this.timer, this.imageTypePackage)
      : super(
          rotate: true,
          height: 75,
          width: 75,
          point: cord,
          builder: (ctx) => TextButton(
            onPressed: () => {parent?.selectMapMarker(int.parse(id))},
            onLongPress: () => {parent?.askDeleteMapMarker(int.parse(id))},
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

class PageWithMap extends StatefulWidget with TIDManagement {
  PageWithMap({super.key});

  List<String> array = [];

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

  void CreateMapMarker(int id, DeviceType type, MarkerData data, int? posInList) {
    bufferDeviceType = SetImagePackage(type.name);

    if (type == DeviceType.STD) {
      global.flagCheckSPPU = true;
    }

    if (global.itemsManager.getSelectedDevice()?.id != id && global.itemsManager.getSelectedDevice() != null) {
      UnselectedMapMarker();
    }

    var localMarker = MapMarker(_page, data, data.cord!, data.id.toString(), data.type!.name, null, bufferDeviceType!);
    global.listMapMarkers[id] = localMarker;
    global.itemsManager.createItem(Device, id, type);
    global.itemsManager.itemAdded = AddItem;
    global.itemsManager.setSelectedItem(id);
    indexMapMarker++;

    global.testPage.addDeviceInDropdown(id, type, null);
    SelectedMapMarker(id);
  }

  void AddItem(int id, CommonItemType type) {
    print(global.itemsManager.getDevice(195)?.id);
    print('$id ${type.name}');
    print(global.itemsManager.getSelectedDevice()?.id);
  }

  void ChangeMapMarker(int oldId, int newId, DeviceType oldType, DeviceType newType) {
    if (oldId != newId) {
      global.itemsManager.changeItemId(oldId, newId);
      var buf = global.listMapMarkers[oldId];
      global.listMapMarkers.remove(oldId);
      buf?.id = newId.toString();
      buf?.markerData.id = newId;
      global.listMapMarkers[newId] = buf!;
    }
    if (oldType != newType) {
      if (oldType == DeviceType.STD && global.flagCheckSPPU == true) {
        global.flagCheckSPPU = false;
      }
      if (newType == DeviceType.STD && global.flagCheckSPPU == false) {
        global.flagCheckSPPU = true;
      }
      global.itemsManager.getSelectedDevice()?.type = newType;
      global.listMapMarkers[oldId]?.markerData.type = newType;
      global.listMapMarkers[oldId]?.type = newType.name;
    }
    global.listMapMarkers[oldId]?.imageTypePackage = SetImagePackage(newType.name);

    //TODO Возможна неизменность маркера

    /*if (global.globalDeviceList[posInList].id == oldId && global.globalDeviceList[posInList].type.name == oldType) {
      global.globalDeviceList[posInList].id = newId;

      global.globalMapMarker[posInList].id = newId.toString();
      global.globalMapMarker[posInList].markerData.id = newId;
      global.globalMapMarker[posInList].markerData.type = newType;
      global.globalMapMarker[posInList].type = newType;
      global.globalMapMarker[posInList].imageTypePackage = SetImagePackage(newType);

      var localMarker = MapMarker(
          _page,
          posInList,
          global.globalMapMarker[posInList].markerData,
          global.globalMapMarker[posInList].markerData.cord!,
          newId.toString(),
          newType,
          null,
          global.globalMapMarker[posInList].imageTypePackage);
      global.globalMapMarker.removeAt(posInList);
      global.globalMapMarker.insert(posInList, localMarker);
      SelectedMapMarker(newId);
      global.testPage.changeDeviceInDropdown(newId, newType, oldId.toString(), posInList);
    }*/
  }

  void DeleteMapMarker(int id) {
    if (global.itemsManager.getSelectedDevice()?.type == DeviceType.STD) {
      global.flagCheckSPPU = false;
    }
    UnselectedMapMarker();
    global.itemsManager.removeItem(id);
    global.listMapMarkers.remove(id);
    global.testPage.deleteDeviceInDropdown(id);
  }

  void SelectedMapMarker(int id) {
    UnselectedMapMarker();
    global.itemsManager.clearSelection();
    global.itemsManager.setSelectedItem(id);
    global.testPage.selectDeviceInDropdown(id);

    if (!global.listMapMarkers[id]!.markerData.notifier.selected) {
      global.listMapMarkers[id]?.markerData.notifier.changeSelected();
    }

    global.mainBottomSelectedDev = Text(
      '${global.listMapMarkers[id]?.markerData.type} #$id',
      textScaleFactor: 1.4,
    );
  }

  void UnselectedMapMarker() {
    if (global.itemsManager.getSelectedItem() != null) {
      var selectId = global.itemsManager.getSelectedItem()!.id;
      if (global.listMapMarkers[selectId]!.markerData.notifier.selected) {
        global.listMapMarkers[selectId]!.markerData.notifier.changeSelected();
      }
      //global.itemsManager.clearSelection();
    }
  }

  void AlarmMapMarker(int id, AlarmReason reason) {
    if (!global.listMapMarkers[id]!.markerData.notifier.alarm) {
      if (reason == AlarmReason.HUMAN) {
        global.listMapMarkers[id]!.markerData.notifier.changeAlarmHuman();
      }
      if (reason == AlarmReason.AUTO) {
        global.listMapMarkers[id]!.markerData.notifier.changeAlarmTransport();
      }
      if (reason == AlarmReason.UNKNOWN) {
        global.listMapMarkers[id]!.markerData.notifier.changeAlarm();
      }
    }

    /*for (int i = 0; i < global.globalMapMarker.length; i++) {
      if (global.globalDeviceList[i].id == id) {
        if (reason == AlarmReason.HUMAN) {
          if (!global.globalMapMarker[i].markerData.notifier.alarm) {
            global.globalMapMarker[i].markerData.notifier.changeAlarmHuman();
          }
        }
        if (reason == AlarmReason.AUTO) {
          if (!global.globalMapMarker[i].markerData.notifier.alarm) {
            global.globalMapMarker[i].markerData.notifier.changeAlarmTransport();
          }
        }
        if (reason == AlarmReason.UNKNOWN) {
          if (!global.globalMapMarker[i].markerData.notifier.alarm) {
            global.globalMapMarker[i].markerData.notifier.changeAlarm();
          }
        }
        break;
      }
    }*/
  }

  void ActivateMapMarker(int id) {
    if (global.listMapMarkers[id]!.timer != null) {
      global.listMapMarkers[id]!.timer!.cancel();
    }
    if (!global.listMapMarkers[id]!.markerData.notifier.active && !global.listMapMarkers[id]!.markerData.notifier.alarm) {
      global.listMapMarkers[id]!.markerData.notifier.changeActive();
    }
    global.listMapMarkers[id]!.timer = Timer(const Duration(minutes: 1), () => DeactivateMapMarker(id));
  }

  void DeactivateMapMarker(int id) {
    if (!global.listMapMarkers[id]!.markerData.notifier.alarm) {
      global.listMapMarkers[id]!.markerData.notifier.changeActive();
    }
  }

  LatLng? coord() {
    return _page.myCords;
  }

  @override
  State createState() {
    _page = _PageWithMap();
    return _page;
  }

  @override
  void acknowledgeReceived(int tid, BasePackage basePackage) {
    tits.remove(tid);
    array.add('acknowledgeReceived');
    global.dataComeFlag = true;
  }

  @override
  void dataReceived(int tid, BasePackage basePackage) {
    tits.remove(tid);
    if (basePackage.getType() == PackageType.TRAP_PHOTO_LIST) {
      var package = basePackage as PhototrapFilesPackage;
      var bufDev = package.getSender();
      if (global.itemsManager.getItemsIds().contains(bufDev)) {
        global.itemsManager.getDevice(bufDev)?.phototrapFiles = package.getPhototrapFiles();
        print(package.getPhototrapFiles());

        array.add('dataReceived: ${package.getPhototrapFiles()}');
        global.pageWithMap.ActivateMapMarker(bufDev);
      }
    }
  }

  @override
  void ranOutOfSendAttempts(int tid, BasePackage? pb) {
    tits.remove(tid);
    if (global.itemsManager.getItemsIds().contains(pb!.getReceiver()) &&
        global.listMapMarkers[pb.getReceiver()]!.markerData.notifier.active) {
      DeactivateMapMarker(global.listMapMarkers[pb.getReceiver()]!.markerData.id!);
      array.add('RanOutOfSendAttempts');
      global.dataComeFlag = true;
    }
  }
}

class _PageWithMap extends State<PageWithMap> with AutomaticKeepAliveClientMixin<PageWithMap> {
  @override
  bool get wantKeepAlive => true;
  Marker? myLocalPosition;
  Location location = Location();
  LatLng? myCords, currentLocation;
  MapController mapController = MapController();
  Widget bottomBarWidget = Container(height: 0);
  int bufferId = 195;
  DeviceType bufferType = DeviceType.STD;

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
      if (global.itemsManager.getSelectedItem() != null) {
        var markerId = global.itemsManager.getSelectedItem()?.id;
        mapController.moveAndRotate(global.listMapMarkers[markerId]!.point, 17, 0.0);
      }
      /*if (widget.selectedMapMarker > 0) {
        for (int i = 0; i < global.globalMapMarker.length; i++) {
          if (global.globalDeviceList[i].id == widget.selectedMapMarker) {
            mapController.moveAndRotate(global.globalMapMarker[i].point, 17, 0.0);
            break;
          }
        }
      }*/
    });
  }

  void selectMapMarker(int id) {
    widget.SelectedMapMarker(id);
    changeBottomBarWidget(1, id);
  }

  void askDeleteMapMarker(int id) {
    setState(() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Подтвердите удаление устройства"),
              actions: [
                TextButton(
                    onPressed: () {
                      deleteMapMarker(id);
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

  void deleteMapMarker(int id) {
    widget.DeleteMapMarker(id);
  }

  void openBottomMenu(var tap, LatLng cord) {
    setState(() {
      changeBottomBarWidget(0, null);
      currentLocation = cord;
    });
  }

  void clearBottomMenu(var tap, LatLng cord) {
    setState(() {
      changeBottomBarWidget(-1, null);
      widget.UnselectedMapMarker();
    });
  }

  void createNewMapMarker(int id, DeviceType type) {
    setState(() {
      widget.CreateMapMarker(id, type, createMarkerData(id, type), null);
      changeBottomBarWidget(-1, null);
    });
  }

  void changeMarkerData(int id, DeviceType type) {
    setState(() {
      global.listMapMarkers[id]!.markerData.id = id;
      global.listMapMarkers[id]!.markerData.type = type;
      global.listMapMarkers[id]!.markerData.cord = currentLocation;
      global.listMapMarkers[id]!.markerData.notifier = HomeNotifier();
    });
  }

  MarkerData createMarkerData(int id, DeviceType type) {
    MarkerData markerData = MarkerData();
    markerData.id = id;
    markerData.type = type;
    markerData.cord = currentLocation;
    return markerData;
  }

  void getPhoto(PhotoImageSize photoImageSize, int id) {
    var photoComp = PhotoImageCompression.HIGH;
    var cc = PhotoRequestPackage();

    global.listMapMarkers[id]!.markerData.downloadPhoto = true;

    global.fileManager.setCameraImageProperty(id, photoImageSize, photoComp);

    cc.setType(PackageType.GET_NEW_PHOTO);
    cc.setParameters(140, photoComp, photoImageSize);
    cc.setBlackAndWhite(false);
    cc.setReceiver(id);
    cc.setSender(RoutesManager.getLaptopAddress());

    var tid = global.postManager.sendPackage(cc);
  }

  void getPhotoList(int id) {
    var cc = BasePackage.makeBaseRequest(id, PackageType.GET_TRAP_PHOTO_LIST);
    var tid = global.postManager.sendPackage(cc);
    widget.tits.add(tid);
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

  void checkCorrectIdAndType(int idForCheck, DeviceType typeForCheck) {
    setState(() {
      if (idForCheck > 0 && idForCheck < 256) {
        if (global.listMapMarkers.isEmpty || !global.flagCheckSPPU) {
          if (typeForCheck != DeviceType.STD) {
            showError("Нанесите СППУ на карту!!!");
          }
          if (typeForCheck == DeviceType.STD) {
            createNewMapMarker(idForCheck, typeForCheck);
            global.mainBottomSelectedDev = Text(
              '$typeForCheck #$idForCheck',
              textScaleFactor: 1.4,
            );
            global.flagCheckSPPU = true;
          }
        } else {
          if (global.listMapMarkers.containsKey(idForCheck)) {
            showError('Такой ИД уже существует');
          } else {
            if (typeForCheck == DeviceType.STD && global.flagCheckSPPU == true) {
              showError("СППУ уже нанесен на карту");
            } else {
              createNewMapMarker(idForCheck, typeForCheck);
              global.mainBottomSelectedDev = Text(
                '${typeForCheck} #$idForCheck',
                textScaleFactor: 1.4,
              );
            }
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
          DropdownButton<DeviceType>(
            icon: const Icon(Icons.keyboard_double_arrow_down),
            onChanged: (DeviceType? value) {
              bufferType = value!;
              addNewDeviceOnMap();
            },
            value: bufferType,
            items: DeviceType.values.map<DropdownMenuItem<DeviceType>>((DeviceType value) {
              return DropdownMenuItem<DeviceType>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
          ),
          TextButton(onPressed: () => checkCorrectIdAndType(bufferId, bufferType), child: const Text('Add device'))
        ]),
      );
    });
  }

  void changeBottomBarWidget(int counter, int? id) {
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
        var bufMark = global.listMapMarkers[id!];
        //global.testPage.selectDeviceInDropdown(int.parse(id!));
        widget.SelectedMapMarker(id);
        global.mainBottomSelectedDev = Text(
          '${bufMark?.type} #$id',
          textScaleFactor: 1.4,
        );
        if (bufMark?.markerData.type == DeviceType.STD) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              children: [
                Text(global.listMapMarkers[id]!.markerData.type!.name),
                IconButton(
                    onPressed: () => {
                          changeBottomBarWidget(-1, null),
                          if (global.listMapMarkers[id]!.markerData.notifier.alarm)
                            {global.listMapMarkers[id]!.markerData.notifier.changeAlarm()}
                        },
                    icon: const Icon(Icons.power_settings_new))
              ],
            ),
          );
        }
        if (bufMark?.markerData.type == DeviceType.RT) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              children: [
                Text(global.itemsManager.getSelectedDevice()!.firmwareVersion.toString()),
                Text(bufMark!.markerData.id.toString()),
                IconButton(
                    onPressed: () => {
                          changeBottomBarWidget(-1, null),
                          if (bufMark.markerData.notifier.alarm) {bufMark.markerData.notifier.changeAlarm()}
                        },
                    icon: const Icon(Icons.power_settings_new))
              ],
            ),
          );
        }
        if (bufMark?.markerData.type == DeviceType.CSD) {
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
                    changeBottomBarWidget(-1, null),
                    if (bufMark!.markerData.notifier.alarm) {bufMark.markerData.notifier.changeAlarm()}
                  },
                  icon: const Icon(Icons.power_settings_new),
                ),
              ],
            ),
          );
        }
        if (bufMark?.markerData.type == DeviceType.CPD) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () => {
                    bufMark!.markerData.downloadPhoto == true
                        ? null
                        : {
                            getPhoto(PhotoImageSize.IMAGE_160X120, bufMark.markerData.id!),
                            global.globalKey.currentState?.changePage(3),
                          }
                  },
                  icon: const Icon(Icons.photo_size_select_small),
                ),
                IconButton(
                  onPressed: () => {
                    bufMark!.markerData.downloadPhoto == true
                        ? null
                        : {
                            getPhoto(PhotoImageSize.IMAGE_320X240, bufMark.markerData.id!),
                            global.globalKey.currentState?.changePage(3),
                          }
                  },
                  icon: const Icon(Icons.photo_size_select_large),
                ),
                IconButton(
                  onPressed: () => {
                    bufMark!.markerData.downloadPhoto == true
                        ? null
                        : {
                            getPhoto(PhotoImageSize.IMAGE_640X480, bufMark.markerData.id!),
                            global.globalKey.currentState?.changePage(3),
                          }
                  },
                  icon: const Icon(Icons.photo_size_select_actual),
                ),
                IconButton(
                  onPressed: () => {
                    global.globalKey.currentState?.changePage(3),
                    global.imagePage.openListFromOther(),
                  },
                  icon: const Icon(Icons.photo_album_outlined),
                ),
                IconButton(
                  onPressed: () => {
                    global.flagMoveMarker = true,
                    changeBottomBarWidget(-1, null),
                    if (bufMark!.markerData.notifier.alarm) {bufMark.markerData.notifier.changeAlarm()},
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

  void changeMoveFlag() {
    global.flagMoveMarker
        ? {
            global.flagMoveMarker = false,
            //global.testPage.updateCordDeviceFromOther(),
          }
        : global.flagMoveMarker = true;
  }

  void changeLocationMarkerOnMap(LatLng point) {}

  void chan(MapPosition pos, bool flag) {
    if (global.flagMoveMarker) {
      global.listMapMarkers[global.itemsManager.getSelectedDevice()!.id]!.point.latitude = pos.center!.latitude;
      global.listMapMarkers[global.itemsManager.getSelectedDevice()!.id]!.point.longitude = pos.center!.longitude;
      global.itemsManager.getSelectedDevice()!.longitude = pos.center!.longitude;
      global.itemsManager.getSelectedDevice()!.latitude = pos.center!.latitude;
    }
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
          onPositionChanged: chan,
          onLongPress: global.flagMoveMarker
              ? (tapPosition, point) {
                  changeLocationMarkerOnMap(point);
                }
              : openBottomMenu,
          onTap: global.flagMoveMarker
              ? (tapPosition, point) {
                  changeLocationMarkerOnMap(point);
                }
              : clearBottomMenu,
        ),
        mapController: mapController,
        layers: [
          TileLayerOptions(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: ['a', 'b', 'c']),
          MarkerLayerOptions(markers: global.listMapMarkers.values.toList()),
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
            SizedBox(
              height: 60,
              child: Opacity(
                opacity: 0.8,
                child: global.itemsManager.getSelectedDevice() != null
                    ? global.flagMoveMarker
                        ? IconButton(
                            onPressed: changeMoveFlag,
                            icon: const Icon(
                              Icons.pin_drop,
                              color: Colors.amber,
                            ),
                          )
                        : IconButton(
                            onPressed: changeMoveFlag,
                            icon: const Icon(
                              Icons.pin_drop,
                              color: Colors.red,
                            ),
                          )
                    : null,
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
