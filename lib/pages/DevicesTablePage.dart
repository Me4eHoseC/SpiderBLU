import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/pages/PageWithMap.dart';

import '../core/Marker.dart';
import '../global.dart' as global;

class DevicesTablePage extends StatefulWidget with global.TIDManagement {
  DevicesTablePage({super.key});
  Map<int, TextButton> deviceTableList = {};

  late _DevicesTablePage _page;

  void addDevice(int id) {
   /* deviceTableList[id] = TextButton(
      onPressed: () => selectDevice(id),
      onLongPress: () => deleteDevice(id),
      child: ListenableBuilder(
        listenable: global.listMapMarkers[id]!.markerData.notifier,
        builder: (context, child) => Ink.image(
          width: 70,
          height: 70,
          image: Image.asset(
            global.listMapMarkers[id]!.markerData.notifier.imageStatus +
                global.listMapMarkers[id]!.markerData.notifier.imageSelected +
                global.listMapMarkers[id]!.markerData.notifier.imageName,
            package: global.pageWithMap.setImagePackage(global.itemsMan.get<Marker>(id)!.typeName()),
          ).image,
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              id.toString(),
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
    );*/
    ref();
  }

  void selectDevice(int id) {
    global.pageWithMap.selectMapMarker(id);
    print(global.listMapMarkers[id]!.markerData.notifier.imageSelected);
  }

  void deleteDevice(int id) {
    global.pageWithMap.deleteMapMarker(id);
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

  void refresh() {
    devTable = Column();
    tableRow = [];
    bufListButton = [];
    setState(() {});
    int z = 0;
    for (int i = 0; i < 255; i++) {
      if (global.itemsMan.get<Marker>(i) != null) {
        z += 1;
        bufListButton.add(
          TextButton(
            onPressed: () => widget.selectDevice(i),
            onLongPress: () => widget.deleteDevice(i),
            child: ListenableBuilder(
              listenable: global.listMapMarkers[i]!.markerData.notifier,
              builder: (context, child) => Ink.image(
                width: 70,
                height: 70,
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
        if (z == 4) {
          tableRow.add(Row(
            children: bufListButton,
          ));
          z = 0;
          bufListButton = [];
        }
      }
      if (i == 254 && z < 4 && z != 0) {
        tableRow.add(Row(
          children: bufListButton,
        ));
        z = 0;
        bufListButton = [];
      }
      //bufListButton.add(widget.deviceTableList.values);
    }
    devTable = Column(
      children: tableRow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
        ),
        body: devTable);
  }
}
