void alignCenter(List<int> wave) {
  double avg = 0.0;
  for (int i = 0; i < wave.length; ++i) {
    avg += wave[i] / wave.length;
  }

  var int16Min = -32768;
  var int16Max = 32767;

  int offset = avg.round();
  for (int i = 0; i < wave.length; ++i) {
    var tmp = wave[i] - offset;
    wave[i] = tmp.clamp(int16Min, int16Max);
  }
}

class SplineWave {
  final List<int> originWave = [];

  /// Size of splined wave
  int splineSize = 0;

  /// Splined wave with extra endpoints
  List<int> splineWave = [];

  int splineFactor = 8;

  /// Makes a copy of wave with extra zero endpoints
  /// Reserves memory for splined wave
  /// Return false if invalid argument provided
  bool init(List<int> wave) {
    if (wave.isEmpty) return false;

    print('wave size: ${wave.length}');

    originWave.clear();
    originWave.addAll(wave);
    originWave.addAll(List<int>.generate(splineFactor, (index) => 0));

    print('origin wave size: ${originWave.length}');

    splineWave.clear();

    splineSize = wave.length * splineFactor;

    var splineWavePoints = originWave.length * splineFactor;
    splineWave = List<int>.generate(splineWavePoints, (index) => 0, growable: false);

    return true;
  }
}

void spline(SplineWave src) {
  if (src.originWave.isEmpty) return;

  var c = List<double>.generate(src.originWave.length, (index) => 0, growable: false);

  bicubCoeff(src.originWave.length, src.originWave, c, src.splineFactor);
  for (int i = 0; i < src.originWave.length - 2; i++) {
    for (int j = 0; j < src.splineFactor; j++) {
      var p = bicubSpl(i, src.originWave, c, i * src.splineFactor + j, src.splineFactor);
      p.clamp(-32767, 32768);

      src.splineWave[i * src.splineFactor + j] = p.toInt();
    }
  }
}

void bicubCoeff(int size, final List<int> data, List<double> c, int splineFactor) {
  var k = List<double>.generate(size, (index) => 0, growable: false);

// Straight stroke

  c[1] = 0;
  for (int i = 2; i < size; i++) {
    int j = i - 1;
    int m = j - 1;
    double a = splineFactor.toDouble();
    double b = splineFactor.toDouble();
    double r = 2 * (a + b) - b * c[j];
    c[i] = a / r;
    k[i] = (3.0 * ((data[i] - data[j]) / a - (data[j] - data[m]) / b) - b * k[j]) / r;
  }

// Reverse stroke
  c[size - 1] = k[size - 1];
  for (int i = size - 2; i >= 0; i--) {
    c[i] = k[i] - c[i] * c[i + 1];
  }
}

double bicubSpl(int originWavePointIndex, List<int> originWave, List<double> c, int x1, int splineFactor) {
  int i, j;
  double a, b, d, q, r, p;
  i = originWavePointIndex + 1; // Next y

    // Intermediate variables and coefficients
    j = i - 1;
    a = originWave[j].toDouble();
    b = j * splineFactor.toDouble();
    q = splineFactor.toDouble();
    r = x1 - b;
    p = c[i];
    d = c[i + 1];
    b = (originWave[i] - a) / q - (d + 2 * (p)) * q / 3.0;
    d = (d - p) / q * r;
  // Calculate spline value
  p = a + r * (b + r * (p + d / 3.0));
  return p;

}
