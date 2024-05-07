import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:projects/radionet/PostManager.dart';
import 'package:projects/radionet/RoutesManager.dart';

import '../core/Marker.dart';
import '../core/RT.dart';
import '../global.dart' as global;
import '../radionet/BasePackage.dart';
import '../radionet/PackageTypes.dart';

class ScanDevice {
  int? id;
  String? type;
  bool? mapped;
  bool? represent;
  bool? answerFromDevice;

  ScanDevice(this.id, this.type, this.mapped, this.represent, this.answerFromDevice);
}

class ScanPage extends StatefulWidget with global.TIDManagement {
  ScanPage({super.key});

  late _ScanPage _page;

  void addAllFromMap() {
    _page.scanDevicesOnMap();
  }

  void addFromMap(int id, String type) {
    if (type == global.deviceTypeList[0]) {
      return;
    }
    ScanDevice item = ScanDevice(id, type, true, true, false);
    _page.listIdDevFromScan[id] = item;
    _page.listDataRow.clear();
    var list = _page.listIdDevFromScan.keys.toList();
    list.sort();
    for (var element in list) {
      _page.addListDataRow(_page.listIdDevFromScan[element]!);
    }
  }

  void addFromScan(int id, String type, bool mapped) {
    ScanDevice item = ScanDevice(id, type, mapped, true, true);
    _page.listIdDevFromScan[id] = item;
    _page.listDataRow.clear();
    var list = _page.listIdDevFromScan.keys.toList();
    list.sort();
    for (var element in list) {
      _page.addListDataRow(_page.listIdDevFromScan[element]!);
    }
  }

  void clearScanTable(int id) {
    _page.deleteDev(id);
  }

  void scan() {
    var receiver = RoutesManager.getBroadcastAddress();
    BasePackage getInfo = BasePackage.makeBaseRequest(receiver, PackageType.GET_PRESENCE);
    var tid = global.postManager.sendPackage(getInfo, PostType.Response, 1);
  }

  @override
  void acknowledgeReceived(int tid, BasePackage basePackage) {
    if (basePackage.getType() == PackageType.PRESENCE) {
      var sender = basePackage.getSender();
      if (global.itemsMan.getAllIds().contains(sender)) {
        if (global.itemsMan.get<STD>(sender) != null) {
          return;
        } else {
          if (_page.listIdDevFromScan.keys.contains(sender)) {
            _page.updateStatus(_page.listIdDevFromScan[sender]!);
          }
          addFromScan(sender, global.itemsMan.get<Marker>(sender)!.typeName(), true);
        }
      } else {
        if (_page.listIdDevFromScan.keys.contains(sender)) {
          _page.updateStatus(_page.listIdDevFromScan[sender]!);
        }
        addFromScan(sender, global.deviceTypeListForScanner[1], false);
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

  bool flagGetTime = true;
  bool flagGetCord = false;
  bool flagSelectAll = false;
  bool flagScanButton = false;

  Row rowChecksAndButtons = Row();
  Widget? deviceStatus, idWithCheck, typeDrop, checkMapped;

  Map<int, DataRow> listDataRow = {};
  Map<int, ScanDevice> listIdDevFromScan = {};

  Map<int, String> mapScanDev = {};
  Timer? timer;

  @override
  void initState() {
    super.initState();
    addScanDevices();

    Timer.periodic(Duration.zero, (_) {
      setState(() {});
    });
  }

  void updateStatus(ScanDevice dev) {
    dev.answerFromDevice = true;
    dev.represent = true;
    checkRepresentScanDev(dev);
    listDataRow[dev.id]?.cells[1] = DataCell(
      Center(
        child: idWithCheck,
      ),
    );
    listDataRow[dev.id]!.cells[0] = DataCell(
      Center(
        child: deviceStatus,
      ),
    );
  }

  void addListDataRow(ScanDevice item) {
    setState(() {
      dropDownType(item);
      checkRepresentScanDev(item);
      var row = DataRow(
        cells: [
          DataCell(
            Center(
              child: deviceStatus!,
            ),
          ),
          DataCell(
            Center(
              child: idWithCheck!,
            ),
          ),
          DataCell(
            Center(
              child: typeDrop!,
            ),
          ),
          DataCell(
            Center(
              child: Checkbox(
                value: item.mapped,
                onChanged: null,
              ),
            ),
          ),
        ],
      );
      listDataRow[item.id!] = row;
      mapScanDev[item.id!] = item.type!;
    });
  }

  void selectAll(bool flag) {
    listIdDevFromScan.forEach((key, value) {
      if (flag) {
        mapScanDev[key] = value.type!;
        flagSelectAll = flag;
      } else {
        mapScanDev.remove(key);
        flagSelectAll = flag;
      }
      value.represent = flag;
      checkRepresentScanDev(value);
      listDataRow[key]!.cells[0] = DataCell(
        Center(
          child: deviceStatus,
        ),
      );
      listDataRow[key]!.cells[1] = DataCell(
        Center(
          child: idWithCheck,
        ),
      );
    });
    flag ? flagSelectAll = false : flagSelectAll = true;
  }

  void checkMappedScanDev(ScanDevice dev) {
    setState(() {
      checkMapped = Checkbox(
        value: dev.mapped,
        onChanged: null,
      );
    });
  }

  void checkRepresentScanDev(ScanDevice dev) {
    setState(() {
      deviceStatus = Icon(
        Icons.circle,
        color: dev.answerFromDevice != false ? Colors.green : Colors.amber,
      );
      idWithCheck = CheckboxListTile(
        visualDensity: const VisualDensity(horizontal: -4),
        title: Text(
          dev.id.toString(),
          style: const TextStyle(fontSize: 20),
        ),
        value: dev.represent,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (bool? value) {
          setState(() {
            dev.represent = value;
            checkRepresentScanDev(dev);
            if (listDataRow.keys.contains(dev.id!)) {
              if (dev.represent! == true) {
                mapScanDev[dev.id!] = dev.type!;
              } else {
                mapScanDev.remove(dev.id!);
              }
              listDataRow[dev.id]!.cells[0] = DataCell(
                Center(
                  child: deviceStatus!,
                ),
              );
              listDataRow[dev.id]!.cells[1] = DataCell(
                Center(
                  child: idWithCheck!,
                ),
              );
            }
          });
        },
      );
    });
  }

  void dropDownType(ScanDevice dev) {
    setState(() {
      typeDrop = DropdownButton<String>(
        alignment: AlignmentDirectional.topCenter,
        onChanged: (String? value) {
          dev.type = value!;
          dropDownType(dev);
          if (mapScanDev.keys.contains(dev.id!)) {
            mapScanDev[dev.id!] = dev.type!;
          }

          if (listDataRow.keys.contains(dev.id!)) {
            listDataRow[dev.id]!.cells[2] = DataCell(
              Center(
                child: typeDrop,
              ),
            );
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CheckboxListTile(
            title: const Icon(Icons.access_time_outlined),
            value: flagGetTime,
            controlAffinity: ListTileControlAffinity.leading,
            visualDensity: const VisualDensity(horizontal: -5),
            onChanged: (bool? value) {
              flagGetTime = value!;
              addScanDevices();
            },
          ),
        ),
        Expanded(
          child: CheckboxListTile(
            title: const Icon(Icons.location_pin),
            value: flagGetCord,
            visualDensity: const VisualDensity(horizontal: -5),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? value) {
              flagGetCord = value!;
              addScanDevices();
            },
          ),
        ),
        Expanded(
          child: Container(),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              addCheckedDevOnMap();
            },
            child: const Text(
              'Apply',
            ),
          ),
        ),
      ],
    );
  }

  void addCheckedDevOnMap() {
    listIdDevFromScan.forEach((key, value) {
      var item = global.itemsMan.get<Marker>(key);

      if (mapScanDev.containsKey(key)) {
        value.mapped = true;

        if (item == null) {
          global.pageWithMap
              .createMarkerFromScanner(key, value.type!, global.devicesTablePage.takeCordForNewDev(), flagGetTime, flagGetCord);
        } else if (item.typeName() != value.type) {
          global.pageWithMap.changeMapMarkerType(key, item.typeName(), value.type!);
        }
      } else if (listDataRow.containsKey(key) && item != null) {
        global.pageWithMap.deleteMapMarker(key);
        value.mapped = false;
      }

      checkMappedScanDev(value);
      listDataRow[key]!.cells[3] = DataCell(
        Center(
          child: checkMapped,
        ),
      );
    });
  }

  void clearScanDevices() {
    setState(() {
      var devicesOnMap = global.itemsMan.getAllIds();
      var listForDelete = [];
      listDataRow.forEach((key, value) {
        if (!devicesOnMap.contains(key)) {
          listForDelete.add(key);
        }
      });
      for (var element in listForDelete) {
        mapScanDev.remove(element);
        listIdDevFromScan.remove(element);
        listDataRow.remove(element);
      }
    });
  }

  void scanDevicesOnMap() {
    bool flag = false;
    var devicesOnMap = global.itemsMan.getAllIds();

    for (var i in devicesOnMap) {
      if (listIdDevFromScan.containsKey(i)) {
        flag = true;
        return;
      }
      if (!flag) {
        var dev = global.itemsMan.get<Marker>(i);
        widget.addFromMap(dev!.id, dev.typeName());
      }
      flag = false;
    }
  }

  void scanDevices() {
    setState(() {
      flagScanButton = true;
      timer = Timer(Duration(seconds: 15), () {
        flagScanButton = false;
      });
      scanDevicesOnMap();
      widget.scan();
      flagSelectAll = false;
    });
  }

  void deleteDev(int id) {
    var devicesOnMap = global.itemsMan.getAllIds();
    if (listDataRow.keys.contains(id) && !devicesOnMap.contains(id)) {
      mapScanDev.remove(id);
      listDataRow.remove(id);
      listIdDevFromScan.remove(id);
    }
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
                  selectAll(flagSelectAll);
                },
                child: flagSelectAll
                    ? const Text(
                        'Select All',
                        style: TextStyle(color: Colors.white),
                      )
                    : const Text(
                        'Unselect All',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              ElevatedButton(
                onPressed: () {
                  clearScanDevices();
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: flagScanButton
                    ? null
                    : () {
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
              horizontalMargin: 10,
              columnSpacing: 20,
              border: TableBorder.all(width: 1),
              columns: const [
                DataColumn(
                  label: Expanded(
                    child: Text(
                      '',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'ID',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Type',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Mapped',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
              rows: listDataRow.values.toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.only(right: 27),
          child: rowChecksAndButtons,
        ),
      ),
    );
  }
}
