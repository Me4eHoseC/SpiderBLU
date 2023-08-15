import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:projects/RoutesManager.dart';

import 'AllEnum.dart';

import 'NetCommonFunctions.dart';

const int MAX_NUM_HOP_ACTIVITY = 40;

const int MAX_HOPS_NUM = 8;
//const int MAX_HOPS_NUM = 4;

const int HOP_BYTE_SIZE = 8 ~/ MAX_HOPS_NUM;

const int PACKAGE_HEAD_SIZE = 2;
const int PACKAGE_HEAD_CODE = 0xDEAD;

class BasePackage {
  static const int minExpectedSize = 20;
  int _head_code = PACKAGE_HEAD_CODE; // 2
  int _id = 0; // 2
  int _size = 0; // 1
  int _type = 0; // 1
  int _receiver = 0; // 2
  int _sender = 0; // 2
  List<int> _hops = List<int>.filled(MAX_HOPS_NUM, 0); // 8
  int _crc16 = 0; // 2

  copyWith(BasePackage other) {
    _head_code = other._head_code;
    _id = other._id;
    _size = other._size;
    _type = other._type;
    _receiver = other._receiver;
    _sender = other._sender;
    _crc16 = other._crc16;
    _hops = List<int>.from(other._hops);
  }

  int getHeadCode() {
    return PACKAGE_HEAD_CODE;
  }

  int getId() {
    return _id;
  }

  int getInvId() {
    return _id ^ 0xFFFF;
  }

  void setId(int newId) {
    _id = newId;
  }

  void setResponseId(BasePackage request) {
    _id = request.getInvId();
  }

  bool isMy() {
    return _sender == RoutesManager.getLaptopAddress();
  }

  bool isAnswer() {
    return isAnswerId(getId());
  }

  static bool isAnswerId(int id) {
    return id & (1 << 15) != 0;
  }

  int getSize() {
    return _size;
  }

  static int extractSize(Uint8List rawData) {
    int sizePos = 4; // 5th byte
    if (rawData.length < sizePos + 1) {
      return -1;
    }
    return rawData[sizePos];
  }

  PackageType getType() {
    return PackageType.values[_type];
  }

  void setType(PackageType type) {
    _type = type.index;
  }

  static PackageType extractType(Uint8List rawData) {
    int typePos = 5; // 6th byte
    if (rawData.length < typePos + 1) {
      return PackageType.NICE_ERROR_CODE;
    }
    return PackageType.values[rawData[typePos]];
  }

  int getReceiver() {
    return _receiver;
  }

  void setReceiver(int receiver) {
    _receiver = receiver;
  }

  int getSender() {
    return _sender;
  }

  void setSender(int sender) {
    _sender = sender;
  }

  int getPartner() {
    return isMy() ? _receiver : _sender;
  }

  int getHopsSize() {
    return MAX_HOPS_NUM;
  }

  int getHop(int index) {
    return _hops[index];
  }

  bool isInHops(int hopId) {
    return _hops.contains(hopId);
  }

  int getCrc16() {
    return _crc16;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);
    success &= unpackHeader(unpackMan);
    return success;
  }

  @protected
  bool unpackHeader(UnpackMan unpackMan) {
    bool success = true;

    var value = unpackMan.unpack<int>(2);
    success &= (value != null);
    if (success) _head_code = value!;

    value = unpackMan.unpack<int>(2);
    success &= (value != null);
    if (success) _id = value!;

    value = unpackMan.unpack<int>(1);
    success &= (value != null);
    if (success) _size = value!;

    value = unpackMan.unpack<int>(1);
    success &= (value != null);
    if (success) _type = value!;

    value = unpackMan.unpack<int>(2);
    success &= (value != null);
    if (success) _receiver = value!;

    value = unpackMan.unpack<int>(2);
    success &= (value != null);
    if (success) _sender = value!;

    var unpackedHops = unpackMan.unpackAll<int>(getHopsSize(), HOP_BYTE_SIZE);
    success &= (unpackedHops != null);
    if (success) _hops = unpackedHops!;

    value = unpackMan.unpack<int>(2);
    success &= (value != null);
    if (success) _crc16 = value!;

    return success;
  }

  @override
  Uint8List toBytesArray(){
    bool success = true;
    PackMan packMan = PackMan();
    success&= packHeader(packMan);
    if (!success) return Uint8List(0);
    var rawData = packMan.getRawData();
    fillSizeAndCrc(rawData!);
    return rawData;
  }

  @protected
  bool packHeader(PackMan packMan){
    bool success = true;

    success &= packMan.pack(_head_code,2);
    success &= packMan.pack(_id,2);
    success &= packMan.pack(_size,1); // placeholder
    success &= packMan.pack(_type,1);
    success &= packMan.pack(_receiver,2);
    success &= packMan.pack(_sender,2);
    success &= packMan.packAll(_hops, HOP_BYTE_SIZE);
    success &= packMan.pack(_crc16,2); // placeholder

    return success;
  }

  @protected
  void fillSizeAndCrc(Uint8List rawData){
    if (rawData.length < minExpectedSize){
      return;
    }

    rawData[4] = rawData.length;
    Uint8List list = Uint8List(2);
    list.buffer.asByteData().setUint16(0, calcCRC(rawData), PROTOCOL_BYTE_ORDER);
    rawData.setAll(18, list);
  }

  static bool checkCrc(Uint8List rawData){
    if (rawData.length < minExpectedSize) return false;

    var buffer = rawData.buffer.asByteData();

    int receivedCrc = buffer.getUint16(18, PROTOCOL_BYTE_ORDER);

    buffer.setUint16(18, 0, PROTOCOL_BYTE_ORDER);

    int crc = calcCRC(rawData);

    buffer.setUint16(18, receivedCrc, PROTOCOL_BYTE_ORDER);

    return crc == receivedCrc;
  }

  static BasePackage makeAcknowledge(BasePackage basePackage){
    BasePackage acknowledge = BasePackage();
    acknowledge._id = basePackage.getInvId();
    acknowledge._size = BasePackage.minExpectedSize;
    acknowledge._type = basePackage._type;
    acknowledge._receiver = basePackage._sender;
    acknowledge._sender = basePackage._receiver;

    return acknowledge;
  }

  static BasePackage makeBaseRequest(int receiver, PackageType type){
    BasePackage req = BasePackage();
    req._size = BasePackage.minExpectedSize;
    req.setType(type);
    req.setReceiver(receiver);
    req.setSender(RoutesManager.getLaptopAddress());

    return req;
  }
}