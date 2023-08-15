import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_gif/flutter_gif.dart';

import 'global.dart' as global;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const MyHomePage(title: 'БРСК "Паук"'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => HomePageState();
}

class HomePageState extends State<MyHomePage>
    with TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  Timer? timer;
  String statusBarString = '';
  Widget list = Container();
  late FlutterGifController controller;

  int selectedBodyWidget = 0;

  void initState() {
    controller = FlutterGifController(vsync: this);
    repeatAnim();
    super.initState();
    Timer.periodic(Duration.zero, (_) {
      setState(() {
        list = global.list;
      });
    });
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      changeStatusBarString();
    });
  }

  void repeatAnim(){
    controller.repeat(min:0, max: 50, period: Duration(seconds: 2));
  }

  void changePage(int selectedPage) {
    setState(() {
      selectedBodyWidget = selectedPage;
    });
  }

  void changeStatusBarString() {
    setState(() {
      statusBarString = global.statusBarString;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 130,
        leading: SizedBox(
          height: 30,
          width: 30,
          child: GifImage(
            image: const AssetImage("assets/gifs/spider.gif"),
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
        child: ListView(
          children: [
            ListTile(
              title: const Text('bluetooth page'),
              onTap: () {
                global.flagMapPage = false;
                changePage(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('map page'),
              onTap: () {
                global.flagMapPage = true;
                changePage(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('test page'),
              onTap: () {
                global.flagMapPage = false;
                changePage(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('image page'),
              onTap: () {
                global.flagMapPage = false;
                changePage(3);
                Navigator.pop(context);
              },
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
              Builder(builder: (context) {
                return FloatingActionButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  child: const Icon(
                    Icons.menu,
                    color: Colors.red,
                  ),
                );
              }),
              global.mainBottomSelectedDev,
              global.flagMapPage
                  ? Builder(builder: (context) {
                      return FloatingActionButton(
                        onPressed: () => {
                          changePage(2),
                          global.flagMapPage = false,
                        },
                        child: const Icon(
                          Icons.settings,
                          color: Colors.red,
                        ),
                      );
                    })
                  : Builder(builder: (context) {
                      return FloatingActionButton(
                        onPressed: () => {
                          changePage(1),
                          global.flagMapPage = true,
                        },
                        child: const Icon(
                          Icons.map,
                          color: Colors.red,
                        ),
                      );
                    }),
            ],
          ),
        ),
      ),
    );
  }
}
