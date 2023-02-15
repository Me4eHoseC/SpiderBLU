import 'dart:convert';
import 'dart:typed_data';

const Endian PROTOCOL_BYTE_ORDER = Endian.little;

int calcCRC(Uint8List data) {
  int crc = 0xFFFF;

  for (int j = 0; j < data.length; j++) {
    int b = data[j];
    crc ^= (b << 8);
    crc &= 0xFFFF;
    for (int i = 0; i < 8; i++) {
      crc = ((crc & 0x8000) != 0) ? ((crc << 1) ^ 0x8005) : (crc << 1);
      crc &= 0xFFFF;
    }
  }
  return crc;
}

class PackMan {
  Uint8List? _data;
  int _offset = 0;

  PackMan([int initialSize = 200]) {
    _data = Uint8List(initialSize);
  }

  bool pack(var object, [int byteSize = 0]) {
    if (byteSize + _offset > _data!.length) {
      return false;
    }

    var d = _data!.buffer.asByteData();

    if (object is int) {
      int value = object;

      if (byteSize == 1) {
        d.setUint8(_offset, value);
      } else if (byteSize == 2) {
        d.setUint16(_offset, value, PROTOCOL_BYTE_ORDER);
      } else if (byteSize == 4) {
        d.setUint32(_offset, value, PROTOCOL_BYTE_ORDER);
      } else {
        return false;
      }
    } else if (object is double) {
      double value = object;

      if (byteSize == 4) {
        d.setFloat32(_offset, value, PROTOCOL_BYTE_ORDER);
      } else if (byteSize == 8) {
        d.setFloat64(_offset, value, PROTOCOL_BYTE_ORDER);
      } else {
        return false;
      }
    } else if (object is DateTime) {
      byteSize = 4;
      if (byteSize + _offset > _data!.length) {
        return false;
      }
      DateTime value = object;

      int secondsSinceEpoch =
          value.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;

      d.setUint32(_offset, secondsSinceEpoch, PROTOCOL_BYTE_ORDER);
    } else if (object is String) {
      String value = object;
      var bytes = utf8.encode(value);
      byteSize = bytes.length;

      if (byteSize + _offset > _data!.length) {
        return false;
      }

      _data!.setAll(_offset, bytes);
    }

    _offset += byteSize;
    return true;
  }

  bool packAll<T>(List<T> data, [int elementByteSize = 0]) {
    bool success = true;
    for (var el in data) {
      success &= pack(el, elementByteSize);
    }
    return success;
  }

  /// Returns null if no data added
  Uint8List? getRawData() {
    return _data!.sublist(0, _offset);
  }
}

class UnpackMan {
  late final Uint8List? _data;
  int _offset = 0;

  UnpackMan(Uint8List initData) {
    _data = initData;
  }

  T? unpack<T>([int byteSize = 0]) {
    if (_data!.length < _offset + byteSize) {
      return null;
    }

    var d = _data!.buffer.asByteData();

    int pos = _offset;
    _offset += byteSize;
    if (T == int) {
      if (byteSize == 1) {
        return d.getUint8(pos) as T;
      } else if (byteSize == 2) {
        return d.getUint16(pos, PROTOCOL_BYTE_ORDER) as T;
      } else if (byteSize == 4) {
        return d.getUint32(pos, PROTOCOL_BYTE_ORDER) as T;
      }
    } else if (T == double) {
      if (byteSize == 4) {
        return d.getFloat32(pos, PROTOCOL_BYTE_ORDER) as T;
      } else if (byteSize == 8) {
        return d.getFloat64(pos, PROTOCOL_BYTE_ORDER) as T;
      }
    } else if (T == DateTime) {
      int seconds = d.getUint32(pos, PROTOCOL_BYTE_ORDER);
      return DateTime.fromMillisecondsSinceEpoch(
          seconds * Duration.millisecondsPerSecond,
          isUtc: true) as T;
    } else if (T == String) {
      return utf8.decode(_data!.sublist(pos, _offset)) as T;
    }

    return null;
  }

  List<T>? unpackAll<T>(int amount, [int elementByteSize = 0]) {
    List<T> list = List<T>.empty(growable: true);
    for (int i = 0; i < amount; i++) {
      var tmp = unpack<T>(elementByteSize);
      if (tmp == null) {
        return null;
      } else {
        list.add(tmp);
      }
    }
    return list;
  }
}
