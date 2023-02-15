import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/AllEnum.dart';
import 'package:projects/BasePackage.dart';
import 'dart:async';

import 'global.dart' as global;

class DevicesList extends StatefulWidget {
  const DevicesList();

  @override
  _DevicesList createState() => new _DevicesList();
}

class _DevicesList extends State<DevicesList>
    with AutomaticKeepAliveClientMixin<DevicesList> {
  @override
  bool get wantKeepAlive => true;
  List<Widget> devicesListWidget = List.empty(growable: true);
  List<int> devicesListId = List.empty(growable: true);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (timer == null) {
      timer = Timer.periodic(Duration(seconds: 1), (_) {
        //checkListDevices();
      });
    }
  }

  void dispose() {
    super.dispose();
    timer!.cancel();
  }

  void checkListDevices() {
    setState(() {
      if (global.globalDevicesForCheck.isNotEmpty) {
        if (devicesListWidget.length < global.globalDevicesForCheck.length) {
          buildListDevices(devicesListWidget.length);
        }
      }
    });
  }

  void buildListDevices(int counter) {
    setState(() {
      print(devicesListWidget.length);
      for (int i = counter; i < global.globalDevicesForCheck.length; i++) {
        devicesListWidget.insert(
            i,
            TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.black),
                onPressed: () {
                  printClick(global.globalDevicesForCheck[i].toString());
                },
                child: Text(global.globalDevicesForCheck[i].toString())));
      }
    });
  }

  void getVersion(){
    var package = BasePackage.makeBaseRequest(195, PacketTypeEnum.GET_VERSION);

  }

  void getTime(){

  }

  void setTime(){

  }

  void printClick(String string) {}

  @override
  Widget build(BuildContext) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FloatingActionButton(onPressed: getVersion),
              FloatingActionButton(onPressed: getTime),
              FloatingActionButton(onPressed: setTime),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(),
              TextField(),
            ],
          )
        ],
      ),
    );
  }
}
