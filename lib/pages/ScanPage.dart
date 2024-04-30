import 'dart:async';

import 'package:flutter/material.dart';
import 'package:projects/radionet/PostManager.dart';
import 'package:projects/radionet/RoutesManager.dart';

import '../core/Marker.dart';
import '../core/RT.dart';
import '../global.dart' as global;
import '../radionet/BasePackage.dart';
import '../radionet/PackageTypes.dart';

class ScanDevices {
  int? id;
  String? type;
  bool? mapped;
  bool? represent;

  ScanDevices(this.id, this.type, this.mapped, this.represent);
}

class ScanPage extends StatefulWidget with global.TIDManagement {
  ScanPage({super.key});

  late _ScanPage _page;

  void addFromMap(int id, String type, bool mapped) {
    if (type == global.deviceTypeList[0]){
      return;
    }
    ScanDevices item = ScanDevices(id, global.itemsMan.get<Marker>(id)!.typeName(), mapped, mapped);
    _page.addListDataRow(item);
  }

  void clearScanTable(){
    _page.clearScanDevices();
  }

  void scan() {
    var receiver = RoutesManager.getBroadcastAddress();
    BasePackage getInfo = BasePackage.makeBaseRequest(receiver, PackageType.GET_PRESENCE);
    var tid = global.postManager.sendPackage(getInfo, PostType.Response, 1);
  }

  void acknowledgeReceived(int tid, BasePackage basePackage) {
    if (basePackage.getType() == PackageType.PRESENCE) {
      var sender = basePackage.getSender();
      if (global.itemsMan.getAllIds().contains(sender)) {
        print('contains $sender');
        if (global.itemsMan.get<STD>(sender) != null) {
          return;
        } else {
          ScanDevices item = ScanDevices(sender, global.itemsMan.get<Marker>(sender)!.typeName(), true, true);
          _page.addListDataRow(item);
        }
      } else {
        print("don't mapped $sender");
        ScanDevices item = ScanDevices(sender, global.deviceTypeListForScanner[0], false, false);
        _page.addListDataRow(item);
      }
    }
  }

  @override
  State createState() {
    _page = _ScanPage();
    return _page;
  }
}

class _ScanPage extends State<ScanPage> with TickerProviderStateMixin {
  bool get wantKeepAlive => true;

  bool flagGetTime = false;
  bool flagGetCord = false;

  Row rowChecksAndButtons = Row();
  Widget? typeDrop, checkRepresent;

  List<DataRow> listDataRow = [];

  Map<int,String> mapScanDev = {};

  @override
  void initState() {
    super.initState();
    addScanDevices();
    Timer.periodic(Duration.zero, (_) {
      setState(() {});
    });
  }

  void addListDataRow(ScanDevices dev) {
    setState(() {
      dropDownType(dev);
      checkRepresentScanDev(dev);
      var row = DataRow(
        cells: [
          DataCell(
            Text(dev.id.toString()),
          ),
          DataCell(
            typeDrop!,
          ),
          //DataCell(Text(dev.mapped.toString())),
          DataCell(
            Checkbox(
              value: dev.mapped,
              onChanged: null,
            ),
          ),
          DataCell(
            dev.mapped == true
                ? Checkbox(
                    value: dev.represent,
                    onChanged: null,
                  )
                : checkRepresent!,
          ),
        ],
      );
      for (int i = 0; i < listDataRow.length; i++) {
        if (listDataRow[i].cells[0].child.toString() == (Text(dev.id.toString())).toString()) {
          return;
        }
      }
      listDataRow.add(row);
    });
  }

  void checkRepresentScanDev(ScanDevices dev) {
    setState(() {
      checkRepresent = Checkbox(
        value: dev.represent,
        onChanged: (bool? value) {
          dev.represent = value;
          checkRepresentScanDev(dev);
          for (int i = 0; i < listDataRow.length; i++) {
            if (listDataRow[i].cells[0].child.toString() == (Text(dev.id.toString())).toString()) {
              print(dev.represent);
              if (dev.represent! == true){
                mapScanDev[dev.id!] = dev.type!;
              } else {
                mapScanDev.remove(dev.id!);
              }
              listDataRow[i].cells[3] = DataCell(checkRepresent!);
              print(mapScanDev.keys.length);
            }
          }
        },
      );
    });
  }

  void dropDownType(ScanDevices dev) {
    setState(() {
      typeDrop = DropdownButton<String>(
        alignment: AlignmentDirectional.topCenter,
        onChanged: (String? value) {
          dev.type = value!;
          dropDownType(dev);
          for (int i = 0; i < listDataRow.length; i++) {
            if (listDataRow[i].cells[0].child.toString() == (Text(dev.id.toString())).toString()) {
              print(dev.type);
              listDataRow[i].cells[1] = DataCell(typeDrop!);
            }
          }
        },
        value: dev.type,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_double_arrow_down),
        items: global.deviceTypeListForScanner.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );
    });
  }

  void addScanDevices() {
    rowChecksAndButtons = Row(
      children: [
        Expanded(
          flex: 2,
          child: CheckboxListTile(
            title: const Icon(Icons.access_time_outlined),
            value: flagGetTime,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? value) {
              flagGetTime = value!;
              addScanDevices();
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
              addScanDevices();
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              addCheckedDevOnMap();
            },
            child: const Text(
              'Add on map',
            ),
          ),
        ),
      ],
    );
  }

  void addCheckedDevOnMap(){
    for(int i = 0; i < mapScanDev.entries.length; i++){
      print(mapScanDev.entries.elementAt(i).key);
      global.pageWithMap.createMarkerFromScanner(mapScanDev.entries.elementAt(i).key, mapScanDev.entries.elementAt(i).value,
          global.devicesTablePage.takeCordForNewDev(), flagGetTime, flagGetCord);
    }
    if (mapScanDev.isNotEmpty){
      mapScanDev.clear();
      clearScanDevices();
      scanDevices();
    }
  }

  void clearScanDevices() {
    setState(() {
      listDataRow.clear();
    });
  }

  void scanDevices() {
    setState(() {
      widget.scan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Builder(
        builder: (context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  clearScanDevices();
                },
                child: const Text(
                  'Clear table',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  scanDevices();
                },
                child: const Text(
                  'Scan',
                ),
              ),
            ],
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: ListView(
          children: [
            DataTable(
              border: TableBorder.all(width: 1),
              columns: global.dataColumn,
              rows: listDataRow,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: rowChecksAndButtons,
      ),
    );
  }
}
