import 'dart:async';

import 'package:flutter/material.dart';

import 'global.dart' as global;

class ImagePage extends StatefulWidget {
  final bool start;
  ImagePage({super.key, this.start = true});

  @override
  _ImagePage createState() => new _ImagePage();
}

class _ImagePage extends State<ImagePage>
    with TickerProviderStateMixin {
  bool get wantKeepAlive => true;
  var photo = Image.memory(global.photoTest.data());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPhoto();
  }

  void checkPhoto(){
    setState(() {
      Timer.periodic(Duration(seconds: 1), (_) {
        photo = Image.memory(global.photoTest.data());
        global.imagePage = ImagePage();


      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          photo,
          Image(
            image: photo.image,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress){
              return Center(child: photo);
            },
          ),
        ],
      ),
    );
  }
}
