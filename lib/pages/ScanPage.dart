import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../global.dart' as global;

class ScanPage extends StatefulWidget with global.TIDManagement {
  ScanPage({super.key});

  late _ScanPage _page;

  @override
  State createState() {
    _page = _ScanPage();
    return _page;
  }
}

class _ScanPage extends State<ScanPage> with TickerProviderStateMixin {
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Row(
        children:[ Container(),]
      ),
    );
  }
}
