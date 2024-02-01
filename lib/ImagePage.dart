import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projects/BasePackage.dart';
import 'package:projects/core/CPD.dart';
import 'package:projects/core/Uint8Vector.dart';
import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';

import 'AllEnum.dart';
import 'NetPackagesDataTypes.dart';
import 'NetPhotoPackages.dart';
import 'RoutesManager.dart';
import 'global.dart' as global;

class ImagePage extends StatefulWidget with global.TIDManagement {
  ImagePage({super.key});
  List<String> array = [];

  int downloadingCpdId = -1;

  late _ImagePage _page;

  var photoTest = Uint8Vector(0);

  bool get isImageEmpty => photoTest.isEmpty;

  bool getPhoto(PhotoImageSize size) {
    if (downloadingCpdId != -1) return false;

    var cpd = global.itemsMan.getSelected<CPD>();
    if (cpd == null) return false;

    var photoComp = PhotoImageCompression.HIGH;
    var cc = PhotoRequestPackage();

    global.fileManager.setCameraImageProperty(cpd.id, size, photoComp);

    global.imagePage.downloadingCpdId = cpd.id;

    cc.setType(PackageType.GET_NEW_PHOTO);
    cc.setParameters(140, photoComp, size);
    cc.setBlackAndWhite(false);
    cc.setReceiver(cpd.id);
    cc.setSender(RoutesManager.getLaptopAddress());

    var tid = global.postManager.sendPackage(cc);
    tits.add(tid);
    return true;
  }

  void setImageSize(int fileSize) {
    photoTest = Uint8Vector(fileSize);
  }

  void addImagePart(Uint8List filePart) {
    photoTest.add(filePart);
  }

  void lastPartCome() {
    _page.save();
    downloadingCpdId = -1;
    var cpd = global.itemsMan.getSelected<CPD>();
    if (cpd == null) return;
  }

  void clearImage(DateTime? photoTime) {
    photoTest.clear();
    _page.clearImage();
    _page._dateLastPhoto = photoTime;
  }

  void redrawImage() {
    _page.redrawImage();
  }

  @override
  State createState() {
    _page = _ImagePage();
    return _page;
  }

  void openListFromOther() {
    _page._scaffoldKey.currentState!.openEndDrawer();
  }

  @override
  void acknowledgeReceived(int tid, BasePackage basePackage) {
    tits.remove(tid);
    array.add('acknowledgeReceived');
    global.dataComeFlag = true;
  }

  @override
  void dataReceived(int tid, BasePackage basePackage) {
    tits.remove(tid);
    if (basePackage.getType() == PackageType.TRAP_PHOTO_LIST) {
      var package = basePackage as PhototrapFilesPackage;
      var bufDev = package.getSender();
      if (global.itemsMan.getAllIds().contains(bufDev)) {
        global.itemsMan.get<CPD>(bufDev)?.phototrapFiles = package.getPhototrapFiles();
        print(package.getPhototrapFiles());
        _page.setPhotoList(global.itemsMan.get<CPD>(bufDev)!.id);
        array.add('dataReceived: ${package.getPhototrapFiles()}');
        global.pageWithMap.activateMapMarker(bufDev);
      }
    }
  }

  @override
  void ranOutOfSendAttempts(int tid, BasePackage? pb) {
    tits.remove(tid);
    if (global.itemsMan.getAllIds().contains(pb!.getReceiver()) && global.listMapMarkers[pb.getReceiver()]!.markerData.notifier.active) {
      global.pageWithMap.deactivateMapMarker(global.listMapMarkers[pb.getReceiver()]!.markerData.id!);
      array.add('RanOutOfSendAttempts');
      global.dataComeFlag = true;
    }
  }
}

class _ImagePage extends State<ImagePage> with TickerProviderStateMixin {
  bool get wantKeepAlive => true;
  MemoryImage? bufFirstImage, bufSecondImage;
  Widget firstImage = Container(), secondImage = Container();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _selectDateOfPhoto, _dateLastPhoto;
  String? downPhoto;
  List<Widget> listOfPhotoButton =
      List<Widget>.generate(10, growable: false, (index) => IconButton(onPressed: null, icon: Icon(Icons.ac_unit)));

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

  void save() async {
    Directory? root = await getDownloadsDirectory();
    String directoryPath = root!.path + '/photoTests';
    await Directory(directoryPath).create(recursive: true);
    String filePath = '$directoryPath/${_dateLastPhoto!.toLocal().toString().substring(0, 19)}.jpeg';
    File(filePath).writeAsBytes(bufSecondImage!.bytes);
    GallerySaver.saveImage(filePath, albumName: 'photoTest');
  }

  void endDownload() {
    widget.downloadingCpdId = -1;
    save();
  }

  void getPhotoList(int id) {
    var cc = BasePackage.makeBaseRequest(id, PackageType.GET_TRAP_PHOTO_LIST);
    var tid = global.postManager.sendPackage(cc);
    widget.tits.add(tid);
  }

  void setPhotoList(int id) {
    setState(() {
      var cpd = global.itemsMan.getSelected<CPD>();
      if (cpd == null) return;
      for (int i = 0; i < cpd.phototrapFiles.length; i++) {
        listOfPhotoButton[i] = RadioListTile(
          title: Text(
            '#${i + 1} - ${cpd.phototrapFiles[i].toLocal().toString().substring(0, 19)}',
          ),
          value: cpd.phototrapFiles[i],
          groupValue: _selectDateOfPhoto,
          onChanged: (DateTime? value) {
            setState(() {
              _selectDateOfPhoto = value;
              setPhotoList(id);
            });
          },
        );
      }
    });
  }

  void getPhototrapImage(int id, DateTime time) {
    widget.downloadingCpdId = id;

    global.fileManager.setCameraImageProperty(id, PhotoImageSize.IMAGE_SIZE_TRAP, PhotoImageCompression.HIGH);

    var cc = LastPhotoRequestPackage();
    cc.setImageSize(PhotoImageSize.IMAGE_SIZE_TRAP);
    cc.setFileTime(time);
    cc.setReceiver(id);
    cc.setSender(RoutesManager.getLaptopAddress());

    var tid = global.postManager.sendPackage(cc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _dateLastPhoto != null
            ? Text('# ${global.itemsMan.getSelected<CPD>()!.id} - ${_dateLastPhoto!.toLocal().toString().substring(0, 19)}')
            : const Text('null'),
      ),
      endDrawer: Drawer(
        width: 250,
        child: ListView(
          children: listOfPhotoButton +
              [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => {
                        global.itemsMan.getSelected<CPD>() != null ? {getPhotoList(global.itemsMan.getSelected<CPD>()!.id)} : null,
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                    IconButton(
                      onPressed: () => {
                        global.itemsMan.getSelected<CPD>() != null && _selectDateOfPhoto != null
                            ? {getPhototrapImage(global.itemsMan.getSelected<CPD>()!.id, _selectDateOfPhoto!)}
                            : null,
                      },
                      icon: const Icon(Icons.check),
                    ),
                  ],
                )
              ],
        ),
      ),
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
            onPressed: () => widget.getPhoto(PhotoImageSize.IMAGE_160X120),
            icon: const Icon(Icons.photo_size_select_small),
          ),
          IconButton(
            onPressed: () => widget.getPhoto(PhotoImageSize.IMAGE_320X240),
            icon: const Icon(Icons.photo_size_select_large),
          ),
          IconButton(
            onPressed: () => widget.getPhoto(PhotoImageSize.IMAGE_640X480),
            icon: const Icon(Icons.photo_size_select_actual),
          ),
          IconButton(
            onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
            icon: const Icon(Icons.photo_album_outlined),
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
