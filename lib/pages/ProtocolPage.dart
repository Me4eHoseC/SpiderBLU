import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../global.dart' as global;

class ProtocolPage extends StatefulWidget with global.TIDManagement {
  ProtocolPage({super.key});
  Widget protocolList = Container();
  List<String> alarmArray = [];

  late _ProtocolPage _page;

  @override
  State createState() {
    _page = _ProtocolPage();
    return _page;
  }

  void addAlarm(String alarm){
    alarmArray.add(alarm);
    _page.checkNewAlarm();
  }
}

class _ProtocolPage extends State<ProtocolPage> with TickerProviderStateMixin {
  bool get wantKeepAlive => true;

  ScrollController _scrollController = ScrollController();

  void checkNewAlarm() {
    setState(() {
      widget.protocolList = ListView.builder(
          reverse: true,
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: widget.alarmArray.length,
          itemBuilder: (context, i) {
            return Text(
              widget.alarmArray[i],
              textScaleFactor: 1,
            );
          });
      if (widget.alarmArray.length > 10) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protocol'),
      ),
      body: widget.protocolList,
    );
  }
}
