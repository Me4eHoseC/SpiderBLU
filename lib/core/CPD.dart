import '../NetPackagesDataTypes.dart';
import 'Marker.dart';
import 'RT.dart';

class CPD extends RT {
  int _cameraSensitivity = 140;
  PhotoImageCompression _cameraCompression = PhotoImageCompression.HIGH;
  int _targetSensor = 0;

  List<DateTime> phototrapFiles = [];
  bool isPhotoBlackAndWhite = false;

  @override
  void copyFrom(Marker other) {
    super.copyFrom(other);
    if (other is! CPD) {
      return;
    }
    _cameraSensitivity = other._cameraSensitivity;
    _cameraCompression = other._cameraCompression;
    _targetSensor = other._targetSensor;
    phototrapFiles = other.phototrapFiles;
    isPhotoBlackAndWhite = other.isPhotoBlackAndWhite;
  }

  @override
  Marker clone() {
    var marker = CPD();
    marker.copyFrom(this);
    return marker;
  }

  static String Name([bool isTr = false]) {
    return isTr ? "CPD" : "CPD";
  }

  @override
  String typeName([bool isTr = false]) {
    return CPD.Name(isTr);
  }

  int get cameraSensitivity => _cameraSensitivity;
  PhotoImageCompression get cameraCompression => _cameraCompression;
  set cameraSensitivity(int sensitivity) => _cameraSensitivity = sensitivity;
  set cameraCompression(PhotoImageCompression compression) => _cameraCompression = compression;

  void setCameraParameters(int sensitivity, PhotoImageCompression compression) {
    _cameraSensitivity = sensitivity;
    _cameraCompression = compression;
  }

  int get targetSensor => _targetSensor;
  set targetSensor(int targetSensor) => _targetSensor = targetSensor;
}
