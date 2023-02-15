import 'dart:typed_data';

import 'BasePackage.dart';
import 'AllEnum.dart';
import 'NetCommonFunctions.dart';
import 'NetPackagesDataTypes.dart';

class SeismicRequestPackage extends BasePackage{
  bool _isZipped = false;
  int _arg1 = 0xFF;
  int _arg2 = 0xFF;

  SeismicRequestPackage(){
    setType(PacketTypeEnum.GET_SEISMIC_WAVE);
  }

  void setZippedFlag(bool isZipped){
    _isZipped = isZipped;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);
    if (_isZipped) {
      success &= packMan.pack(_arg1, 1);
      success &= packMan.pack(_arg2, 1);

    }
    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class HumanSensitivityPackage extends BasePackage{
  int _sensitivity = 0;

  HumanSensitivityPackage(){
    setType(PacketTypeEnum.SET_HUMAN_SENSETIVITY);
  }

  int getHumanSensitivity(){
    return _sensitivity;
  }
  void setHumanSensitivity(int value){
    _sensitivity = value;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(1);
    success &= (value != null);
    if (success) _sensitivity = value!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);
    success &= packMan.pack(_sensitivity, 1);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class TransportSensitivityPackage extends BasePackage{
  int _sensitivity = 0;

  TransportSensitivityPackage(){
    setType(PacketTypeEnum.SET_TRANSPORT_SENSETIVITY);
  }

  int getTransportSensitivity(){
    return _sensitivity;
  }
  void setTransportSensitivity(int value){
    _sensitivity = value;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(1);
    success &= (value != null);
    if (success) _sensitivity = value!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);
    success &= packMan.pack(_sensitivity, 1);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class CriterionFilterPackage extends BasePackage{
  int _criterion = 0;

  CriterionFilterPackage(){
    setType(PacketTypeEnum.SET_CRITERION_FILTER);
  }

  CriterionFilter getCriterionFilter(){
    return CriterionFilter.values[_criterion];
  }
  void setCriterionFilter(CriterionFilter filter){
    _criterion = filter.index;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(2);
    success &= (value != null);
    if (success) _criterion = value!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);
    success &= packMan.pack(_criterion, 2);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class CriterionRecognitionPackage extends BasePackage{
  List<int> _criteria = List.empty(growable: true);

  CriterionRecognitionPackage() {
    setType(PacketTypeEnum.SET_CRITERION_RECOGNITION);
  }

  int getCriteriaCount(){
    return _criteria.length;
  }
  int getCriterion(int index){
    return _criteria[index];
  }
  List<int> getCriteria(){
    return _criteria;
  }
  void pushBackCriteria(int value){
    _criteria.add(value);
  }
  void setCriterion(int index, int value){
    if (_criteria.length <= index) return;
    _criteria[index] = value;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    int bodySize = getSize() - BasePackage.minExpectedSize;
    int count =
        bodySize ~/ _criteria.length;

    if (count < 0) count = 0;

    for(int i = 0; i < count; ++i){
      var value = unpackMan.unpack<int>(1);
      success &= (value != null);

      if (!success) break;

      _criteria.add(value!);
    }

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);
    success &= packMan.packAll(_criteria, 1);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class SignalToNoiseRatioPackage extends BasePackage{
  int _snr = 0;

  SignalToNoiseRatioPackage(){
    setType(PacketTypeEnum.SET_SIGNAL_TO_NOISE_RATIO);
  }

  int getSignalToNoiseRatio(){
    return _snr;
  }
  void setSignalToNoiseRatio(int value){
    _snr = value;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(2);
    success &= (value != null);
    if (success) _snr = value!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);
    success &= packMan.pack(_snr, 2);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }

}

class SeismicSignalSwingPackage extends BasePackage{
  double _swing = 0;

  SeismicSignalSwingPackage(){
    setType(PacketTypeEnum.SIGNAL_SWING);
  }

  double getSignalSwing(){
    return _swing;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<double>(4);
    success &= (value != null);
    if (success) _swing = value!;

    return success;
  }
}