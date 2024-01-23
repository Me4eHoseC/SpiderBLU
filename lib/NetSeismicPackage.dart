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
    setType(PackageType.GET_SEISMIC_WAVE);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is SeismicRequestPackage) {
       _isZipped = other._isZipped;
       _arg1 = other._arg1;
       _arg2 = other._arg2;
    }
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
    setType(PackageType.SET_HUMAN_SENSETIVITY);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is HumanSensitivityPackage) {
      _sensitivity = other._sensitivity;
    }
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

class HumanFreqThresholdPackage extends BasePackage{
  int _freqThreshold = 0;

  HumanFreqThresholdPackage(){
    setType(PackageType.SET_HUMAN_FREQ_THRESHOLD);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is HumanFreqThresholdPackage) {
      _freqThreshold = other._freqThreshold;
    }
  }

  int getHumanFreqThresholdPackage(){
    return _freqThreshold;
  }
  void setHumanFreqThresholdPackage(int value){
    _freqThreshold = value;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var value = unpackMan.unpack<int>(2);
    success &= (value != null);
    if (success) _freqThreshold = value!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);
    success &= packMan.pack(_freqThreshold, 2);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class TransportSensitivityPackage extends BasePackage{
  int _sensitivity = 0;

  TransportSensitivityPackage(){
    setType(PackageType.SET_TRANSPORT_SENSETIVITY);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is TransportSensitivityPackage) {
      _sensitivity = other._sensitivity;
    }
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
    setType(PackageType.SET_CRITERION_FILTER);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is CriterionFilterPackage) {
      _criterion = other._criterion;
    }
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
    setType(PackageType.SET_CRITERION_RECOGNITION);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is CriterionRecognitionPackage) {
      _criteria = List<int>.from(other._criteria);
    }
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
    int count = 0;
    if (_criteria.isEmpty){
      count = 0;
    } else {
      count =
          bodySize ~/ _criteria.length;
    }

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
    setType(PackageType.SET_SIGNAL_TO_NOISE_RATIO);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is SignalToNoiseRatioPackage) {
      _snr = other._snr;
    }
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
    setType(PackageType.SIGNAL_SWING);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is SeismicSignalSwingPackage) {
      _swing = other._swing;
    }
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