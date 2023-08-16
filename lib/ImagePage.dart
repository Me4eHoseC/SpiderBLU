import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:projects/core/Uint8Vector.dart';


class ImagePage extends StatefulWidget {
  ImagePage({super.key});

  late _ImagePage _page;

  var photoTest = Uint8Vector(0);

  bool get isImageEmpty => photoTest.isEmpty;

  void setImageSize(int fileSize){
    photoTest = Uint8Vector(fileSize);
  }

  void addImagePart(Uint8List filePart){
    photoTest.add(filePart);
  }

  void clearImage(){
    photoTest.clear();
  }

  void redrawImage() {
    _page.redrawImage();
  }

  @override
  State createState() {
    _page = _ImagePage();
    return _page;
  }
}

class _ImagePage extends State<ImagePage> with TickerProviderStateMixin {
  bool get wantKeepAlive => true;

  void redrawImage() {
    MemoryImage(widget.photoTest.data()).evict();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: !widget.isImageEmpty ? Image.memory(widget.photoTest.data(), key: UniqueKey())
                                        : Image.asset("assets/320x240.jpeg")));
  }
}
