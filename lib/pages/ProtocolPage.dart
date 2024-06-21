import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projects/events/alarmEvents.dart';
import 'package:projects/events/baseEvent.dart';
import 'package:projects/events/systemEvents.dart';
import 'package:projects/events/variosEvents.dart';

import '../global.dart' as global;
import '../localNotification.dart';
import '../main.dart';

class ProtocolPage extends StatefulWidget with global.TIDManagement {
  ProtocolPage({super.key});
  Widget protocolList = Container();
  List<String> listEvents = [];

  late _ProtocolPage _page;

  @override
  State createState() {
    _page = _ProtocolPage();
    return _page;
  }

  void localeEvent(){
    listEvents = [];
    for(int i = 0; i < global.eventsMan.events.length; i++){
      addEvent(global.eventsMan.events[i]);
    }
    _page.checkNewEvents();
  }

  void addEvent(BaseEvent event) {
    if (event is AlarmEvent){
      if (event is BreaklineAlarmEvent){
        listEvents.add('${DateFormat('yMd', MyApp.of(_page.context)!.getLocale().toString()).add_jms().format(event.dateTime)} '
            '${event.alarmDeviceIdToString(_page.context)} ${event.message(_page.context)}');
      }
    }
    _page.checkNewEvents();
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

  void checkNewEvents() {
    setState(() {
      widget.protocolList = ListView.builder(
          reverse: true,
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: //widget.alarmArray.length,
          widget.listEvents.length,
          itemBuilder: (context, i) {
            return Text(
              widget.listEvents[i],
              textScaleFactor: 1,
            );
          });
      if (widget.listEvents.length > 10) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.protocolList,
    );
  }
}
