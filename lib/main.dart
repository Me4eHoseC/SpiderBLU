import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:projects/core/NetDevice.dart';
import 'package:projects/localNotification.dart';
import 'package:projects/std/STDConnectionManager.dart';
import 'package:provider/provider.dart';

import 'core/AIRS.dart';
import 'core/CPD.dart';
import 'core/CSD.dart';
import 'core/MCD.dart';
import 'core/RT.dart';
import 'global.dart' as global;

void main() {
  Provider.debugCheckInvalidValueType = null;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  MaterialColor getMaterialColor(Color color) {
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;
    final int alpha = color.alpha;

    final Map<int, Color> shades = {
      50: Color.fromARGB(alpha, red, green, blue),
      100: Color.fromARGB(alpha, red, green, blue),
      200: Color.fromARGB(alpha, red, green, blue),
      300: Color.fromARGB(alpha, red, green, blue),
      400: Color.fromARGB(alpha, red, green, blue),
      500: Color.fromARGB(alpha, red, green, blue),
      600: Color.fromARGB(alpha, red, green, blue),
      700: Color.fromARGB(alpha, red, green, blue),
      800: Color.fromARGB(alpha, red, green, blue),
      900: Color.fromARGB(alpha, red, green, blue),
    };

    return MaterialColor(color.value, shades);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: getMaterialColor(Colors.green[900]!),
      ),
      home: MyHomePage(key: global.globalKey, title: 'БРСК "Паук"'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => HomePageState();
}

class HomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  bool get wantKeepAlive => true;
  Timer? timer;
  String statusBarString = '';
  Widget list = Container();
  late FlutterGifController controller;

  int selectedBodyWidget = 1;
  int lastPage = -1;

  @override
  void initState() {
    global.getPermission();
    controller = FlutterGifController(vsync: this);
    repeatAnim();
    super.initState();

    global.stdConnectionManager.stdConnected = global.deviceParametersPage.stdConnected;
    global.packageProcessor.subscribers
        .addAll([global.deviceParametersPage, global.imagePage, global.seismicPage, global.pageWithMap, global.scanPage]);

    global.deviceTypeList = [];
    global.deviceTypeListForScanner = [];
    global.deviceTypeList.add(STD.Name());
    global.deviceTypeList.add(RT.Name());
    global.deviceTypeListForScanner.add(RT.Name());
    global.deviceTypeList.add(CSD.Name());
    global.deviceTypeListForScanner.add(CSD.Name());
    global.deviceTypeList.add(CPD.Name());
    global.deviceTypeListForScanner.add(CPD.Name());
    global.deviceTypeList.add(MCD.Name());
    global.deviceTypeListForScanner.add(MCD.Name());
    global.deviceTypeList.add(AIRS.Name());
    global.deviceTypeListForScanner.add(AIRS.Name());

    Timer.periodic(Duration.zero, (_) {
      setState(() {
        list = global.list;
      });
    });
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      changeStatusBarString();
    });
  }

  void onKeyDown() {}

  void repeatAnim() {
    controller.repeat(min: 0, max: 50, period: Duration(seconds: 2));
  }

  void changePage(int selectedPage) {
    lastPage = selectedBodyWidget;
    if (selectedPage != 1 && selectedPage != 2) {
      global.flagMapPage = false;
    } else {
      global.flagMapPage = true;
    }

    selectedBodyWidget = selectedPage;
    setState(() {});
  }

  void changeStatusBarString() {
    setState(() {
      statusBarString = global.statusBarString;
    });
  }

  @override
  Widget build(BuildContext context) {
    late Text stdIndicatorText;

    int stdId = global.std?.stdId ?? -1;
    var std = global.itemsMan.get<STD>(stdId);

    if (global.std != null && std != null) {
      var connectionType = global.stdInfo.type != StdConnectionType.UNDEFINED ? ' (${global.stdInfo.getConnectionType()})' : '';
      stdIndicatorText = Text('${STD().typeName()} #$stdId $connectionType - ${std.channel}${std.isMain ? '' : 'r'}');
    } else {
      stdIndicatorText = Text(STD().typeName());
    }

    return WillPopScope(
      onWillPop: () async {
        //alert();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 130,
          leading: SizedBox(
            height: 30,
            width: 30,
            child: GifImage(
              image: const AssetImage("packages/assets/gifs/spider.gif"),
              controller: controller,
            ),
          ),
          title: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 30,
                    child: Text(
                      statusBarString,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 100, child: list),
            ],
          ),
        ),
        drawerEdgeDragWidth: 0,
        drawer: Drawer(
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 50),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: global.std != null ? Colors.green : Colors.red,
                    ),
                    stdIndicatorText,
                  ],
                ),
              ),
              Column(
                children: [
                  ListTile(
                    title: const Text('Settings'),
                    onTap: () {
                      global.flagMapPage = false;
                      changePage(0);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Map'),
                    onTap: () {
                      global.flagMapPage = true;
                      changePage(1);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Devices Table'),
                    onTap: () {
                      global.flagMapPage = true;
                      changePage(2);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Device parameters'),
                    enabled: global.itemsMan.getSelected<NetDevice>() != null,
                    onTap: () {
                      global.flagMapPage = false;
                      changePage(3);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Photo'),
                    enabled: global.itemsMan.getSelected<CPD>() != null,
                    onTap: () {
                      global.flagMapPage = false;
                      changePage(4);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Seismic'),
                    enabled: global.itemsMan.getSelected<CSD>() != null,
                    onTap: () {
                      global.flagMapPage = false;
                      changePage(5);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Scanner'),
                    onTap: () {
                      global.flagMapPage = false;
                      global.scanPage.addAllFromMap();
                      changePage(6);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Protocol'),
                    onTap: () {
                      global.flagMapPage = false;
                      changePage(7);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        body: IndexedStack(
          index: selectedBodyWidget,
          children: global.pages,
        ),
        bottomNavigationBar: BottomAppBar(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) {
                    return FloatingActionButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      child: const Icon(
                        Icons.menu,
                        color: Colors.red,
                      ),
                    );
                  },
                ),
                global.mainBottomSelectedDev,
                Row(
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        if (lastPage < 0) {
                          return;
                        }
                        changePage(lastPage);
                      },
                      child: const Icon(
                        Icons.arrow_back_sharp,
                        color: Colors.red,
                      ),
                    ),
                    global.flagMapPage
                        ? Builder(
                            builder: (context) {
                              return FloatingActionButton(
                                onPressed: () {
                                  if (global.itemsMan.getSelected<NetDevice>() == null) {
                                    return;
                                  }
                                  changePage(3);
                                },
                                child: const Icon(
                                  Icons.settings,
                                  color: Colors.red,
                                ),
                              );
                            },
                          )
                        : Builder(
                            builder: (context) {
                              return FloatingActionButton(
                                onPressed: () => {
                                  changePage(1),
                                },
                                child: const Icon(
                                  Icons.map,
                                  color: Colors.red,
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
