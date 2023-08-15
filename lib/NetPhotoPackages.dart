import 'dart:typed_data';

import 'BasePackage.dart';
import 'AllEnum.dart';
import 'NetCommonFunctions.dart';
import 'NetPackagesDataTypes.dart';

/// Can be used as camera parameters package or as new photo request package
class PhotoParametersPackage extends BasePackage {
  int _compressRatio = 0, _imageSize = 0, _photocellLevel = 0;

  PhotoParametersPackage() {
    setType(PackageType.SET_PHOTO_PARAMETERS);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is PhotoParametersPackage) {
      _compressRatio = other._compressRatio;
      _imageSize = other._imageSize;
      _photocellLevel = other._photocellLevel;
    }
  }

  void setParameters(
      int invLightSensitivity, PhotoImageCompression compressionRatio,
      [PhotoImageSize imageSize = PhotoImageSize.IMAGE_160X120]) {
    _photocellLevel = invLightSensitivity;
    _compressRatio = castFromCompression(compressionRatio, imageSize);
    _imageSize = imageSize.index;
  }

  PhotoImageCompression getCompressRatio() {
    return PhotoImageCompression.values[_compressRatio];
  }

  PhotoImageSize getImageSize() {
    return PhotoImageSize.values[_imageSize];
  }

  int getInvLightSensitivity() {
    return _photocellLevel;
  }

  void setBlackAndWhite(bool isBlackAndWhite) {
    if (isBlackAndWhite) _imageSize |= 0x00010000;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var valueCompressRatio = unpackMan.unpack<int>(1);
    success &= (valueCompressRatio != null);
    if (success) _compressRatio = valueCompressRatio!;
    var valueImageSize = unpackMan.unpack<int>(1);
    success &= (valueImageSize != null);
    if (success) _imageSize = valueImageSize!;
    var valuePhotoCellLevel = unpackMan.unpack<int>(1);
    success &= (valuePhotoCellLevel != null);
    if (success) _photocellLevel = valuePhotoCellLevel!;

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);

    success &= packMan.pack(_compressRatio, 1);
    success &= packMan.pack(_imageSize, 1);
    success &= packMan.pack(_photocellLevel, 1);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

/// To request a new photo set type to PackageType::GET_NEW_PHOTO
typedef PhotoRequestPackage = PhotoParametersPackage;

class LastPhotoRequestPackage extends BasePackage {
  DateTime? _fileTime;
  int _imageSize = 0;

  LastPhotoRequestPackage() {
    setType(PackageType.GET_LAST_PHOTO);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is LastPhotoRequestPackage) {
      _fileTime = other._fileTime;
      _imageSize = other._imageSize;
    }
  }

  void setFileTime(DateTime dateTime) {
    _fileTime = dateTime;
  }

  void setImageSize(PhotoImageSize imageSize) {
    _imageSize = imageSize.index;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);

    success &= packMan.pack(_fileTime, 4);
    success &= packMan.pack(_imageSize, 1);

    int trash = 0;
    success &= packMan.pack(trash, 1);
    success &= packMan.pack(trash, 1);
    success &= packMan.pack(trash, 1);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class PhototrapPackage extends BasePackage {
  int _master = 0;
  List<int> _crossDevicesIds = List<int>.empty(growable: true);

  PhototrapPackage() {
    setType(PackageType.SET_TRAP_ADDRESS);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is PhototrapPackage) {
      _master = other._master;
      _crossDevicesIds = List<int>.from(other._crossDevicesIds);
    }
  }

  List<int> getCrossDevicesList() {
    return _crossDevicesIds;
  }

  void addCrossDevice(int deviceId) {
    _crossDevicesIds.add(deviceId);
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    var valueMaster = unpackMan.unpack<int>(2);
    success &= (valueMaster != null);
    if (success) _master = valueMaster!;

    int bodySize = getSize() - BasePackage.minExpectedSize;
    int count =
        (bodySize - (_master.bitLength / 8).ceil()) ~/ _crossDevicesIds.length;

    if (count < 0) count = 0;

    for (int i = 0; i < count; ++i) {
      int crossDevice = 0;
      var value = unpackMan.unpack<int>(2);
      success &= (value != null);
      if (success) {
        crossDevice = value!;
      } else {
        break;
      }
      _crossDevicesIds.add(crossDevice);
    }

    return success;
  }

  @override
  Uint8List toBytesArray() {
    bool success = true;
    PackMan packMan = PackMan();

    success &= super.packHeader(packMan);

    success &= packMan.pack(_master, 2);
    success &= packMan.packAll(_crossDevicesIds, 2);

    if (!success) return Uint8List(0);

    var rawData = packMan.getRawData();

    fillSizeAndCrc(rawData!);

    return rawData;
  }
}

class PhototrapFilesPackage extends BasePackage {
  List<DateTime> _files = List<DateTime>.empty(growable: true);

  PhototrapFilesPackage() {
    setType(PackageType.TRAP_PHOTO_LIST);
  }

  @override
  copyWith(BasePackage other) {
    super.copyWith(other);

    if (other is PhototrapFilesPackage) {
      _files = List<DateTime>.from(other._files);
    }
  }

  List<DateTime> getPhototrapFiles() {
    return _files;
  }

  @override
  bool tryParse(Uint8List rawData) {
    bool success = true;
    UnpackMan unpackMan = UnpackMan(rawData);

    success &= super.unpackHeader(unpackMan);

    int bodySize = getSize() - BasePackage.minExpectedSize;
    int count = bodySize ~/ _files.length;

    if (count < 0) count = 0;

    for (int i = 0; i < count; ++i) {
      DateTime file;
      var value = unpackMan.unpack<DateTime>(4);
      success &= (value != null);
      if (success) {
        file = value!;
      } else {
        break;
      }
      _files.add(file);
    }
    return success;
  }
}
