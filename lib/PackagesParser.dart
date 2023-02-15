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
      PacketTypeEnum type = package.getType();

      if (package.getId() != 0) {
        if (type == PacketTypeEnum.ALARM ||
            type == PacketTypeEnum.PHOTO ||
            type == PacketTypeEnum.SEISMIC_WAVE ||
            type == PacketTypeEnum.ADPCM_SEISMIC_WAVE ||
            type == PacketTypeEnum.MESSAGE) {
          BasePackage answer = BasePackage.makeAcknowledge(package);

          global.postManager.sendPackage(answer, PostType.Acknowledge);
        }
      }
      bool isDuplicate = _checkDuplicate(package);
      if (isDuplicate) {
        continue;
      }
      if (package.getSize() == BasePackage.minExpectedSize) {
        if (package.isAnswer()) {
          Timer(Duration.zero, () => acknowledgeReceived(package));
        } else {
          Timer(Duration.zero, () => requestReceived(package));
        }
        continue;
      }
      if (type == PacketTypeEnum.PHOTO ||
          type == PacketTypeEnum.SEISMIC_WAVE ||
          type == PacketTypeEnum.ADPCM_SEISMIC_WAVE ||
          type == PacketTypeEnum.MESSAGE) {
        Timer(
            Duration.zero, () => filePartReceived(package as FilePartPackage));
      } else {
        Timer(Duration.zero, () => dataReceived(package));
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

    PacketTypeEnum type = BasePackage.extractType(dataRef.value);
    if (type == PacketTypeEnum.NICE_ERROR_CODE) {
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

  static BasePackage _createAppropriatePackage(PacketTypeEnum type) {
    switch (type) {
      // common packages
      case PacketTypeEnum.EXTERNAL_POWER:
        return ExternalPowerPackage();
      case PacketTypeEnum.BATTERY_STATE:
        return BatteryStatePackage();
      case PacketTypeEnum.ALL_INFORMATION:
        return AllInformationPackage();
      case PacketTypeEnum.PERIPHERY:
        return PeripheryMaskPackage();
      case PacketTypeEnum.EEPROM_FACTORS:
        return EEPROMFactorsPackage();
      case PacketTypeEnum.INFORMATION:
        return InformationPackage();
      case PacketTypeEnum.ALARM:
        return AlarmPackage();
      case PacketTypeEnum.COORDINATE:
        return CoordinatesPackage();
      case PacketTypeEnum.STATE:
        return StatePackage();
      case PacketTypeEnum.TIME:
        return TimePackage();
      case PacketTypeEnum.BATTERY_MONITOR:
        return BatteryMonitorPackage();
      case PacketTypeEnum.VERSION:
        return VersionPackage();
      case PacketTypeEnum.ALARM_REASON_MASK:
        return AlarmReasonMaskPackage();

      // seismic packages
      case PacketTypeEnum.HUMAN_SENSITIVITY:
        return HumanSensitivityPackage();
      case PacketTypeEnum.TRANSPORT_SENSITIVITY:
        return TransportSensitivityPackage();
      case PacketTypeEnum.CRITERION_FILTER:
        return CriterionFilterPackage();
      case PacketTypeEnum.SIGNAL_TO_NOISE_RATIO:
        return SignalToNoiseRatioPackage();
      case PacketTypeEnum.CRITERION_RECOGNITION:
        return CriterionRecognitionPackage();

      // photo packages
      case PacketTypeEnum.TRAP_ADDRESS:
        return PhototrapPackage();
      case PacketTypeEnum.TRAP_PHOTO_LIST:
        return PhototrapFilesPackage();
      case PacketTypeEnum.PHOTO_PARAMETERS:
        return PhotoParametersPackage();

      // network packages
      case PacketTypeEnum.MODEM_NETWORK_NUM:
        return ModemNetworkNumberPackage();
      case PacketTypeEnum.MODEM_FREQUENCY:
        return ModemFrequencyPackage();
      case PacketTypeEnum.ALLOWED_HOPS:
        return HopsPackage();
      case PacketTypeEnum.UNALLOWED_HOPS:
        return HopsPackage();

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
