import 'package:flutter/cupertino.dart';
import 'package:projects/events/alarmEvents.dart';
import 'package:projects/events/baseEvent.dart';
import 'package:projects/events/systemEvents.dart';
import 'package:projects/global.dart' as global;

class EventsManager{
  List<BaseEvent> events = [];

  void localeEvent(BuildContext context){
    global.protocolPage.localeEvent();
  }

  void addEvent(BaseEvent event, BuildContext context){
    if (event is AlarmEvent){
      if (event is BreaklineAlarmEvent){
      }
      global.protocolPage.addEvent(event);
      events.add(event);
    }
    if (event is SystemEvent){
      global.protocolPage.addEvent(event);
    }

  }
}