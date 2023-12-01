import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projects/core/Uint8Vector.dart';

import 'AllEnum.dart';
import 'NetPackagesDataTypes.dart';
import 'NetPhotoPackages.dart';
import 'RoutesManager.dart';
import 'global.dart' as global;

class ImagePage extends StatefulWidget {
  ImagePage({super.key});

  late _ImagePage _page;

  var photoTest = Uint8Vector(0);

  bool get isImageEmpty => photoTest.isEmpty;

  void setImageSize(int fileSize) {
    photoTest = Uint8Vector(fileSize);
  }

  void addImagePart(Uint8List filePart) {
    photoTest.add(filePart);
  }

  void lastPartCome() {
    global.globalMapMarker[global.selectedMapMarkerIndex].markerData.downloadPhoto = false;
  }

  void clearImage() {
    photoTest.clear();
    _page.clearImage();
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
  MemoryImage? bufFirstImage, bufSecondImage;
  Widget firstImage = Container(), secondImage = Container();

  void clearImage() {
    setState(() {
      firstImage = Container();
      secondImage = Container();
      bufSecondImage = null;
      print('CLEAR');
    });
  }

  void redrawImage() {
    setState(() {
      if (bufSecondImage != null) {
        bufFirstImage = bufSecondImage;
        firstImage = Image.memory(bufFirstImage!.bytes);
      } else {
        firstImage = Image.memory(widget.photoTest.data());
      }
      Uint8List dataBuf = Uint8List(widget.photoTest.size());
      dataBuf.setAll(0, widget.photoTest.data());

      bufSecondImage = MemoryImage(dataBuf);
      secondImage = Image.memory(bufSecondImage!.bytes);
    });
  }

  void endDownload() {
    global.globalMapMarker[global.selectedMapMarkerIndex].markerData.downloadPhoto = false;
  }

  void getPhoto(PhotoImageSize photoImageSize, int deviceId) {
    global.globalMapMarker[global.selectedMapMarkerIndex].markerData.downloadPhoto = true;
    var photoComp = PhotoImageCompression.HIGH;
    //var imageSize = PhotoImageSize.IMAGE_160X120;

    global.fileManager.setCameraImageProperty(deviceId, photoImageSize, photoComp);

    var cc = PhotoRequestPackage();
    cc.setType(PackageType.GET_NEW_PHOTO);
    cc.setParameters(140, photoComp, photoImageSize);
    cc.setBlackAndWhite(false);
    cc.setReceiver(deviceId);
    cc.setSender(RoutesManager.getLaptopAddress());

    var tid = global.postManager.sendPackage(cc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveViewer(
        trackpadScrollCausesScale: true,
        maxScale: 5,
        child: Center(
          child: !widget.isImageEmpty
              ? Stack(
                  children: <Widget>[
                    firstImage,
                    secondImage,
                  ],
                )
              : Container(),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => {
              global.globalMapMarker[global.selectedMapMarkerIndex].markerData.downloadPhoto == true
                  ? null
                  : getPhoto(PhotoImageSize.IMAGE_160X120, global.globalMapMarker[global.selectedMapMarkerIndex].markerData.id!),
            },
            icon: const Icon(Icons.photo_size_select_small),
          ),
          IconButton(
            onPressed: () => {
              global.globalMapMarker[global.selectedMapMarkerIndex].markerData.downloadPhoto == true
                  ? null
                  : getPhoto(PhotoImageSize.IMAGE_320X240, global.globalMapMarker[global.selectedMapMarkerIndex].markerData.id!),
            },
            icon: const Icon(Icons.photo_size_select_large),
          ),
          IconButton(
            onPressed: () => {
              global.globalMapMarker[global.selectedMapMarkerIndex].markerData.downloadPhoto == true
                  ? null
                  : getPhoto(PhotoImageSize.IMAGE_640X480, global.globalMapMarker[global.selectedMapMarkerIndex].markerData.id!),
            },
            icon: const Icon(Icons.photo_size_select_actual),
          ),
          IconButton(
            onPressed: endDownload,
            icon: const Icon(Icons.cancel_outlined),
          ),
        ],
      ),
    );
  }
}
