import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:projects/NetCommonPackages.dart';
import 'package:projects/PostManager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projects/core/Device.dart';
import 'package:projects/core/Uint8Vector.dart';
import 'AllEnum.dart';
import 'global.dart' as global;
import 'package:projects/BasePackage.dart';

abstract class TIDManagement {
  final List<int> tits = List.empty(growable: true);

  bool isMyTransaction(int tid) {
    return tits.contains(tid);
  }

  void dataReceived(int tid, BasePackage basePackage);
  void acknowledgeReceived(int tid, BasePackage basePackage);
  void ranOutOfSendAttempts(int tid, BasePackage? pb);
}

class Application {
  static void init() async {
    global.packagesParser.dataReceived = dataReceived;
    global.packagesParser.acknowledgeReceived = acknowledgeReceived;
    global.packagesParser.requestReceived = requestReceived;
    global.packagesParser.filePartReceived = global.fileManager.addFilePart;

    global.fileManager.fileDownloaded = fileDownloaded;
    global.fileManager.filePartReceived = filePartReceived;
    global.fileManager.fileDownloadStarted = fileDownloadStarted;
    global.fileManager.messageReceived = messageReceived;


    global.postManager.packageSendingAttempt = packageSendingAttempt;
    global.postManager.ranOutOfSendAttempts = ranOutOfSendAttempts;
  }

  static Uint8List _readFileByteSync(String filePath){
    Uint8List bytes;
    var file = File(filePath);
    bytes = file.readAsBytesSync();
    return bytes;
  }

  static void dataReceived(BasePackage basePackage) {
    int tid = -1;

    if (basePackage.isAnswer()) {
      tid = global.postManager.getRequestTransactionId(basePackage.getInvId());
      global.postManager.responseReceived(basePackage);
    }

    if (global.testPage.isMyTransaction(tid)) {
      global.testPage.dataReceived(tid, basePackage);
    }

    if (global.pageWithMap.isMyTransaction(tid)) {
      global.pageWithMap.dataReceived(tid, basePackage);
    }

    if (global.imagePage.isMyTransaction(tid)) {
      global.imagePage.dataReceived(tid, basePackage);
    }

    if (global.seismicPage.isMyTransaction(tid)) {
      global.seismicPage.dataReceived(tid, basePackage);
    }

    if (tid == -1) {
      global.testPage.alarmReceived(basePackage);
    }
  }

  static void acknowledgeReceived(BasePackage basePackage) {
    var tid =
        global.postManager.getRequestTransactionId(basePackage.getInvId());
    global.postManager.responseReceived(basePackage);

    if (global.testPage.isMyTransaction(tid)) {
      global.testPage.acknowledgeReceived(tid, basePackage);
    }
  }

  static void fileDownloadStarted(int sender, FilePartPackage filePartPackage){
    if (global.itemsManager.getDevice(sender)!.type == DeviceType.CPD){
      global.imagePage.clearImage(filePartPackage.getCreationTime());
    }

    if (global.itemsManager.getDevice(sender)!.type == DeviceType.CSD){
      global.seismicPage.clearSeismic(filePartPackage.getCreationTime());
      if (filePartPackage.getType() == PackageType.SEISMIC_WAVE){
        global.seismicPage.setADPCMMode(false);
      } else if(filePartPackage.getType() == PackageType.ADPCM_SEISMIC_WAVE){
        global.seismicPage.setADPCMMode(true);
      }
    }
  }

  static void filePartReceived(FilePartPackage filePartPackage) {
    var fp = filePartPackage;
    if (fp.getType() == PackageType.PHOTO) {
      if (global.imagePage.isImageEmpty) {
        global.imagePage.setImageSize(fp.getFileSize());
      }

      global.imagePage.addImagePart(fp.getPartData());
      global.imagePage.redrawImage();
    }

    if (fp.getType() == PackageType.SEISMIC_WAVE){
      global.seismicPage.addSeismicPart(fp.getPartData());
      global.seismicPage.plot();
      print ('Seismic part received');
    }

    if (fp.getType() == PackageType.ADPCM_SEISMIC_WAVE){
      global.seismicPage.addSeismicPart(fp.getPartData());
      global.seismicPage.plot();
      print ('Seismic ADPCM part received');
    }
  }

  static void fileDownloaded(int sender) {
    if (global.itemsManager.getDevice(sender)!.type == DeviceType.CPD){
      global.imagePage.lastPartCome();
    }

    if (global.itemsManager.getDevice(sender)!.type == DeviceType.CSD){
      print('END');
    }
    //global.imagePage.redrawImage();
  }

  static void requestReceived(BasePackage basePackage) {
    print('requestReceived');
  }

  static void ranOutOfSendAttempts(BasePackage? pb, int transactionId) {
    //global.globalMapMarker[id].markerData.deviceAvailable = false;
    print('RanOutOfSendAttempts');
    global.testPage.ranOutOfSendAttempts(transactionId, pb);
  }

  static void packageSendingAttempt(PackageSendingStatus sendingStatus) {
    print("#${sendingStatus.transactionId}: ${sendingStatus.attemptNumber}/"
        "${sendingStatus.totalAttemptNumber} -> #${sendingStatus.receiver}");
    global.statusBarString =
        ("#${sendingStatus.transactionId}: ${sendingStatus.attemptNumber}/"
            "${sendingStatus.totalAttemptNumber} -> #${sendingStatus.receiver}");
    timerClearStatusBar();
  }

  static void messageReceived(FilePartPackage filePartPackage){
    print (filePartPackage.getPartData());
  }

  static void timerClearStatusBar(){
    if (global.timer != null){
      print(global.timer);
      global.timer!.cancel();
      global.timer = Timer(Duration(seconds: 5), () {
        global.statusBarString = " ";
      });
    }
    else{
      global.timer = Timer(Duration(seconds: 5), () {
        global.statusBarString = " ";
      });
    }
  }
}
