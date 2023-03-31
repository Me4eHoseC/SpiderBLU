import 'dart:async';

import 'package:flutter/material.dart';
import 'package:projects/Application.dart';
import 'package:projects/BasePackage.dart';
import 'package:projects/NetCommonPackages.dart';
import 'package:projects/NetPackagesDataTypes.dart';

import 'package:projects/RoutesManager.dart';

import './AllEnum.dart';
import 'NetNetworkPackages.dart';
import 'global.dart' as global;

class BluetoothPage extends StatefulWidget{
  final bool start;
  BluetoothPage({super.key, this.start = true});

  @override
  _BluetoothPage createState() => new _BluetoothPage();

}

class _BluetoothPage extends State<BluetoothPage>
    with AutomaticKeepAliveClientMixin<BluetoothPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Application.init();
    _startDiscovery();
  }

  void _startDiscovery() {
    global.stdConnectionManager.setStateOnDone = () {
      setState(() {});
    };
    setState(() {
      global.stdConnectionManager.searchAndConnect();
    });
  }

  void Disconnect() {
    setState(() {
      global.stdConnectionManager.Disconnect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: global.flagConnect
              ? Text(global.deviceName)
              : Text('None device'),
          actions: <Widget>[
            global.flagConnect
                ? IconButton(
                    onPressed: Disconnect,
                    icon: const Icon(Icons.cancel),
                  )
                : (global.stdConnectionManager.isDiscovering
                    ? FittedBox(
                        child: Container(
                          margin: const EdgeInsets.all(16.0),
                          child: const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: _startDiscovery,
                        icon: const Icon(Icons.replay),
                      )),
          ],
        ),
        body: Visibility(
            visible: global.std != null,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [],
                  ),
                  Container(width: 200, height: 500),
                ])));
  }
}
