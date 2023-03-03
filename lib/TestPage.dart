import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'global.dart' as global;

class TestPage extends StatefulWidget {
  @override
  _TestPage createState() => new _TestPage();
}

class _TestPage extends State<TestPage>
    with AutomaticKeepAliveClientMixin<TestPage> {
  bool get wantKeepAlive => true;
  bool checked = false;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration.zero, (_) {
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: checked
          ? Column(
              children: [
                TextButton(
                  onPressed: () {
                    print(checked);
                    if (checked) {
                      checked = false;
                    } else {
                      checked = true;
                    }
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => global.bluetoothPage));

                  },
                  child: Text('test'),
                ),
                TextButton(
                  onPressed: () {
                    print(checked);
                    if (checked) {
                      checked = false;
                    } else {
                      checked = true;
                    }
                  },
                  child: Text('test'),
                ),
              ],
            )
          : Column(
              children: [
                IconButton(
                    onPressed: (){
                      if (checked) {
                        checked = false;
                      } else {
                        checked = true;
                      }
                    },
                    icon: Icon(Icons.menu),
                ),
              ],
            ),
      /*TextButton(
        onPressed: () {
          print(checked);
          if (checked){
            checked = false;
          }
          else{
            checked = true;
          }
        },
        child:  Text('test'),
      ),*/
    );
  }
}
