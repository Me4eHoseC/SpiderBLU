import 'package:collection/collection.dart';

void alignCenter(List<int> wave) {
  double avg = wave.average;

  var int16Min = -32768;
  var int16Max = 32767;

  int offset = avg.round();
  for (int i = 0; i < wave.length; ++i) {
    var tmp = wave[i] - offset;
    wave[i] = tmp.clamp(int16Min, int16Max);
  }
}
