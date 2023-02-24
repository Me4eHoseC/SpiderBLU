import 'package:projects/NetNetworkPackages.dart';
import 'package:projects/PostManager.dart';

import 'global.dart' as global;
import 'package:projects/BasePackage.dart';
import 'AllEnum.dart';
import 'NetCommonPackages.dart';

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

    /*var pages = [global.bluetoothPage, *//**//*];

    for (TIDManagement page in pages) {
      if (page.isMyTransaction(tid)) {
        page.dataReceived(tid, basePackage);
        break;
      }
    }*/

    if (global.bluetoothPage.isMyTransaction(tid)) {
      global.bluetoothPage.dataReceived(tid, basePackage);
    }

    if (tid == -1){
      global.bluetoothPage.alarmReceived(basePackage);
    }

  }

  static void acknowledgeReceived(BasePackage basePackage) {
    var tid =
        global.postManager.getRequestTransactionId(basePackage.getInvId());
    global.postManager.responseReceived(basePackage);

    if (global.bluetoothPage.isMyTransaction(tid)) {
      global.bluetoothPage.acknowledgeReceived(tid, basePackage);
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
  }

  static void packageSendingAttempt(PackageSendingStatus sendingStatus) {
    print("#${sendingStatus.transactionId}: ${sendingStatus.attemptNumber}/"
        "${sendingStatus.totalAttemptNumber} -> #${sendingStatus.receiver}");
  }
}
