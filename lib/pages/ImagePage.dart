import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:projects/core/NetDevice.dart';
import 'dart:io';

import '../core/CPD.dart';

import '../radionet/PackageTypes.dart';
import '../utils/Uint8Vector.dart';

import '../radionet/BasePackage.dart';
import '../radionet/NetPackagesDataTypes.dart';
import '../radionet/NetPhotoPackages.dart';
import '../radionet/RoutesManager.dart';
import '../global.dart' as global;

class ImagePage extends StatefulWidget with global.TIDManagement {
  ImagePage({super.key});
  List<String> array = [];

  int downloadingCpdId = -1;

  late _ImagePage _page;

  var photoTest = Uint8Vector(0);

  bool get isImageEmpty => photoTest.isEmpty;

  bool getPhoto(PhotoImageSize size) {
    if (global.imagePage.downloadingCpdId != -1) return false;

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
  void dataReceived(int tid, BasePackage basePackage) {
    if (basePackage.getType() == PackageType.TRAP_PHOTO_LIST) {
      var package = basePackage as PhototrapFilesPackage;
      var sender = package.getSender();
      var cpd = global.itemsMan.get<CPD>(sender);
      if (cpd != null) {
        cpd.phototrapFiles = package.getPhototrapFiles();
        _page.setPhotoList(cpd.id);
      }
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
    Directory? root = global.pathToProject;
    String directoryPath = '${root.path}/photoTest';
    await Directory(directoryPath).create(recursive: true);
    String filePath = '$directoryPath/${_dateLastPhoto!.toLocal().toString().substring(0, 13)}-'
        '${_dateLastPhoto!.toLocal().toString().substring(14, 16)}-${_dateLastPhoto!.toLocal().toString().substring(17, 19)}.jpeg';
    await File(filePath).create().then((file) => file.writeAsBytes(bufSecondImage!.bytes));
  }

  void cancelPhotoDownload() {
    widget.downloadingCpdId = -1;
    global.stopMedia();
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
      appBar: _dateLastPhoto != null
          ? AppBar(
              title: Text('# ${global.itemsMan.getSelected<CPD>()!.id} - ${_dateLastPhoto!.toLocal().toString().substring(0, 19)}'),
            )
          : null,
      endDrawer: Drawer(
        width: 250,
        child: ListView(
          children: listOfPhotoButton +
              [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => {
                        global.itemsMan.getSelected<CPD>() != null ? {getPhotoList(global.itemsMan.getSelected<CPD>()!.id)} : null,
                      },
                      child: const Icon(Icons.refresh),
                    ),
                    OutlinedButton(
                      onPressed: () => {
                        global.itemsMan.getSelected<CPD>() != null && _selectDateOfPhoto != null
                            ? {getPhototrapImage(global.itemsMan.getSelected<CPD>()!.id, _selectDateOfPhoto!)}
                            : null,
                      },
                      child: const Icon(Icons.check),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          OutlinedButton(
            onPressed: widget.downloadingCpdId != -1 ? null : () => widget.getPhoto(PhotoImageSize.IMAGE_160X120),
            child: const Icon(Icons.photo_size_select_small),
          ),
          OutlinedButton(
            onPressed: widget.downloadingCpdId != -1 ? null : () => widget.getPhoto(PhotoImageSize.IMAGE_320X240),
            child: const Icon(Icons.photo_size_select_large),
          ),
          OutlinedButton(
            onPressed: widget.downloadingCpdId != -1 ? null : () => widget.getPhoto(PhotoImageSize.IMAGE_640X480),
            child: const Icon(Icons.photo_size_select_actual),
          ),
          OutlinedButton(
            onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
            child: const Icon(Icons.photo_album_outlined),
          ),
          OutlinedButton(
            onPressed: widget.downloadingCpdId == -1 ? null : cancelPhotoDownload,
            child: const Icon(Icons.cancel_outlined),
          ),
        ],
      ),
    );
  }
}
