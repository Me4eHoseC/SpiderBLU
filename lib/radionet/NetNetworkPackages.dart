import 'dart:typed_data';

import 'BasePackage.dart';
import 'NetCommonFunctions.dart';

import 'PackageTypes.dart';

class HopsPackage extends BasePackage{
  List<int> _hops = [];

  HopsPackage(){
    setType(PackageType.SET_ALLOWED_HOPS);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is HopsPackage) {
      _hops = List<int>.from(other._hops);
    }
  }

  List<int> getHops(){
    return _hops;
  }
  void clearHops(){
    _hops.clear();
  }
  void addHop(int hop){
    if (_hops.length == MAX_NUM_HOP_ACTIVITY) return;
    _hops.add(hop);
  }

  void fillZeroHops([int totalSize = MAX_NUM_HOP_ACTIVITY]){
    var diff = totalSize - _hops.length;
    for (int i = 0; i < diff; ++i) {
      _hops.add(0);
    }
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    int bodySize = getSize() - BasePackage.minExpectedSize;
    int count = bodySize ~/ 2;

    for (int i = 0; i < count; ++i){
      var value = unpackMan.unpack<int>(2);
      success &= (value != null);
      if (!success) break;
      _hops.add(value!);
    }

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);
    success &= packMan.packAll(_hops, 2);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class ModemFrequencyPackage extends BasePackage {
  int _frequency = 0;
  
  ModemFrequencyPackage(){
    setType(PackageType.SET_MODEM_FREQUENCY);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is ModemFrequencyPackage) {
      _frequency = other._frequency;
    }
  }

  int getModemFrequency(){
    return _frequency;
  }
  void setModemFrequency(int value){
    _frequency = value;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(4);
    success &= (value != null);
    if (success) _frequency = value!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);
    success &= packMan.pack(_frequency, 4);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class ModemNetworkNumberPackage extends BasePackage {
  int _number = 0;

  ModemNetworkNumberPackage(){
    setType(PackageType.SET_MODEM_NETWORK_NUM);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is ModemNetworkNumberPackage) {
      _number = other._number;
    }
  }

  int getModemNumber(){
    return _number;
  }
  void setModemNumber(int value){
    if (value == 52) {
      return;  //TODO:WHY????
    }
    _number = value;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(1);
    success &= (value != null);
    if (success) _number = value!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);
    success &= packMan.pack(_number, 1);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

