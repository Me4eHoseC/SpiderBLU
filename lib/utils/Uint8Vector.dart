import 'dart:typed_data';

class Uint8Vector {
  int _endIt = 0;
  Uint8List _data = Uint8List(0);
  
  Uint8Vector(int initLength) {
    _data = Uint8List(initLength);
  }

  int size() {
    return _data.length;
  }

  bool get isEmpty => _data.isEmpty;

  Uint8List data() {
    return _data;
  }
  
  void clear() {
    _data = Uint8List(0);
    _endIt = 0;
  }
  
  void add(Uint8List part) {
    if (part.isEmpty) return;

    if (_data.length - _endIt < part.length) {
      var newBuffer = Uint8List(_endIt + part.length);
      newBuffer.setAll(0, _data);
      _data = newBuffer;
    }

    _data.setAll(_endIt, part);
    _endIt += part.length;
  }
}