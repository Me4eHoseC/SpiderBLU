import 'package:flutter/material.dart';
import 'dart:async';

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
        primarySwatch: Colors.grey,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
    with AutomaticKeepAliveClientMixin<MyHomePage> {
  @override
  bool get wantKeepAlive => true;
  Timer? timer;
  String statusBarString = '';

  int selectedBodyWidget = 0;

  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      changeStatusBarString();
    });
  }

  void changePage(int selectedPage) {
    setState(() {
      selectedBodyWidget = selectedPage;
    });
  }

  void changeStatusBarString(){
    setState(() {
      statusBarString = global.statusBarString;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 30,
        title: SizedBox(
          width: 400,
          height: 30,
          child: Text(
            statusBarString,
            textAlign: TextAlign.end,
          ),
        )
      ),
      //drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 0,
      drawer: Drawer(
        width: 200,
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('bluetooth page'),
              onTap: () {
                changePage(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('map page'),
              onTap: () {
                changePage(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('test page'),
              onTap: () {
                changePage(2);
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
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          child: const Icon(
            Icons.menu,
            color: Colors.red,
          ),
        );
      }),
    );
  }
}
