import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:projects/core/NetDevice.dart';
import 'package:projects/std/STDConnectionManager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/AIRS.dart';
import 'core/CPD.dart';
import 'core/CSD.dart';
import 'core/MCD.dart';
import 'core/RT.dart';
import 'global.dart' as global;
import 'localizations/app_localizations.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();

  static _MyApp? of(BuildContext context) => context.findAncestorStateOfType<_MyApp>();
}

class _MyApp extends State<MyApp> {
  Locale _locale = Locale('ru');
  ThemeData? _theme;

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
      Timer(Duration(seconds: 1), () {
        global.protocolPage.localeEvent();
      });
    });
  }

  Locale getLocale() {
    return _locale;
  }

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

  ColorScheme lightThemeColors(context) {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF202020),
      onPrimary: Colors.white60,
      secondary: Color(0xFFBBBBBB),
      onSecondary: Color(0xFFEAEAEA),
      error: Color(0xFFF32424),
      onError: Color(0xFFF32424),
      background: Colors.white,
      onBackground: Color(0xFFFFFFFF),
      surface: Color(0xFF202020),
      onSurface: Color(0xFF202020),
    );
  }

  ColorScheme darkThemeColors(context) {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.white60,
      onPrimary: Colors.white10,
      secondary: Color(0xFFBBBBBB),
      onSecondary: Colors.white10,
      error: Color(0xFFF32424),
      onError: Color(0xFFF32424),
      background: Color(0xFF202020),
      onBackground: Colors.white10,
      surface: Colors.white60,
      onSurface: Colors.white60,
    );
  }

  void setTheme(BuildContext context) {
    setState(() {
      if (global.darkMode) {
        _theme = darkThemeData(context);
      } else {
        _theme = lightThemeData(context);
      }
    });
  }

  ThemeData lightThemeData(BuildContext context) {
    return ThemeData(
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return null;
            }
            if (states.contains(MaterialState.selected)) {
              return Colors.blueAccent;
            }
            return null; // Use the component's default.
          },
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            return Colors.blueAccent; // Use the component's default.
          },
        ),
      ),
      scaffoldBackgroundColor: lightThemeColors(context).background,
      appBarTheme: AppBarTheme(
        backgroundColor: lightThemeColors(context).background,
        titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(color: lightThemeColors(context).primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightThemeColors(context).background,
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: lightThemeColors(context).primary),
      ),
      colorScheme: lightThemeColors(context),
      sliderTheme: SliderThemeData(overlayShape: SliderComponentShape.noOverlay),
    );
  }

  ThemeData darkThemeData(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: darkThemeColors(context).background,
      appBarTheme: AppBarTheme(
        backgroundColor: darkThemeColors(context).background,
        titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(color: darkThemeColors(context).primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkThemeColors(context).background,
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: darkThemeColors(context).primary),
      ),
      colorScheme: darkThemeColors(context),
      sliderTheme: SliderThemeData(overlayShape: SliderComponentShape.noOverlay),
    );
  }

  @override
  Widget build(BuildContext context) {
    setTheme(context);
    return MaterialApp(
      //themeMode: ThemeMode.system,
      locale: _locale,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: _theme,
      darkTheme: darkThemeData(context),
      themeMode: ThemeMode.system,
      home: MyHomePage(key: global.globalKey, title: "SpiderNet"),
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
  List<DropdownMenuItem<Locale>> dropdownLocaleItems = [];
  Locale? dropdownLocaleItem;

  int selectedBodyWidget = 1;
  int lastPage = -1;

  @override
  void initState() {
    global.getPermission();
    controller = FlutterGifController(vsync: this);
    repeatAnim();
    super.initState();
    dropdownLocaleItem = MyApp.of(context)!.getLocale();
    for (int i = 0; i < AppLocalizations.supportedLocales.length; i++) {
      var newItem = DropdownMenuItem(
        value: AppLocalizations.supportedLocales[i],
        child: Text(AppLocalizations.supportedLocales[i].languageCode),
      );
      dropdownLocaleItems.add(newItem);
    }

    global.stdConnectionManager.stdConnected = global.deviceParametersPage.stdConnected;
    global.packageProcessor.subscribers
        .addAll([global.deviceParametersPage, global.imagePage, global.seismicPage, global.pageWithMap, global.scanPage]);

    global.deviceTypeList = [];
    global.deviceTypeListForScanner = [];

    global.deviceTypeList.add(STD.Name());
    global.deviceTypeList.add(CSD.Name());
    global.deviceTypeList.add(RT.Name());
    global.deviceTypeList.add(CPD.Name());
    global.deviceTypeList.add(MCD.Name());
    global.deviceTypeList.add(AIRS.Name());
    global.deviceTypeListForScanner.add(RT.Name());
    global.deviceTypeListForScanner.add(CSD.Name());
    global.deviceTypeListForScanner.add(CPD.Name());
    global.deviceTypeListForScanner.add(MCD.Name());
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
      stdIndicatorText = Text('${AppLocalizations.of(context)!.stdName} #$stdId $connectionType - ${std.channel}${std.isMain ? '' : 'r'}');
    } else {
      stdIndicatorText = Text(AppLocalizations.of(context)!.stdName);
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
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: ListTile(
                      title: Icon(
                        Icons.circle,
                        color: global.std != null ? Colors.green : Colors.red,
                      ),
                      trailing: stdIndicatorText,
                    ),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.language),
                    trailing: DropdownButton<Locale>(
                      items: dropdownLocaleItems,
                      value: dropdownLocaleItem,
                      onChanged: (Locale? value) {
                        MyApp.of(context)!.setLocale(value!);
                        dropdownLocaleItem = value;
                        Timer(const Duration(milliseconds: 200), () {
                          if (global.itemsMan.getSelected<NetDevice>() != null) {
                            global.pageWithMap.selectMapMarker(global.itemsMan.getSelected<NetDevice>()!.id);
                            global.scanPage.changeLocale();
                          }
                          global.scanPage.changeLocale();
                        });
                      },
                    ),
                  ),
                  SwitchListTile(
                    title: Text(
                      AppLocalizations.of(context)!.darkMode,
                      style: TextStyle(fontSize: 14),
                    ),
                    value: global.darkMode,
                    onChanged: (bool newValue) {
                      global.darkMode = newValue;
                      MyApp.of(context)!.setTheme(context);
                      global.deviceParametersPage.changeTheme(Colors.white10);
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.settingsPage),
                    onTap: () {
                      global.flagMapPage = false;
                      changePage(0);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.mapPage),
                    onTap: () {
                      global.flagMapPage = true;
                      changePage(1);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.devicesTablePage),
                    onTap: () {
                      global.flagMapPage = true;
                      changePage(2);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.deviceParametersPage),
                    enabled: global.itemsMan.getSelected<NetDevice>() != null,
                    onTap: () {
                      global.flagMapPage = false;
                      changePage(3);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.imagePage),
                    enabled: global.itemsMan.getSelected<CPD>() != null,
                    onTap: () {
                      global.flagMapPage = false;
                      changePage(4);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.seismicPage),
                    enabled: global.itemsMan.getSelected<CSD>() != null,
                    onTap: () {
                      global.flagMapPage = false;
                      changePage(5);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.scannerPage),
                    onTap: () {
                      global.flagMapPage = false;
                      global.scanPage.addAllFromMap();
                      changePage(6);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.protocolPage),
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
          elevation: 0,
          shadowColor: Colors.white,
          child: SizedBox(
            height: 45,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: OutlinedButton(
                      onPressed: () => changePage(0),
                      child: GifImage(
                        height: 35,
                        image: const AssetImage("packages/assets/gifs/spider.gif"),
                        controller: controller,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        return OutlinedButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          child: const Icon(
                            Icons.menu,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: global.mainBottomSelectedDev,
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: global.flagMapPage
                        ? OutlinedButton(
                            onPressed: () {
                              if (global.itemsMan.getSelected<NetDevice>() == null) {
                                null;
                              }
                              changePage(3);
                            },
                            child: const Icon(
                              Icons.settings,
                            ),
                          )
                        : OutlinedButton(
                            onPressed: () => {
                              changePage(1),
                            },
                            child: const Icon(
                              Icons.map,
                            ),
                          ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: OutlinedButton(
                      onPressed: () {
                        if (lastPage < 0) {
                          null;
                        }
                        changePage(lastPage);
                      },
                      child: const Icon(
                        Icons.arrow_back_sharp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
