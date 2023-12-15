import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projects/Application.dart';
import 'package:projects/BasePackage.dart';
import 'package:projects/core/Uint8Vector.dart';
import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';

import 'AllEnum.dart';
import 'NetPackagesDataTypes.dart';
import 'NetPhotoPackages.dart';
import 'RoutesManager.dart';
import 'global.dart' as global;

class ImagePage extends StatefulWidget with TIDManagement {
  ImagePage({super.key});
  List<String> array = [];

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
    _page.save();
    global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]?.markerData.downloadPhoto = false;
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

  void openListFromOther(){
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
      if (global.itemsManager.getItemsIds().contains(bufDev)) {
        global.itemsManager.getDevice(bufDev)?.phototrapFiles = package.getPhototrapFiles();
        print(package.getPhototrapFiles());
        _page.setPhotoList(global.itemsManager.getDevice(bufDev)!.id);
        array.add('dataReceived: ${package.getPhototrapFiles()}');
        global.pageWithMap.ActivateMapMarker(bufDev);
      }
    }
  }

  @override
  void ranOutOfSendAttempts(int tid, BasePackage? pb) {
    tits.remove(tid);
    if (global.itemsManager.getItemsIds().contains(pb!.getReceiver()) &&
        global.listMapMarkers[pb.getReceiver()]!.markerData.notifier.active) {
      global.pageWithMap.DeactivateMapMarker(global.listMapMarkers[pb.getReceiver()]!.markerData.id!);
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
    await Directory(directoryPath).create(recursive: false);
    String filePath = '$directoryPath/${_dateLastPhoto!.toLocal().toString().substring(0,19)}.jpeg';
      File(filePath).writeAsBytes(bufSecondImage!.bytes);
    GallerySaver.saveImage(filePath, albumName: 'photoTest');
  }

  void endDownload() {
    global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]?.markerData.downloadPhoto = false;
    save();
  }

  void getPhotoList(int id) {
    var cc = BasePackage.makeBaseRequest(id, PackageType.GET_TRAP_PHOTO_LIST);
    var tid = global.postManager.sendPackage(cc);
    widget.tits.add(tid);
  }

  void setPhotoList(int id) {
    setState(() {
      for (int i = 0; i < global.itemsManager.getSelectedDevice()!.phototrapFiles.length; i++) {
        listOfPhotoButton[i] = RadioListTile(
          title: Text('#${i+1} - ${global.itemsManager.getSelectedDevice()!.phototrapFiles[i].toLocal().toString().substring(0,19)}',),
          value: global.itemsManager.getSelectedDevice()!.phototrapFiles[i],
          groupValue: _selectDateOfPhoto,
          onChanged: (DateTime? value){
            setState(() {
              _selectDateOfPhoto = value;
              setPhotoList(id);
            });
          },
        );
      }
    });
  }

  void getPhotoFromTrap(int id, DateTime time) {
    global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]?.markerData.downloadPhoto = true;

    global.fileManager.setCameraImageProperty(id, PhotoImageSize.IMAGE_SIZE_TRAP, PhotoImageCompression.HIGH);

    var cc = LastPhotoRequestPackage();
    cc.setImageSize(PhotoImageSize.IMAGE_SIZE_TRAP);
    cc.setFileTime(time);
    cc.setReceiver(id);
    cc.setSender(RoutesManager.getLaptopAddress());

    var tid = global.postManager.sendPackage(cc);
  }

  void getPhoto(PhotoImageSize photoImageSize, int deviceId) {
    global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]?.markerData.downloadPhoto = true;
    var photoComp = PhotoImageCompression.HIGH;

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
      key: _scaffoldKey,
      appBar: AppBar(
        title: _dateLastPhoto != null
        ?Text(_dateLastPhoto!.toLocal().toString().substring(0,19))
            :Text('none'),
      ),
      endDrawer: Drawer(
        width: 250,
        child: ListView(
          children:listOfPhotoButton + [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => {
                    global.itemsManager.getSelectedDevice() != null
                        ? {getPhotoList(global.itemsManager.getSelectedDevice()!.id)}
                        : null,
                  },
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  onPressed: () => {
                    global.itemsManager.getSelectedDevice() != null && _selectDateOfPhoto != null
                        ? {getPhotoFromTrap(global.itemsManager.getSelectedDevice()!.id, _selectDateOfPhoto!)}
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
            onPressed: () => {
              global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]?.markerData.downloadPhoto == true
                  ? null
                  : getPhoto(
                      PhotoImageSize.IMAGE_160X120, global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]!.markerData.id!),
            },
            icon: const Icon(Icons.photo_size_select_small),
          ),
          IconButton(
            onPressed: () => {
              global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]?.markerData.downloadPhoto == true
                  ? null
                  : getPhoto(
                      PhotoImageSize.IMAGE_320X240, global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]!.markerData.id!),
            },
            icon: const Icon(Icons.photo_size_select_large),
          ),
          IconButton(
            onPressed: () => {
              global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]?.markerData.downloadPhoto == true
                  ? null
                  : getPhoto(
                      PhotoImageSize.IMAGE_640X480, global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]!.markerData.id!),
            },
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
