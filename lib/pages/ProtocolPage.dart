import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../global.dart' as global;
import '../localNotification.dart';

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

  void addAlarm(String alarm) {
    alarmArray.add(alarm);
    _page.checkNewAlarm();
  }

  void createNotification(String title, String body, int id){
    _page.notification(title, body, id);
  }
}

class _ProtocolPage extends State<ProtocolPage> with TickerProviderStateMixin {
  bool get wantKeepAlive => true;

  late final LocalNotificationService service;
  int check = 0;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    service = LocalNotificationService();
    service.initialize();
    super.initState();
  }

  void notification(String title, String body, int id) {
    if (check == 0){
      check = 10;
    }
    service.showNotification(id: check, title: title, body: body, payload: id);
    check--;
  }

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
