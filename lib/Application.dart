import 'dart:async';

import 'package:projects/PostManager.dart';

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
  static void init() {
    global.packagesParser.dataReceived = dataReceived;
    global.packagesParser.acknowledgeReceived = acknowledgeReceived;
    global.packagesParser.filePartReceived = filePartReceived;
    global.packagesParser.requestReceived = requestReceived;

    global.postManager.packageSendingAttempt = packageSendingAttempt;
    global.postManager.ranOutOfSendAttempts = ranOutOfSendAttempts;
  }

  static void dataReceived(BasePackage basePackage) {
    int tid = -1;

    if (basePackage.isAnswer()) {
      tid = global.postManager.getRequestTransactionId(basePackage.getInvId());
      global.postManager.responseReceived(basePackage);
    }

    /*var pages = [global.bluetoothPage, */ /**/ /*];

    for (TIDManagement page in pages) {
      if (page.isMyTransaction(tid)) {
        page.dataReceived(tid, basePackage);
        break;
      }
    }*/

    if (global.testPage.isMyTransaction(tid)) {
      global.testPage.dataReceived(tid, basePackage);
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

  static void filePartReceived(BasePackage basePackage) {
    print('filePartReceived');
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
