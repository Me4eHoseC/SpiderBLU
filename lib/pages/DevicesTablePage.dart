import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../core/Marker.dart';
import '../global.dart' as global;

class DevicesTablePage extends StatefulWidget with global.TIDManagement {
  DevicesTablePage({super.key});
  Map<int, TextButton> deviceTableList = {};

  late _DevicesTablePage _page;

  LatLng takeCordForNewDev(){
    return _page.takeCordForNewDevice();
  }

  void addDevice(int id) {
    ref();
  }

  void selectDevice(int id) {
    global.pageWithMap.selectMapMarker(id);
  }

  void deleteDevice(int id) {
    global.pageWithMap.askDeleteMapMarker(id);
  }

  void ref() {
    _page.refresh();
  }

  @override
  State createState() {
    _page = _DevicesTablePage();
    return _page;
  }
}

class _DevicesTablePage extends State<DevicesTablePage> with TickerProviderStateMixin {
  bool get wantKeepAlive => true;

  Column devTable = Column();
  List<Row> tableRow = [];
  List<TextButton> bufListButton = [];
  LatLng cordLastDev = LatLng(0, 0);
  double cordLat = 0, cordLon = 0;
  int colDev = 1, rowDev = 1;

  @override
  void initState() {
    super.initState();
    refresh();
    if (global.pageWithMap.coord() != null) {
      cordLastDev = global.pageWithMap.coord()!;
    }
    Timer.periodic(Duration.zero, (timer) {
      setState(() {});
    });
  }

  void refresh() {
    devTable = Column();
    tableRow = [];
    bufListButton = [];
    setState(() {});
    int z = 0;
    for (int i = 0; i < 256; i++) {
      if (global.itemsMan.get<Marker>(i) != null) {
        z += 1;
        bufListButton.add(
          TextButton(
            onPressed: () => widget.selectDevice(i),
            onLongPress: () => widget.deleteDevice(i),
            child: ListenableBuilder(
              listenable: global.listMapMarkers[i]!.markerData.notifier,
              builder: (context, child) => Ink.image(
                width: 60,
                height: 60,
                image: Image.asset(
                  global.listMapMarkers[i]!.markerData.notifier.imageStatus +
                      global.listMapMarkers[i]!.markerData.notifier.imageSelected +
                      global.listMapMarkers[i]!.markerData.notifier.imageName,
                  package: global.pageWithMap.setImagePackage(global.itemsMan.get<Marker>(i)!.typeName()),
                ).image,
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    i.toString(),
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
        if (z == 5) {
          tableRow.add(Row(
            children: bufListButton,
          ));
          z = 0;
          bufListButton = [];
        }
      }
      if (i == 255) {
        bufListButton.add(
          TextButton(
            onPressed: () => {},
            onLongPress: () => addNewDevice(),
            child: const Icon(
              Icons.add,
              size: 60,
            ),
          ),
        );
        if (bufListButton != []) {
          tableRow.add(Row(
            children: bufListButton,
          ));
          z = 0;
          bufListButton = [];
        }
      }
      //bufListButton.add(widget.deviceTableList.values);
    }
    devTable = Column(
      children: tableRow,
    );
  }

  LatLng takeCordForNewDevice() {
    var size = global.pageWithMap.takeMapBounds();
    if (cordLon * 8 - 0.001 > size.northWest.longitude - size.southEast.longitude ||
        cordLon * 8 + 0.001 < size.northWest.longitude - size.southEast.longitude ||
        cordLat - 0.001 > size.northWest.latitude - size.southEast.latitude ||
        cordLat + 0.001 < size.northWest.latitude - size.southEast.latitude) {
      rowDev = 1;
      colDev = 1;
    }
    cordLon = (size.northWest.longitude - size.southEast.longitude) / 8;
    cordLat = size.northWest.latitude - size.southEast.latitude;
    if (colDev == 6) {
      rowDev++;
      colDev = 1;
    }
    colDev++;
    LatLng coordinates = LatLng(size.northWest.latitude + cordLon * rowDev, size.northWest.longitude - cordLon * colDev);
    setState(() {});
    return coordinates;
  }

  void addNewDevice() {
    setState(() {
      global.pageWithMap.addNewDeviceOnMap(takeCordForNewDevice());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: devTable,
      ),
      bottomNavigationBar: BottomAppBar(
        child: global.pageWithMap.bottomBarWidget,
      ),
    );
  }
}
