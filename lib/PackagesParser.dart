import 'dart:async';
import 'dart:typed_data';

import 'package:projects/BasePackage.dart';
import 'package:projects/AllEnum.dart';
import 'package:projects/NetCommonPackages.dart';
import 'package:projects/NetNetworkPackages.dart';
import 'package:projects/NetPhotoPackages.dart';
import 'package:projects/NetSeismicPackage.dart';
import 'package:projects/PostManager.dart';
import 'package:projects/RoutesManager.dart';

import 'FileManager.dart';
import 'global.dart' as global;

class Reference<T> {
  T value;

  Reference(this.value);
}

class PackagesParser {
  PackagesParser() {
    _buffer = Uint8List(0);
  }

  void addData(Uint8List data) {
    if (data.isEmpty) return;

    Uint8List newBuffer = Uint8List(data.length + _buffer.length);
    newBuffer.setAll(0, _buffer);
    newBuffer.setAll(_buffer.length, data);
    _buffer = newBuffer;

    while (_buffer.length >= BasePackage.minExpectedSize) {
      var ref = Reference<Uint8List>(_buffer);
      var pair = tryFindAndParsePackage(ref);
      _buffer = ref.value;

      if (pair.first == null) {
        if (pair.second) {
          continue;
        } else {
          break;
        }
      }
      BasePackage package = pair.first!;
      PackageType type = package.getType();

      if (package.getId() != 0) {
        if ((type == PackageType.ALARM || FileManager.isFileType(type)) &&
            !package.isAnswer()) {
          BasePackage answer = BasePackage.makeAcknowledge(package);

          global.postManager.sendAcknowledge(answer);
        }
      }

      bool isDuplicate = _checkDuplicate(package);

      if (isDuplicate) {
        continue;
      }

      if (package.getSize() == BasePackage.minExpectedSize) {
        if (package.isAnswer()) {
          Timer.run(() => acknowledgeReceived(package));
        } else {
          Timer.run(() => requestReceived(package));
        }
        continue;
      }

      if (FileManager.isFileType(type)) {
        Timer.run(() => filePartReceived(package as FilePartPackage));
      } else {
        Timer.run(() => dataReceived(package));
      }
    }
  }

  static global.Pair<BasePackage?, bool> tryFindAndParsePackage(
      Reference<Uint8List> dataRef) {
    var pair = global.Pair<BasePackage?, bool>(null, false);

    int index = _indexOfPackageHeader(dataRef.value, PACKAGE_HEAD_CODE);
    if (index == -1) return pair;

    dataRef.value =
        _reduceFixedList(dataRef.value, index, dataRef.value.length - index);

    int size = BasePackage.extractSize(dataRef.value);

    if (size == -1) return pair;
    if (size > dataRef.value.length) return pair;

    pair.second = true;

    bool isCorrectCrc = BasePackage.checkCrc(dataRef.value);

    if (!isCorrectCrc) {
      dataRef.value =
          _reduceFixedList(dataRef.value, 2, dataRef.value.length - 2);
      return pair;
    }

    PackageType type = BasePackage.extractType(dataRef.value);
    if (type == PackageType.NICE_ERROR_CODE) {
      dataRef.value =
          _reduceFixedList(dataRef.value, size, dataRef.value.length - size);
      return pair;
    }

    BasePackage package;
    if (size == BasePackage.minExpectedSize) {
      package = BasePackage();
    } else {
      package = _createAppropriatePackage(type);
    }

    bool parsed = package.tryParse(dataRef.value);

    if (!parsed) {
      dataRef.value =
          _reduceFixedList(dataRef.value, size, dataRef.value.length - size);
      return pair;
    }

    int myId = RoutesManager.getLaptopAddress();
    int broadcast = RoutesManager.getBroadcastAddress();

    int receiver = package.getReceiver();
    if (receiver != myId && receiver != broadcast) {
      dataRef.value =
          _reduceFixedList(dataRef.value, size, dataRef.value.length - size);
      return pair;
    }

    int sender = package.getSender();
    if (sender == myId) {
      dataRef.value =
          _reduceFixedList(dataRef.value, size, dataRef.value.length - size);
      return pair;
    }
    dataRef.value =
        _reduceFixedList(dataRef.value, size, dataRef.value.length - size);
    pair.first = package;

    return pair;
  }

  static Uint8List _reduceFixedList(
      Uint8List data, int skipCount, int newSize) {
    var newData = Uint8List(newSize);
    newData.setRange(0, newSize, data, skipCount);
    return newData;
  }

  static BasePackage _createAppropriatePackage(PackageType type) {
    switch (type) {
      // common packages
      case PackageType.ERROR_STAT:
        return ErrorCodePackage();
      case PackageType.SAFETY_CATCH:
        return ExternalPowerSafetyCatchPackage();
      case PackageType.AUTO_EXT_POWER:
        return AutoExternalPowerPackage();
      case PackageType.EXTERNAL_POWER:
        return ExternalPowerPackage();
      case PackageType.BATTERY_STATE:
        return BatteryStatePackage();
      case PackageType.ALL_INFORMATION:
        return AllInformationPackage();
      case PackageType.PERIPHERY:
        return PeripheryMaskPackage();
      case PackageType.EEPROM_FACTORS:
        return EEPROMFactorsPackage();
      case PackageType.INFORMATION:
        return InformationPackage();
      case PackageType.ALARM:
        return AlarmPackage();
      case PackageType.COORDINATE:
        return CoordinatesPackage();
      case PackageType.STATE:
        return StatePackage();
      case PackageType.TIME:
        return TimePackage();
      case PackageType.BATTERY_MONITOR:
        return BatteryMonitorPackage();
      case PackageType.VERSION:
        return VersionPackage();
      case PackageType.ALARM_REASON_MASK:
        return AlarmReasonMaskPackage();

      // seismic packages
      case PackageType.SIGNAL_SWING:
        return SeismicSignalSwingPackage();
      case PackageType.HUMAN_SENSITIVITY:
        return HumanSensitivityPackage();
      case PackageType.TRANSPORT_SENSITIVITY:
        return TransportSensitivityPackage();
      case PackageType.CRITERION_FILTER:
        return CriterionFilterPackage();
      case PackageType.SIGNAL_TO_NOISE_RATIO:
        return SignalToNoiseRatioPackage();
      case PackageType.CRITERION_RECOGNITION:
        return CriterionRecognitionPackage();

      // photo packages
      case PackageType.TRAP_ADDRESS:
        return PhototrapPackage();
      case PackageType.TRAP_PHOTO_LIST:
        return PhototrapFilesPackage();
      case PackageType.PHOTO_PARAMETERS:
        return PhotoParametersPackage();

      // network packages
      case PackageType.MODEM_NETWORK_NUM:
        return ModemNetworkNumberPackage();
      case PackageType.MODEM_FREQUENCY:
        return ModemFrequencyPackage();
      case PackageType.ALLOWED_HOPS:
        return HopsPackage();
      case PackageType.UNALLOWED_HOPS:
        return HopsPackage();

        //files packages
      case PackageType.PHOTO:
      case PackageType.SEISMIC_WAVE:
      case PackageType.ADPCM_SEISMIC_WAVE:
      case PackageType.MESSAGE:
        return FilePartPackage();

      default:
        return BasePackage();
    }
  }

  static int _indexOfPackageHeader(Uint8List data, int header) {
    Uint8List headerBytes = Uint8List(2);
    headerBytes.buffer.asByteData().setUint16(0, header, Endian.little);

    int index = 0;
    while (index != -1) {
      index = data.indexOf(headerBytes[0], index);

      if (index == -1) return -1;
      if (data.length < index + 2) return -1;

      if (data[index + 1] == headerBytes[1]) {
        return index;
      } else {
        index += 1;
      }
    }
    return -1;
  }

  static const int _journalVolume = 20;
  final Map<int, List<int>> _packagesJournal = {};

  int _getHashCode(BasePackage basePackage) {
    int hash = 0;
    hash |= basePackage.getType().index;
    hash << 16;
    hash |= basePackage.getSender();
    return hash;
  }

  bool _checkDuplicate(BasePackage basePackage) {
    bool isDuplicate = false;

    int id = basePackage.getId();
    int hash = _getHashCode(basePackage);

    bool containsJournalIt = _packagesJournal.containsKey(hash);

    if (!containsJournalIt) {
      _packagesJournal[hash] = List<int>.empty(growable: true);
      _packagesJournal[hash]!.insert(0, id);
      return containsJournalIt;
    }
    var record = _packagesJournal[hash]!;
    bool containsId = record.contains(id);

    if (containsId) {
      record.remove(id);
      isDuplicate = true;
    }

    if (record.length > _journalVolume) {
      record.removeLast();
    }

    record.insert(0, id);

    return isDuplicate;
  }

  Uint8List _buffer = Uint8List(0);

  late void Function(BasePackage) requestReceived;
  late void Function(BasePackage) acknowledgeReceived;
  late void Function(BasePackage) dataReceived;
  late void Function(FilePartPackage) filePartReceived;
}
