import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/CPD.dart';
import '../core/CSD.dart';
import '../core/MCD.dart';
import '../core/RT.dart';
import '../global.dart' as global;

class BluetoothPage extends StatefulWidget {
  final bool start;
  BluetoothPage({super.key, this.start = true});

  @override
  _BluetoothPage createState() => new _BluetoothPage();
}

class _BluetoothPage extends State<BluetoothPage> with TickerProviderStateMixin {
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    global.stdConnectionManager.stdConnected = global.deviceParametersPage.stdConnected;

    global.packageProcessor.subscribers.addAll([global.deviceParametersPage, global.imagePage, global.seismicPage, global.pageWithMap]);

    global.deviceTypeList = [];
    global.deviceTypeList.add(STD.Name());
    global.deviceTypeList.add(RT.Name());
    global.deviceTypeList.add(CSD.Name());
    global.deviceTypeList.add(CPD.Name());
    global.deviceTypeList.add(MCD.Name());
    _startDiscovery();
  }

  void alert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Enter bluetooth name"),
            actions: [
              TextField(
                controller: TextEditingController(text: global.deviceName),
                maxLength: 20,
                onChanged: (string) => global.deviceName = string,
                onSubmitted: (string) => global.deviceName = string,
              ),
              TextField(
                controller: TextEditingController(text: global.STDNum),
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                onChanged: (string) => global.STDNum = string,
                onSubmitted: (string) => global.STDNum = string,
              ),
              TextButton(
                onPressed: () {
                  //global.stdConnectionManager.searchAndConnect();
                  Navigator.pop(context);
                },
                child: Text('Accept'),
              ),
            ],
          );
        }).then(
      (value) {
        if (value == null) {
          print('dialog closed with on barrier dismissal or android back button');
          global.stdConnectionManager.searchAndConnect();
        }
      },
    );
    setState(() {});
  }

  void _startDiscovery() {
    global.stdConnectionManager.setStateOnDone = () {
      setState(() {});
    };
    setState(() {
      global.stdConnectionManager.searchAndConnect();
    });
  }

  void repeatDiscovery() {
    alert();
  }

  void disconnect() {
    setState(() {
      global.stdConnectionManager.disconnect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: global.flagConnect ? Text(global.deviceName) : const Text('None device'),
          actions: <Widget>[
            global.flagConnect
                ? IconButton(
                    onPressed: disconnect,
                    icon: const Icon(Icons.cancel),
                  )
                : (global.stdConnectionManager.isDiscovering
                    ? FittedBox(
                        child: Container(
                          margin: const EdgeInsets.all(16.0),
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: repeatDiscovery,
                        icon: const Icon(Icons.replay),
                      )),
          ],
        ),
        body: Visibility(
            visible: global.std != null,
            child: const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
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
              SizedBox(width: 200, height: 500),
            ])));
  }
}
