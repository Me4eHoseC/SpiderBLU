import 'global.dart' as global;
import 'dart:typed_data';

class ADPCMProcessor {
  void setMaxAmplitude(int maxAmplitude) {
    _originMaxAmplitude = maxAmplitude;
  }

  void addData(Uint8List rawData) {
    if (rawData.isEmpty) return;
    _zipped.addAll(rawData);
  }

  List<int> unzip() {
    /*
     * ADPCM zips 16 bits in 4 times to 4 bits.
     * VDVI tries to compress it even further.
     * In best it will convert 16 bits into 2 bits.
     * In that case each point is described by 2 bits so
     * the total amount of points: zipped.size() * (8bits / 2bits) */

    _s = AdpcmContext();

    var unzipped = <int>[];
    var unzippedSize = _adpcmDecode(unzipped, _zipped);

    int max = _maxModuleAmplitude(unzipped);
    double coef = _originMaxAmplitude / max;

    for (int i = 0; i < unzippedSize; ++i) {
      unzipped[i] = (unzipped[i] * coef).floor();
    }

    return unzipped;
  }

  void clear() {
    _originMaxAmplitude = -1;
    _zipped.clear();
  }

  int _originMaxAmplitude = -1;
  final List<int> _zipped = [];

  late AdpcmContext _s;

  int _adpcmDecode(List<int> amp, final List<int> imaData) {
    int samples = 0;

    int code = 0;
    _s.bits = 0;

    for (int i = 0;;) {
      if (_s.bits <= 8) {
        if (i >= imaData.length) break;

        code |= (imaData[i++] << (8 - _s.bits));
        _s.bits += 8;
      }

      int j;
      for (j = 0; j < 8; j++) {
        if ((vdviDecode[j].mask & code) == vdviDecode[j].code) break;
        if ((vdviDecode[j + 8].mask & code) == vdviDecode[j + 8].code) {
          j += 8;
          break;
        }
      }

      amp[samples++] = _decode(j);
      code <<= vdviDecode[j].bits;
      _s.bits -= vdviDecode[j].bits;
    }

    /* Use up the remanents of the last octet */
    while (_s.bits > 0) {
      int j;
      for (j = 0; j < 8; j++) {
        if ((vdviDecode[j].mask & code) == vdviDecode[j].code) break;
        if ((vdviDecode[j + 8].mask & code) == vdviDecode[j + 8].code) {
          j += 8;
          break;
        }
      }

      if (vdviDecode[j].bits > _s.bits) break;

      amp[samples++] = _decode(j);
      code <<= vdviDecode[j].bits;
      _s.bits -= vdviDecode[j].bits;
    }

    return samples;
  }

  int _decode(int adpcm) {
    int e;
    int ss;
    int linear;

    ss = stepSize[_s.stepIndex];
    e = ss >> 3;

    if (adpcm & 0x01 != 0) e += (ss >> 2);
    if (adpcm & 0x02 != 0) e += (ss >> 1);
    if (adpcm & 0x04 != 0) e += ss;
    if (adpcm & 0x08 != 0) e = -e;

    linear = _saturate(_s.last + e);
    _s.last = linear;
    _s.stepIndex += stepAdjustment[adpcm & 0x07];

    if (_s.stepIndex < 0) {
      _s.stepIndex = 0;
    } else if (_s.stepIndex > 88) {
      _s.stepIndex = 88;
    }

    return linear;
  }

  int _saturate(int amp) {

    return amp.clamp(-32768, 32767);
  }

  int _maxModuleAmplitude(List<int> data) {
    int max = data[0].abs();

    for (int i = 1; i < data.length; ++i) {
      var value = data[i].abs();
      if (value > max) max = value;
    }

    return max;
  }
}

class AdpcmContext {
  int last = 0;
  int stepIndex = 0;
  int imaByte = 0;
  int bits = 0;
}

final List<int> stepSize = [
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  16,
  17,
  19,
  21,
  23,
  25,
  28,
  31,
  34,
  37,
  41,
  45,
  50,
  55,
  60,
  66,
  73,
  80,
  88,
  97,
  107,
  118,
  130,
  143,
  157,
  173,
  190,
  209,
  230,
  253,
  279,
  307,
  337,
  371,
  408,
  449,
  494,
  544,
  598,
  658,
  724,
  796,
  876,
  963,
  1060,
  1166,
  1282,
  1411,
  1552,
  1707,
  1878,
  2066,
  2272,
  2499,
  2749,
  3024,
  3327,
  3660,
  4026,
  4428,
  4871,
  5358,
  5894,
  6484,
  7132,
  7845,
  8630,
  9493,
  10442,
  11487,
  12635,
  13899,
  15289,
  16818,
  18500,
  20350,
  22385,
  24623,
  27086,
  29794,
  32767
];

final List<int> stepAdjustment = [-1, -1, -1, -1, 2, 4, 6, 8];

class VDVI {
  VDVI(this.code, this.mask, this.bits);

  int code = 0;
  int mask = 0;
  int bits = 0;
}

final List<VDVI> vdviDecode = [
  VDVI(0x0000, 0xC000, 2),
  VDVI(0x4000, 0xE000, 3),
  VDVI(0xC000, 0xF000, 4),
  VDVI(0xE000, 0xF800, 5),
  VDVI(0xF000, 0xFC00, 6),
  VDVI(0xF800, 0xFE00, 7),
  VDVI(0xFC00, 0xFF00, 8),
  VDVI(0xFE00, 0xFF00, 8),
  VDVI(0x8000, 0xC000, 2),
  VDVI(0x6000, 0xE000, 3),
  VDVI(0xD000, 0xF000, 4),
  VDVI(0xE800, 0xF800, 5),
  VDVI(0xF400, 0xFC00, 6),
  VDVI(0xFA00, 0xFE00, 7),
  VDVI(0xFD00, 0xFF00, 8),
  VDVI(0xFF00, 0xFF00, 8)
];
