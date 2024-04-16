import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:projects/core/AIRS.dart';

import '../radionet/NetCommonPackages.dart';
import '../radionet/PackageTypes.dart';

import '../radionet/BasePackage.dart';
import '../radionet/NetPackagesDataTypes.dart';
import '../radionet/RoutesManager.dart';
import '../radionet/NetPhotoPackages.dart';
import '../radionet/NetSeismicPackage.dart';

import '../core/NetDevice.dart';
import '../core/CPD.dart';
import '../core/CSD.dart';
import '../core/MCD.dart';
import '../core/RT.dart';
import '../core/Marker.dart' as mark;
import '../global.dart' as global;

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

class AddDeviceNotifier with ChangeNotifier {
  AddDeviceNotifier();

  String imageName = '.png';
  String imageStatus = 'online';
  String imageSelected = '';

  bool _selected = false;

  bool get selected => _selected;

  void changeSelected() {
    if (_selected) {
      _selected = false;
      imageSelected = '';
      notifyListeners();
    } else {
      _selected = true;
      imageSelected = ' selected';
      notifyListeners();
    }
  }
}

class MarkerData {
  int? id;
  String? type;
  LatLng? cord;

  MarkerData(this.id, this.type, this.cord);

  factory MarkerData.fromJson(Map<String, Object?> jsonMap) {
    return MarkerData(
        jsonMap["id"] as int, jsonMap["type"] as String, LatLng(jsonMap["latitude"] as double, jsonMap["longitude"] as double));
  }

  Map toJson() => {'id': id, 'type': type, 'latitude': cord?.latitude, 'longitude': cord?.longitude};
  HomeNotifier notifier = HomeNotifier();
}

class MapMarker extends Marker {
  _PageWithMap? parent;
  MarkerData markerData;
  String id;
  String type;
  String imageTypePackage;

  MapMarker(this.parent, this.markerData, LatLng cord, this.id, this.type, this.imageTypePackage)
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

class PageWithMap extends StatefulWidget with global.TIDManagement {
  PageWithMap({super.key});

  List<String> array = [];

  late _PageWithMap _page;
  String? bufferDeviceType;

  Widget bottomBarWidget = Container(height: 0);

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
    }
    if (type == AIRS.Name(global.transLang)) {
      return 'assets/devices/airs';
    } else {
      return '';
    }
  }

  void setTimeForNewDevice(int devId) {
    global.deviceParametersPage.setTimeForNewDevice(devId);
  }

  void getCordForNewDevice(int devId) {
    global.deviceParametersPage.getCordForNewDevice(devId);
  }

  void saveMapMarkersInFile() async {
    global.getPermission();
    var dir = global.pathToProject;
    File file = File('${dir.path}/first.json');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    var bufJson = '[';
    for (int i in global.listMapMarkers.keys) {
      if (i != global.listMapMarkers.keys.last) {
        bufJson += '${json.encode(global.listMapMarkers[i]!.markerData)},';
      } else {
        bufJson += json.encode(global.listMapMarkers[i]!.markerData);
      }
    }
    bufJson += ']';
    await file.writeAsString(bufJson);
  }

  Future<void> loadMapMarkersFromFile() async {
    global.getPermission();
    var dir = global.pathToProject;
    File file = File('${dir.path}/first.json');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    final data = await file.readAsString();
    final decoded = json.decode(data);
    for (final item in decoded) {
      createMapMarker(MarkerData.fromJson(item).id!, MarkerData.fromJson(item).type!, MarkerData.fromJson(item));
    }
  }

  void createFirstSTDAutomatically(int id, double latitude, double longitude) {
    bufferDeviceType = setImagePackage(STD().typeName());
    MarkerData data = MarkerData(id, STD().typeName(), LatLng(latitude, longitude));
    data.id = id;
    data.cord = LatLng(latitude, longitude);
    data.type = STD().typeName();
    var localMarker = MapMarker(_page, data, data.cord!, data.id.toString(), data.type!, bufferDeviceType!);
    global.listMapMarkers[id] = localMarker;
    global.flagCheckSPPU = true;

    mark.Marker pin;
    pin = STD();

    pin.id = id;
    pin.setCoordinates(data.cord!.latitude, data.cord!.longitude);

    global.itemsMan.addItem(pin);
    global.itemsMan.itemAdded = addItem;
    global.itemsMan.selectionChanged = selectedItem;

    global.stdConnectionManager.setSTDId(id);
    global.stdConnectionManager.startConnectRoutine();

    global.deviceParametersPage.addDeviceInDropdown(id, data.type!);
    selectMapMarker(id);
    saveMapMarkersInFile();
  }

  void createMapMarker(int id, String type, MarkerData data) {
    bufferDeviceType = setImagePackage(type);

    global.initSendingState(id);

    if (global.itemsMan.getSelected<mark.Marker>() != null) {
      unselectMapMarker();
    }

    var localMarker = MapMarker(_page, data, data.cord!, data.id.toString(), data.type!, bufferDeviceType!);
    global.listMapMarkers[id] = localMarker;

    mark.Marker pin;
    if (type == mark.Marker.Name()) {
      pin = mark.Marker();
    } else if (type == STD.Name()) {
      pin = STD();
      global.flagCheckSPPU = true;
      global.stdConnectionManager.setSTDId(id);
    } else if (type == CPD.Name()) {
      pin = CPD();
    } else if (type == CSD.Name()) {
      pin = CSD();
    } else if (type == MCD.Name()) {
      pin = MCD();
    } else if (type == AIRS.Name()) {
      pin = AIRS();
    } else {
      pin = RT();
    }

    pin.id = id;
    pin.setCoordinates(data.cord!.latitude, data.cord!.longitude);

    global.itemsMan.addItem(pin);
    global.itemsMan.itemAdded = addItem;
    global.itemsMan.selectionChanged = selectedItem;
    global.itemsMan.itemRemoved = itemRemoved;
    global.deviceParametersPage.addDeviceInDropdown(id, type);

    if (_page.flagGetCord){
      getCordForNewDevice(id);
    }
    if (_page.flagGetTime){
      setTimeForNewDevice(id);
    }

    selectMapMarker(id);
    saveMapMarkersInFile();
  }

  void addNewDeviceOnMap(LatLng cord) {
    _page.addNewDeviceOnMap(cord);
  }

  LatLngBounds takeMapBounds() {
    return _page.takeBounds();
  }

  void selectedItem() {
    if (global.itemsMan.getSelected<NetDevice>() == null) return;
    _page.changeBottomBarWidget(1, global.itemsMan.getSelected<NetDevice>()!.id, null);
  }

  void addItem(int id) {
    global.devicesTablePage.addDevice(id);
  }

  void itemRemoved(int id) {
    print('delete device $id');
  }

  void changeMapMarkerID(int oldId, int newId) {
    if (oldId == newId) return;

    if (global.std != null && global.std?.stdId == oldId) {
      global.std!.disconnect();
    }

    var oldDevice = global.itemsMan.get<NetDevice>(oldId);

    oldDevice?.state = NDState.Offline;
    global.pageWithMap.deactivateMapMarker(oldId);
    global.deviceParametersPage.addProtocolLine('Device #$oldId offline');

    global.itemsMan.changeItemId(oldId, newId);

    var std = global.itemsMan.get<STD>(newId);
    if (std != null) {
      global.stdConnectionManager.setSTDId(newId);
      global.stdConnectionManager.startConnectRoutine();
    }

    var buf = global.listMapMarkers[oldId];
    buf!.markerData.id = newId;

    var localMarker = MapMarker(_page, buf.markerData, buf.markerData.cord!, newId.toString(), buf.markerData.type!, buf.imageTypePackage);

    global.listMapMarkers[newId] = localMarker;
    global.deviceParametersPage.changeDeviceInDropdown(newId, buf.markerData.type!, oldId.toString());
    selectMapMarker(newId);
    global.listMapMarkers.remove(oldId);

    saveMapMarkersInFile();
  }

  void changeMapMarkerType(int id, String oldType, String newType) {
    var item = global.itemsMan.get<mark.Marker>(id);

    if (oldType != newType) {
      mark.Marker newItem;
      if (newType == mark.Marker.Name()) {
        newItem = mark.Marker();
      } else if (newType == STD.Name()) {
        newItem = STD();
      } else if (newType == CPD.Name()) {
        newItem = CPD();
      } else if (newType == CSD.Name()) {
        newItem = CSD();
      } else if (newType == MCD.Name()) {
        newItem = MCD();
      } else if (newType == AIRS.Name()) {
        newItem = AIRS();
      } else {
        newItem = RT();
      }

      var buf = global.listMapMarkers[id];

      newItem.copyFrom(item!);

      buf!.markerData.type = newType;
      global.listMapMarkers.remove(id);

      var localMarker = MapMarker(_page, buf.markerData, buf.markerData.cord!, id.toString(), newType, setImagePackage(newType));
      global.listMapMarkers[id] = localMarker;

      global.itemsMan.blockSignals = true;

      global.itemsMan.removeItem(id);
      global.itemsMan.addItem(newItem);
      selectMapMarker(newItem.id);

      global.itemsMan.blockSignals = false;

      if (newType == STD.Name()) {
        global.flagCheckSPPU = true;
        global.stdConnectionManager.setSTDId(id);
        global.stdConnectionManager.startConnectRoutine();
      }

      global.deviceParametersPage.changeDeviceInDropdown(id, newType, id.toString());
      saveMapMarkersInFile();
    }
  }

  void askDeleteMapMarker(int id) {
    _page.askDeleteMapMarker(id);
  }

  void deleteMapMarker(int id) {
    if (global.itemsMan.get<STD>(id) != null) {
      global.stdConnectionManager.setSTDId(0);

      global.flagCheckSPPU = false;
      global.std?.disconnect();
    }
    if (global.itemsMan.isSelected(id)) {
      unselectMapMarker();
      _page.clearBottomMenu(null,null);
    }

    global.itemsMan.removeItem(id);
    global.listMapMarkers.remove(id);
    global.deviceParametersPage.deleteDeviceInDropdown(id);
    saveMapMarkersInFile();
    global.devicesTablePage.ref();
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
    global.devicesTablePage.ref();
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
    global.mainBottomSelectedDev = const Text(
      '',
      textScaleFactor: 1.4,
    );
    global.devicesTablePage.ref();
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
    if (!global.listMapMarkers[id]!.markerData.notifier.active && !global.listMapMarkers[id]!.markerData.notifier.alarm) {
      global.listMapMarkers[id]!.markerData.notifier.changeActive();
    }
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
}

class _PageWithMap extends State<PageWithMap> with AutomaticKeepAliveClientMixin<PageWithMap> {
  @override
  bool get wantKeepAlive => true;
  Marker? myLocalPosition;
  Location location = Location();
  LatLng? myCords;
  MapController mapController = MapController();
  Widget? listOfDevices;

  String bufferType = '';
  int bufferId = global.itemsMan.getNextId();
  bool flagGetTime = false;
  bool flagGetCord = false;
  TextEditingController controllerId = TextEditingController();

  List<Expanded> bufListButton = [];

  LatLng? pointForNewDevice;

  Map<String, AddDeviceNotifier> mapSelectedDevices = {};

  @override
  void initState() {
    super.initState();
    makeListOfDevices();
    if (bufferType == ''){
      bufferType = global.deviceTypeList[0];
      mapSelectedDevices[bufferType]!.changeSelected();
    }

    widget.loadMapMarkersFromFile().then((_) {
      if (global.flagCheckSPPU == false) {
        Timer(const Duration(seconds: 4), () {
          var coord = global.pageWithMap.coord();
          if (coord == null) return;

          global.pageWithMap.createFirstSTDAutomatically(195, coord.latitude, coord.longitude);
        });
      } else {
        global.stdConnectionManager.startConnectRoutine();
      }
    });

    Timer.periodic(Duration.zero, (_) => setState(() {}));

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

  void selectMapMarker(int id) {
    widget.selectMapMarker(id);
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
      changeBottomBarWidget(0, null, cord);
      //currentLocation = cord;
    });
  }

  void clearBottomMenu(var tap, LatLng? cord) {
    setState(() {
      changeBottomBarWidget(-1, null, null);
      widget.unselectMapMarker();
    });
  }

  void createNewMapMarker(int id, String type, LatLng cord) {
    setState(() {
      widget.createMapMarker(id, type, createMarkerData(id, type, cord));
      changeBottomBarWidget(-1, null, null);
    });
  }

  void changeMarkerData(int id, String type, LatLng cord) {
    setState(() {
      global.listMapMarkers[id]!.markerData.id = id;
      global.listMapMarkers[id]!.markerData.type = type;
      global.listMapMarkers[id]!.markerData.cord = cord;
      global.listMapMarkers[id]!.markerData.notifier = HomeNotifier();
    });
  }

  MarkerData createMarkerData(int id, String type, LatLng cord) {
    MarkerData markerData = MarkerData(id, type, cord);
    markerData.id = id;
    markerData.type = type;
    markerData.cord = cord;
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

  void checkCorrectIdAndType(int idForCheck, String typeForCheck, LatLng cord) {
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

      createNewMapMarker(idForCheck, typeForCheck, cord);
      global.mainBottomSelectedDev = Text(
        '$typeForCheck #$idForCheck',
        textScaleFactor: 1.4,
      );
    });
  }

  Expanded iconRadioButton(int index) {
    return Expanded(
      flex: 1,
      child: InkResponse(
        child: ListenableBuilder(
          listenable: mapSelectedDevices[global.deviceTypeList[index]]!,
          builder: (context, child) => Ink.image(
            width: 70,
            height: 70,
            image: Image.asset(
              mapSelectedDevices[global.deviceTypeList[index]]!.imageStatus +
                  mapSelectedDevices[global.deviceTypeList[index]]!.imageSelected +
                  mapSelectedDevices[global.deviceTypeList[index]]!.imageName,
              package: widget.setImagePackage(global.deviceTypeList[index]),
            ).image,
          ),
        ),
        onTap: () {
          if (bufferType != '') {
            mapSelectedDevices[bufferType]!.changeSelected();
          }
          bufferType = global.deviceTypeList[index];
          mapSelectedDevices[bufferType]!.changeSelected();
          addNewDeviceOnMap(pointForNewDevice!);
        },
      ),
    );
  }

  void makeListOfDevices() {
    for (int j = 0; j < global.deviceTypeList.length; j++) {
      mapSelectedDevices[global.deviceTypeList[j]] = AddDeviceNotifier();
      bufListButton.add(iconRadioButton(j));
      print(j);
    }
  }

  _changeId() {
    setState(() {
      bufferId = int.parse(controllerId.text);
      global.initSendingState(bufferId);
    });
  }

  void addNewDeviceOnMap(LatLng cord) {
    pointForNewDevice = cord;
    bufferId = int.parse(controllerId.text);
    controllerId.addListener(_changeId);
    widget.bottomBarWidget = SizedBox(
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: bufListButton,
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CheckboxListTile(
                  title: const Icon(Icons.access_time_outlined),
                  value: flagGetTime,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) {
                    flagGetTime = value!;
                    addNewDeviceOnMap(pointForNewDevice!);
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: CheckboxListTile(
                  title: const Icon(Icons.location_pin),
                  value: flagGetCord,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) {
                    flagGetCord = value!;
                    addNewDeviceOnMap(pointForNewDevice!);
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: controllerId,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  maxLength: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Device ID',
                    counterText: '',
                  ),
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () => checkCorrectIdAndType(bufferId, bufferType, cord),
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void changeBottomBarWidget(int counter, int? id, LatLng? point) {
    setState(() {
      if (counter == 0) {
        controllerId.text = global.itemsMan.getNextId().toString();
        addNewDeviceOnMap(point!);
      }
      if (counter == -1) {
        widget.bottomBarWidget = Container(
          height: 0.0,
        );
      }
      if (counter == 1) {
        var bufMark = global.listMapMarkers[id!];
        if (bufMark == null) return;
        global.mainBottomSelectedDev = Text(
          '${bufMark.type} #$id',
          textScaleFactor: 1.4,
        );
        if (bufMark.markerData.type == STD.Name()) {
          widget.bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: !global.listMapMarkers[id]!.markerData.notifier.alarm
                      ? null
                      : () {
                          global.listMapMarkers[id]!.markerData.notifier.changeAlarm();
                          changeBottomBarWidget(-1, null, null);
                        },
                  icon: !global.listMapMarkers[id]!.markerData.notifier.alarm
                      ? const Icon(Icons.warning_rounded)
                      : const Icon(
                          Icons.warning_rounded,
                          color: Color.fromARGB(220, 211, 44, 44),
                        ),
                ),
              ],
            ),
          );
        }
        if (bufMark.markerData.type == RT.Name()) {
          widget.bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: !global.listMapMarkers[id]!.markerData.notifier.alarm
                      ? null
                      : () {
                          global.listMapMarkers[id]!.markerData.notifier.changeAlarm();
                          changeBottomBarWidget(-1, null, null);
                        },
                  icon: !global.listMapMarkers[id]!.markerData.notifier.alarm
                      ? const Icon(Icons.warning_rounded)
                      : const Icon(
                          Icons.warning_rounded,
                          color: Color.fromARGB(220, 211, 44, 44),
                        ),
                ),
              ],
            ),
          );
        }
        if (bufMark.markerData.type == MCD.Name()) {
          widget.bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: !global.listMapMarkers[id]!.markerData.notifier.alarm
                      ? null
                      : () {
                          global.listMapMarkers[id]!.markerData.notifier.changeAlarm();
                          changeBottomBarWidget(-1, null, null);
                        },
                  icon: !global.listMapMarkers[id]!.markerData.notifier.alarm
                      ? const Icon(Icons.warning_rounded)
                      : const Icon(
                          Icons.warning_rounded,
                          color: Color.fromARGB(220, 211, 44, 44),
                        ),
                ),
              ],
            ),
          );
        }
        if (bufMark.markerData.type == CSD.Name()) {
          widget.bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    var success = global.seismicPage.getSeismic();
                    if (success) global.globalKey.currentState?.changePage(5);
                  },
                  icon: const Icon(Icons.show_chart),
                ),
                IconButton(
                  onPressed: () {
                    var success = global.seismicPage.getLastSeismic();
                    if (success) global.globalKey.currentState?.changePage(5);
                  },
                  icon: const Icon(
                    Icons.show_chart,
                    color: Color.fromARGB(220, 211, 44, 44),
                  ),
                ),
                IconButton(
                  onPressed: !global.listMapMarkers[id]!.markerData.notifier.alarm
                      ? null
                      : () {
                          global.listMapMarkers[id]!.markerData.notifier.changeAlarm();
                          changeBottomBarWidget(-1, null, null);
                        },
                  icon: !global.listMapMarkers[id]!.markerData.notifier.alarm
                      ? const Icon(Icons.warning_rounded)
                      : const Icon(
                          Icons.warning_rounded,
                          color: Color.fromARGB(220, 211, 44, 44),
                        ),
                ),
              ],
            ),
          );
        }
        if (bufMark.markerData.type == CPD.Name()) {
          widget.bottomBarWidget = SizedBox(
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    var success = global.imagePage.getPhoto(PhotoImageSize.IMAGE_160X120);
                    if (success) global.globalKey.currentState?.changePage(4);
                  },
                  icon: const Icon(Icons.photo_size_select_small),
                ),
                IconButton(
                  onPressed: () {
                    var success = global.imagePage.getPhoto(PhotoImageSize.IMAGE_320X240);
                    if (success) global.globalKey.currentState?.changePage(4);
                  },
                  icon: const Icon(Icons.photo_size_select_large),
                ),
                IconButton(
                  onPressed: () {
                    var success = global.imagePage.getPhoto(PhotoImageSize.IMAGE_640X480);
                    if (success) global.globalKey.currentState?.changePage(4);
                  },
                  icon: const Icon(Icons.photo_size_select_actual),
                ),
                IconButton(
                  onPressed: () {
                    global.globalKey.currentState?.changePage(4);
                    global.imagePage.openListFromOther();
                  },
                  icon: const Icon(Icons.photo_album_outlined),
                ),
                IconButton(
                  onPressed: !global.listMapMarkers[id]!.markerData.notifier.alarm
                      ? null
                      : () {
                          global.listMapMarkers[id]!.markerData.notifier.changeAlarm();
                          changeBottomBarWidget(-1, null, null);
                        },
                  icon: !global.listMapMarkers[id]!.markerData.notifier.alarm
                      ? const Icon(Icons.warning_rounded)
                      : const Icon(
                          Icons.warning_rounded,
                          color: Color.fromARGB(220, 211, 44, 44),
                        ),
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
            widget.saveMapMarkersInFile(),
          }
        : global.flagMoveMarker = true;
  }

  void changeLocationMarkerOnMap(LatLng point) {}

  void saveTile(String name) async {
    Directory? root = global.pathToProject;
    String directoryPath = '${root.path}/mapTiles';
    await Directory(directoryPath).create(recursive: true);
    String filePath = '$directoryPath/$name';
    //await File(filePath).create().then((file) => file.writeAsBytes());
    print(filePath);
  }

  LatLngBounds takeBounds() {
    var bounds = mapController.bounds!;
    print(mapController.bounds!.northWest);
    return bounds;
  }

  void chan(MapPosition pos, bool flag) {
    //print(mapController.bounds!.northWest);
    // print(mapController.bounds!.southEast);

    if (global.flagMoveMarker) {
      global.listMapMarkers[global.itemsMan.getSelected<mark.Marker>()!.id]!.point.latitude = pos.center!.latitude;
      global.listMapMarkers[global.itemsMan.getSelected<mark.Marker>()!.id]!.point.longitude = pos.center!.longitude;
      global.listMapMarkers[global.itemsMan.getSelected<mark.Marker>()!.id]!.markerData.cord!.latitude = pos.center!.latitude;
      global.listMapMarkers[global.itemsMan.getSelected<mark.Marker>()!.id]!.markerData.cord!.longitude = pos.center!.longitude;
      global.itemsMan.getSelected<mark.Marker>()!.setCoordinates(pos.center!.latitude, pos.center!.longitude);
      global.deviceParametersPage.updateDevice();
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
          keepAlive: true,
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
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayerOptions(markers: [myLocalPosition!]),
          MarkerLayerOptions(markers: global.listMapMarkers.values.toList()),
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
                opacity: 1,
                child: IconButton(
                  onPressed: findMarkerPosition,
                  icon: const Icon(
                    Icons.crop_free,
                    color: Color.fromARGB(250, 61, 174, 233),
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 1),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 60,
              child: Opacity(
                opacity: 1,
                child: IconButton(
                  onPressed: changeMapRotation,
                  icon: const Icon(
                    Icons.arrow_upward,
                    color: Color.fromARGB(250, 61, 174, 233),
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 1),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 60,
              child: Opacity(
                opacity: 1,
                child: IconButton(
                  onPressed: findMyPosition,
                  icon: const Icon(
                    Icons.location_searching,
                    color: Color.fromARGB(250, 61, 174, 233),
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 1),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 60,
              child: Opacity(
                opacity: 1,
                child: global.itemsMan.getSelected<mark.Marker>() != null
                    ? global.flagMoveMarker
                        ? IconButton(
                            onPressed: changeMoveFlag,
                            icon: const Icon(
                              Icons.pin_drop,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 1),
                              ],
                            ),
                          )
                        : IconButton(
                            onPressed: changeMoveFlag,
                            icon: const Icon(
                              Icons.pin_drop,
                              color: Color.fromARGB(250, 61, 174, 233),
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 1),
                              ],
                            ),
                          )
                    : null,
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: BottomAppBar(
        child: widget.bottomBarWidget,
      ),
    );
  }
}
