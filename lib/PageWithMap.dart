import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:projects/BasePackage.dart';
import 'package:projects/NetPackagesDataTypes.dart';
import 'package:projects/RoutesManager.dart';
import 'package:projects/Application.dart';
import 'package:projects/core/NetDevice.dart';

import 'AllEnum.dart';
import 'NetPhotoPackages.dart';
import 'NetSeismicPackage.dart';
import 'core/CPD.dart';
import 'core/CSD.dart';
import 'core/MCD.dart';
import 'core/RT.dart';
import 'core/Marker.dart' as mark;
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
  String? type;
  LatLng? cord;
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
            onPressed: () => parent?.selectMapMarker(int.parse(id)),
            onLongPress: () => parent?.askDeleteMapMarker(int.parse(id)),
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
  int indexMapMarker = 0;
  String? bufferDeviceType;

  String setImagePackage(String type) {
    if (type == STD.Name(global.transLang)) {
      return 'assets/devices/std';
    }
    if (type == CSD.Name(global.transLang)) {
      return 'assets/devices/csd';
    }
    if (type == CPD.Name(global.transLang)) {
      return 'assets/devices/cpd';
    }
    if (type == RT.Name(global.transLang)) {
      return 'assets/devices/rt';
    }
    if (type == MCD.Name(global.transLang)) {
      return 'assets/devices/mcd';
    } else {
      return '';
    }
  }

  void createFirstSTDAutomatically(int id , double latitude, double longitude){
    bufferDeviceType = setImagePackage(STD().typeName());
    MarkerData data = MarkerData();
    data.id = id;
    data.cord = LatLng(latitude, longitude);
    data.type = STD().typeName();
    var localMarker = MapMarker(_page, data, data.cord!, data.id.toString(), data.type!, null, bufferDeviceType!);
    global.listMapMarkers[id] = localMarker;

    mark.Marker pin;
    pin = STD();

    pin.id = id;
    pin.setCoordinates(data.cord!.latitude, data.cord!.longitude);

    global.itemsMan.addItem(pin);
    global.itemsMan.itemAdded = addItem;
    global.itemsMan.selectionChanged = selectedItem;
    indexMapMarker++;

    global.deviceParametersPage.addDeviceInDropdown(id, data.type!);
    selectMapMarker(id);
  }

  void createMapMarker(int id, String type, MarkerData data) {
    bufferDeviceType = setImagePackage(type);

    if (global.itemsMan.getSelected<mark.Marker>() != null) {
      unselectMapMarker();
    }

    var localMarker = MapMarker(_page, data, data.cord!, data.id.toString(), data.type!, null, bufferDeviceType!);
    global.listMapMarkers[id] = localMarker;

    mark.Marker pin;
    if (type == mark.Marker.Name()) {
      pin = mark.Marker();
    } else if (type == STD.Name()) {
      pin = STD();
      //_page.startDiscovery();
    } else if (type == CPD.Name()) {
      pin = CPD();
    } else if (type == CSD.Name()) {
      pin = CSD();
    } else if (type == MCD.Name()) {
      pin = MCD();
    } else {
      pin = RT();
    }

    pin.id = id;
    pin.setCoordinates(data.cord!.latitude, data.cord!.longitude);

    global.itemsMan.addItem(pin);
    global.itemsMan.itemAdded = addItem;
    global.itemsMan.selectionChanged = selectedItem;
    indexMapMarker++;

    global.deviceParametersPage.addDeviceInDropdown(id, type);
    selectMapMarker(id);
  }

  void selectedItem() {
    print(global.itemsMan.getSelected<NetDevice>()?.id);
    /*print(global.itemsMan.getAllIds());
    print(global.itemsMan.get<STD>(195)?.typeName);
    print(global.itemsMan.getSelectedItem()?.id);*/
  }

  void addItem(int id) {
    /*print(global.itemsMan.get(195)?.id);
    print('$id ${global.itemsMan.get<NetDevice>(id)?.typeName(global.transLang)}');
    print(global.itemsMan.getSelectedItem()?.id);*/
  }

  void changeMapMarkerID(int oldId, int newId) {
    if (oldId != newId) {
      global.itemsMan.changeItemId(oldId, newId);

      var buf = global.listMapMarkers[oldId];
      buf!.markerData.id = newId;

      var localMarker =
          MapMarker(_page, buf.markerData, buf.markerData.cord!, newId.toString(), buf.markerData.type!, null, buf.imageTypePackage);

      global.listMapMarkers[newId] = localMarker;
      selectMapMarker(newId);
      global.listMapMarkers.remove(oldId);

      global.deviceParametersPage.changeDeviceInDropdown(newId, buf.markerData.type!, oldId.toString());
    }
  }

  void changeMapMarkerType(int id, String oldType, String newType) {
    var item = global.itemsMan.get<mark.Marker>(id);

    if (oldType != newType) {
      mark.Marker newItem;
      if (newType == mark.Marker.Name()) {
        newItem = mark.Marker();
      } else if (newType == STD.Name()) {
        newItem = STD();
        //_page.startDiscovery();
      } else if (newType == CPD.Name()) {
        newItem = CPD();
      } else if (newType == CSD.Name()) {
        newItem = CSD();
      } else if (newType == MCD.Name()) {
        newItem = MCD();
      } else {
        newItem = RT();
      }

      var buf = global.listMapMarkers[id];

      newItem.copyFrom(item!);

      buf!.markerData.type = newType;
      global.listMapMarkers.remove(id);

      var localMarker = MapMarker(_page, buf.markerData, buf.markerData.cord!, id.toString(), newType, null, setImagePackage(newType));
      global.listMapMarkers[id] = localMarker;

      global.itemsMan.blockSignals = true;

      global.itemsMan.removeItem(id);
      global.itemsMan.addItem(newItem);
      selectMapMarker(newItem.id);

      global.itemsMan.blockSignals = false;
      global.deviceParametersPage.changeDeviceInDropdown(id, newType, id.toString());
    }
  }

  void deleteMapMarker(int id) {
    if (global.itemsMan.get<STD>(id) != null) {
      print('blya');
      global.flagCheckSPPU = false;
      //_page.disconnect();
    }
    if (global.itemsMan.isSelected(id)) {
      unselectMapMarker();
    }

    global.itemsMan.removeItem(id);
    global.listMapMarkers.remove(id);
    global.deviceParametersPage.deleteDeviceInDropdown(id);
  }

  void selectMapMarker(int id) {
    if (!global.itemsMan.isSelected(id)) {
      unselectMapMarker();
    }

    global.itemsMan.setSelected(id);
    global.deviceParametersPage.selectDeviceInDropdown(id);

    if (!global.listMapMarkers[id]!.markerData.notifier.selected) {
      global.listMapMarkers[id]?.markerData.notifier.changeSelected();
    }

    global.mainBottomSelectedDev = Text(
      '${global.listMapMarkers[id]?.markerData.type} #$id',
      textScaleFactor: 1.4,
    );
  }

  void unselectMapMarker() {
    var selected = global.itemsMan.getSelected<mark.Marker>();
    if (selected == null) {
      return;
    }
    if (global.listMapMarkers[selected.id]!.markerData.notifier.selected) {
      global.listMapMarkers[selected.id]!.markerData.notifier.changeSelected();
    }
    global.itemsMan.clearSelection();
  }

  void alarmMapMarker(int id, AlarmReason reason) {
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
  }

  void activateMapMarker(int id) {
    if (global.listMapMarkers[id]!.timer != null) {
      global.listMapMarkers[id]!.timer!.cancel();
    }
    if (!global.listMapMarkers[id]!.markerData.notifier.active && !global.listMapMarkers[id]!.markerData.notifier.alarm) {
      global.listMapMarkers[id]!.markerData.notifier.changeActive();
    }
    global.listMapMarkers[id]!.timer = Timer(const Duration(minutes: 1), () => deactivateMapMarker(id));
  }

  void deactivateMapMarker(int id) {
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
      if (global.itemsMan.getAllIds().contains(bufDev)) {
        global.itemsMan.get<CPD>(bufDev)?.phototrapFiles = package.getPhototrapFiles();
        array.add('dataReceived: ${package.getPhototrapFiles()}');
        global.pageWithMap.activateMapMarker(bufDev);
      }
    }
  }

  @override
  void ranOutOfSendAttempts(int tid, BasePackage? pb) {
    tits.remove(tid);
    if (global.itemsMan.getAllIds().contains(pb!.getReceiver()) && global.listMapMarkers[pb.getReceiver()]!.markerData.notifier.active) {
      deactivateMapMarker(global.listMapMarkers[pb.getReceiver()]!.markerData.id!);
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
  String bufferType = STD.Name();

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration.zero, (timer) {
      setState(() {});
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
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
      if (global.itemsMan.getSelected<mark.Marker>() != null) {
        var markerId = global.itemsMan.getSelected<mark.Marker>()!.id;
        mapController.moveAndRotate(global.listMapMarkers[markerId]!.point, 17, 0.0);
      }
    });
  }

  /*void startDiscovery() {
    global.stdConnectionManager.setStateOnDone = () {
      setState(() {});
    };
    setState(() {
      global.stdConnectionManager.searchAndConnect();
    });
  }

  void disconnect() {
    setState(() {
      global.stdConnectionManager.disconnect();
    });
  }*/

  void selectMapMarker(int id) {
    widget.selectMapMarker(id);
    changeBottomBarWidget(1, id);
  }

  void askDeleteMapMarker(int id) {
    setState(() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm device removal"),
              actions: [
                TextButton(
                    onPressed: () {
                      deleteMapMarker(id);
                      Navigator.pop(context);
                    },
                    child: const Text('Confirm')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
              ],
            );
          });
    });
  }

  void deleteMapMarker(int id) {
    widget.deleteMapMarker(id);
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
      widget.unselectMapMarker();
    });
  }

  void createNewMapMarker(int id, String type) {
    setState(() {
      widget.createMapMarker(id, type, createMarkerData(id, type));
      changeBottomBarWidget(-1, null);
    });
  }

  void changeMarkerData(int id, String type) {
    setState(() {
      global.listMapMarkers[id]!.markerData.id = id;
      global.listMapMarkers[id]!.markerData.type = type;
      global.listMapMarkers[id]!.markerData.cord = currentLocation;
      global.listMapMarkers[id]!.markerData.notifier = HomeNotifier();
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
    var photoComp = PhotoImageCompression.HIGH;
    var cc = PhotoRequestPackage();

    global.fileManager.setCameraImageProperty(id, photoImageSize, photoComp);

    global.imagePage.downloadingCpdId = id;

    cc.setType(PackageType.GET_NEW_PHOTO);
    cc.setParameters(140, photoComp, photoImageSize);
    cc.setBlackAndWhite(false);
    cc.setReceiver(id);
    cc.setSender(RoutesManager.getLaptopAddress());

    var tid = global.postManager.sendPackage(cc);
    widget.tits.add(tid);
  }

  void getPhotoList(int id) {
    var cc = BasePackage.makeBaseRequest(id, PackageType.GET_TRAP_PHOTO_LIST);
    var tid = global.postManager.sendPackage(cc);
    widget.tits.add(tid);
  }

  void getLastSeismic(int id) {
    //todo

    var cc = SeismicRequestPackage();
    cc.setType(PackageType.GET_LAST_SEISMIC_WAVE);
    cc.setReceiver(id);
    cc.setSender(RoutesManager.getLaptopAddress());
    cc.setZippedFlag(true);

    var tid = global.postManager.sendPackage(cc);
    widget.tits.add(tid);
  }

  void getSeismic(int id) {
    //todo

    var cc = SeismicRequestPackage();
    cc.setReceiver(id);
    cc.setSender(RoutesManager.getLaptopAddress());
    cc.setZippedFlag(true);

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

  void checkCorrectIdAndType(int idForCheck, String typeForCheck) {
    setState(() {
      if (idForCheck < 1 || idForCheck > 255) {
        showError("Invalid ID \n"
            "ID can be from 1 to 255");
        return;
      }

      if (global.listMapMarkers.containsKey(idForCheck)) {
        showError('This ID is exist');
        return;
      }

      if (!global.flagCheckSPPU && typeForCheck != STD.Name()) {
        showError("Place STD on the map!!!");
        return;
      }

      if (global.flagCheckSPPU && typeForCheck == STD.Name()) {
        showError("STD has already been mapped");
        return;
      }

      if (!global.flagCheckSPPU && typeForCheck == STD.Name()) {
        global.flagCheckSPPU = true;
        print('flag');
      }

      createNewMapMarker(idForCheck, typeForCheck);
      global.mainBottomSelectedDev = Text(
        '$typeForCheck #$idForCheck',
        textScaleFactor: 1.4,
      );
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
        widget.selectMapMarker(id);
        global.mainBottomSelectedDev = Text(
          '${bufMark?.type} #$id',
          textScaleFactor: 1.4,
        );
        if (bufMark?.markerData.type == STD.Name()) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              children: [
                Text(global.listMapMarkers[id]!.markerData.type!),
                IconButton(
                    onPressed: () {
                      changeBottomBarWidget(-1, null);
                      if (global.listMapMarkers[id]!.markerData.notifier.alarm) {
                        global.listMapMarkers[id]!.markerData.notifier.changeAlarm();
                      }
                    },
                    icon: const Icon(Icons.power_settings_new))
              ],
            ),
          );
        }
        if (bufMark?.markerData.type == RT.Name()) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              children: [
                Text(global.itemsMan.getSelected<RT>()!.firmwareVersion.toString()),
                Text(bufMark!.markerData.id.toString()),
                IconButton(
                    onPressed: () {
                      changeBottomBarWidget(-1, null);
                      if (bufMark.markerData.notifier.alarm) {
                        bufMark.markerData.notifier.changeAlarm();
                      }
                    },
                    icon: const Icon(Icons.power_settings_new))
              ],
            ),
          );
        }
        if (bufMark?.markerData.type == CSD.Name()) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    var success = global.seismicPage.getSeismic();
                    if (success) global.globalKey.currentState?.changePage(4);
                  },
                  icon: const Icon(Icons.show_chart),
                ),
                IconButton(
                  onPressed: () {
                    var success = global.seismicPage.getLastSeismic();
                    if (success) global.globalKey.currentState?.changePage(4);
                  },
                  icon: const Icon(
                    Icons.show_chart,
                    color: Colors.red,
                  ),
                ),
                IconButton(
                  onPressed: () => global.globalKey.currentState?.changePage(4),
                  icon: const Icon(Icons.file_download),
                ),
                IconButton(
                  onPressed: () {
                    changeBottomBarWidget(-1, null);
                    if (bufMark!.markerData.notifier.alarm) {
                      bufMark.markerData.notifier.changeAlarm();
                    }
                  },
                  icon: const Icon(Icons.power_settings_new),
                ),
              ],
            ),
          );
        }
        if (bufMark?.markerData.type == CPD.Name()) {
          bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    var success = global.imagePage.getPhoto(PhotoImageSize.IMAGE_160X120);
                    if (success) global.globalKey.currentState?.changePage(3);
                  },
                  icon: const Icon(Icons.photo_size_select_small),
                ),
                IconButton(
                  onPressed: () {
                    var success = global.imagePage.getPhoto(PhotoImageSize.IMAGE_320X240);
                    if (success) global.globalKey.currentState?.changePage(3);
                  },
                  icon: const Icon(Icons.photo_size_select_large),
                ),
                IconButton(
                  onPressed: () {
                    var success = global.imagePage.getPhoto(PhotoImageSize.IMAGE_640X480);
                    if (success) global.globalKey.currentState?.changePage(3);
                  },
                  icon: const Icon(Icons.photo_size_select_actual),
                ),
                IconButton(
                  onPressed: () {
                    global.globalKey.currentState?.changePage(3);
                    global.imagePage.openListFromOther();
                  },
                  icon: const Icon(Icons.photo_album_outlined),
                ),
                IconButton(
                  onPressed: () {
                    global.flagMoveMarker = true;
                    changeBottomBarWidget(-1, null);
                    if (bufMark!.markerData.notifier.alarm) {
                      bufMark.markerData.notifier.changeAlarm();
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
      global.listMapMarkers[global.itemsMan.getSelected<mark.Marker>()!.id]!.point.latitude = pos.center!.latitude;
      global.listMapMarkers[global.itemsMan.getSelected<mark.Marker>()!.id]!.point.longitude = pos.center!.longitude;
      global.itemsMan.getSelected<mark.Marker>()!.setCoordinates(pos.center!.latitude, pos.center!.longitude);
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
                child: global.itemsMan.getSelected<mark.Marker>() != null
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
