import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:volume_controller/volume_controller.dart';

import '../radionet/NetCommonFunctions.dart';
import '../radionet/NetSeismicPackage.dart';
import '../radionet/RoutesManager.dart';

import '../utils/adpcmProcessor.dart';
import '../utils/seismogramFunctions.dart';
import '../radionet/PackageTypes.dart';

import '../core/CSD.dart';

import '../global.dart' as global;

class SeismicHeader {
  int flags = 0x0;
  int rarify = 8;
  int samplesCount = 0;
  int discreteFreq = 2000; // Hz
  int maxAmp = 0;

// Parse values from char data. Changes pointer position and dataSize value
  bool init(Uint8List data) {
    if (data.length < 8) {
      return false;
    }
    var unpackMan = UnpackMan(data);
    flags = unpackMan.unpack<int>(1)!;
    rarify = unpackMan.unpack<int>(1)!;
    samplesCount = unpackMan.unpack<int>(2)!;
    discreteFreq = unpackMan.unpack<int>(2)!;
    maxAmp = unpackMan.unpack<int>(2)!;

    return true;
  }
}

class SeismogramWavHeader {
  SeismogramWavHeader(int dataSize, int sampleFrequency) {
    var sizeofRiff = 4 + 4;
    _RiffChunkSize = dataSize + 44 - sizeofRiff;
    _DataChunkSize = dataSize;
    _SamplesPerSecond = sampleFrequency;
    _BytesPerSecond = sampleFrequency * _BlockAlign;
  }

  int getNumberOfChannels() {
    return _NumberOfChannels;
  }

  int getSamplesPerSecond() {
    return _SamplesPerSecond;
  }

  int getBitsPerSample() {
    return _BitsPerSample;
  }

  Uint8List toBytes() {
    PackMan packMan = PackMan();

    packMan.packAll(_RIFF, 1);
    packMan.pack(_RiffChunkSize, 4);
    packMan.packAll(_WAVE, 1);

    packMan.packAll(_FMT, 1);
    packMan.pack(_FmtChunkSize, 4);
    packMan.pack(_AudioFormat, 2);

    packMan.pack(_NumberOfChannels, 2);
    packMan.pack(_SamplesPerSecond, 4);
    packMan.pack(_BytesPerSecond, 4);
    packMan.pack(_BlockAlign, 2);
    packMan.pack(_BitsPerSample, 2);

    packMan.packAll(_DATA, 1);
    packMan.pack(_DataChunkSize, 4);

    var rawData = packMan.getRawData();
    return rawData!;
  }

  List<int> _RIFF = [82, 73, 70, 70]; // RIFF Header Magic header / 1 byte per value
  int _RiffChunkSize = 0; // RIFF Chunk Size / 4 byte
  List<int> _WAVE = [87, 65, 86, 69]; // WAVE Header / 1 byte per value

  // "fmt " sub-chunk
  List<int> _FMT = [102, 109, 116, 32]; // FMT header / 1 byte per value
  int _FmtChunkSize = 16; // Size of the fmt chunk / 4 byte
  int _AudioFormat = 1; // Audio format 1=PCM, 6=mulaw, 7=alaw, 257=IBM Mu-Law, 258=IBM A-Law, 259=ADPCM / 2 byte

  int _NumberOfChannels = 1; // Number of channels 1=Mono 2=Sterio / 2 byte
  int _SamplesPerSecond = 2000; // Sampling Frequency in Hz / 4 byte
  int _BytesPerSecond = 2000 * 2; // bytes per second / 4 byte
  int _BlockAlign = 2; // 2=16-bit mono, 4=16-bit stereo / 2 byte
  int _BitsPerSample = 16; // Number of bits per sample / 2 byte

  // "data" sub-chunk
  List<int> _DATA = [100, 97, 116, 97]; // "data"  string / 1 byte per value
  int _DataChunkSize = 0; // Sampled data length / 4 byte
}

class ContextSound {
  late SeismogramWavHeader _header;
  Uint8List _soundBytes = Uint8List(0);

  void convertWaveToSound(List<int> wave, [int discreteFrequency = 2000, int frequencyShift = 100]) {
    if (wave.isEmpty) return;

    if (frequencyShift < 100) frequencyShift = 100;
    if (frequencyShift > 250) frequencyShift = 250;

    double t = 1 / discreteFrequency;

    List<double> tmp = [];
    var max = double.minPositive;
    for (int i = 0; i < wave.length; ++i) {
      var wavePoint = wave[i];
      var x = 2 * pi * frequencyShift * i * t;
      var Re = cos(x);
      var Im = sin(x);
      var e = Re + Im;
      tmp.add(wavePoint * e);

      if (max.abs() < tmp[i].abs()) max = tmp[i];
    }

    var maxTreshold = 32767 * 0.97;
    var K = maxTreshold / max.abs();

    _header = SeismogramWavHeader(wave.length * 2, discreteFrequency);

    List<int> sound = [];
    for (int i = 0; i < wave.length; ++i) {
      var value = (K * tmp[i]).floor();
      sound.add(value);
    }

    PackMan packMan = PackMan(sound.length * 2);

    packMan.packAll(sound, 2);

    _soundBytes = packMan.getRawData()!;
  }

  Uint8List toBytes() {
    var headerBytes = _header.toBytes();
    Uint8List soundFile = Uint8List(headerBytes.length + _soundBytes.length);
    soundFile.setAll(0, headerBytes);
    soundFile.setAll(headerBytes.length, _soundBytes);
    return soundFile;
  }
}

class Spectrum {
  int hc = 1024;
  List<int> seismicValues = [];
  int samplingFrequency = 2000;

  List<double> calcFullSpectrumAvgAmp([int fStart = 0, int fStop = 100]) {
    List<double> avgAmps = [];

    var fc = _calcFragmentsCount();
    if (fc == 0) return avgAmps;

    avgAmps = _calcFullSpectrumAmp(0, fStart, fStop);

    if (fc == 1) return avgAmps;

    for (int i = 0; i < avgAmps.length; ++i) {
      avgAmps[i] /= fc;
    }

    for (int fn = 1; fn < fc; ++fn) {
      List<double> amps = _calcFullSpectrumAmp(fn, fStart, fStop);

      for (int i = 0; i < avgAmps.length; ++i) {
        avgAmps[i] += amps[i] / fc;
      }
    }
    return avgAmps;
  }

  List<double> calcSpectrumFreq(int fStart, int fStop) {
    List<double> frequencies = [];

    var fr = _calcFreqResolution();
    if (fr == -1) return frequencies;

    var begin = _calcFreqIndex(fStart);
    var end = _calcFreqIndex(fStop);

    for (int fi = begin; fi < end; ++fi) {
      frequencies.add(fi * fr);
    }

    return frequencies;
  }

  int _calcFragmentsCount() {
    return (seismicValues.length / hc).ceil();
  }

  int _calcFragmentOffset(int fragmentIndex) {
    var sc = seismicValues.length;
    if (sc == 0) return 0;

    var fc = _calcFragmentsCount();
    double step = (sc - hc) / (fc - 1);

    return (fragmentIndex * step).floor();
  }

  double _calcFreqResolution() {
    var sf = samplingFrequency;
    if (sf == 0) return -1;

    double fr = sf / hc;
    return fr;
  }

  int _calcFreqIndex(int ft) {
    var fr = _calcFreqResolution();
    if (fr == -1) return 0;

    var fi = (ft / fr).ceil();
    return fi;
  }

  List<double> _calcFullSpectrumAmp(int fragmentIndex, int fStart, int fStop) {
    List<double> amps = [];
    var fr = _calcFreqResolution();
    if (fr == -1) return amps;

    var begin = _calcFreqIndex(fStart);
    var end = _calcFreqIndex(fStop);

    var K = 2 * pi / hc;
    var fso = _calcFragmentOffset(fragmentIndex);

    if (fso + hc > seismicValues.length) return amps;

    if (begin == 0) {
      amps.add(0);
      begin += 1;
    }

    // for each frequency index
    for (int fi = begin; fi < end; ++fi) {
      double sinSum = 0;
      double cosSum = 0;

      // for each Hartley transform sample
      for (int h = 0; h < hc; ++h) {
        var v = seismicValues[fso + h];
        var tmp = K * fi * h;

        sinSum += v * sin(tmp);
        cosSum += v * cos(tmp);
      }

      double amp = 0;
      amp += pow(sinSum / hc, 2);
      amp += pow(cosSum / hc, 2);

      amps.add(amp);
    }

    return amps;
  }

}

class SeismicPage extends StatefulWidget with global.TIDManagement {
  SeismicPage({super.key});
  late _SeismicPage _page;
  List<String> array = [];
  bool _isADPCM = false;
  SeismicHeader header = SeismicHeader();
  final ADPCMProcessor adpcmProcessor = ADPCMProcessor();
  List<int> rawValues = [], seismicValues = [], wave = [];
  double min = 0, max = 0;
  List<Point> spectrumSeries = [];
  final List<Point> mainSeries = [];
  AudioPlayer player = AudioPlayer();

  ContextSound contextSound = ContextSound();

  int downloadingCsdId = -1;

  void addSeismicPart(Uint8List filePart) {
    if (filePart.isEmpty) return;

    if (_isADPCM) {
      if (header.samplesCount == 0) {
        if (!header.init(filePart)) return;

        var newData = Uint8List(filePart.length - 8);
        newData.setRange(0, newData.length, filePart, 8);
        filePart = newData;

        adpcmProcessor.setMaxAmplitude(header.maxAmp);
      }

      adpcmProcessor.addData(filePart);
      var unzipped = adpcmProcessor.unzip(); // unzip returns whole seismogram

      if (unzipped.length > header.samplesCount) {
        unzipped.removeRange(header.samplesCount, unzipped.length);
      }

      rawValues = unzipped;
    } else {
      var valuesCount = filePart.length / 2;

      UnpackMan unpackMan = UnpackMan(filePart);

      for (int i = 0; i < valuesCount; ++i) {
        var value = unpackMan.unpack<int>(2, true);
        rawValues.add(value!);
      }
    }

    seismicValues = rawValues;
    _page.drawSeismicChart();

    SplineWave splineWave = SplineWave();
    splineWave.init(seismicValues);
    spline(splineWave);

    wave = splineWave.splineWave.getRange(0, splineWave.splineSize).toList();

    Spectrum spectrum = Spectrum();
    spectrum.seismicValues = wave;
    spectrum.samplingFrequency = getSamplingFrequency();
    spectrum.hc = 1024;

    var amps = spectrum.calcFullSpectrumAvgAmp(0, 100);
    var freq = spectrum.calcSpectrumFreq(0, 100);

    _page.drawSpectrumChart(freq, amps);
  }

  void lastPartCome() {
    _page.closeStream();
    downloadingCsdId = -1;

    contextSound.convertWaveToSound(wave, getSamplingFrequency(), _page.freq.toInt());
    player.setReleaseMode(ReleaseMode.loop);
    player.play(BytesSource(contextSound.toBytes()), volume: 1).then((value) {
      if (_page.flagPlay) {
        player.pause();
      }
    });
    _page.initDurationAndPosition();

    Spectrum spectrum = Spectrum();
    spectrum.seismicValues = wave;
    spectrum.samplingFrequency = getSamplingFrequency();
    spectrum.hc = 1024;

    var amps = spectrum.calcFullSpectrumAvgAmp(0, 100);
    var freq = spectrum.calcSpectrumFreq(0, 100);

    _page.drawSpectrumChart(freq, amps);
  }

  void refresh() {
    contextSound.convertWaveToSound(wave, getSamplingFrequency(), _page.freq.toInt());
    player.setReleaseMode(ReleaseMode.loop);
    player.play(BytesSource(contextSound.toBytes()), volume: 1).then((value) {
      if (_page.flagPlay) {
        player.pause();
      }
    });
    _page.initDurationAndPosition();
  }

  void setADPCMMode(bool isADPCM) {
    _isADPCM = isADPCM;
  }

  void clearSeismic(DateTime time) {
    _isADPCM = false;
    header = SeismicHeader();
    adpcmProcessor.clear();

    rawValues.clear();
    seismicValues.clear();

    _page.seismicChart = Container();
  }

  int getSamplingFrequency() {
    int samplingFrequency = 2000;
    if (header.samplesCount != 0) {
      samplingFrequency = header.discreteFreq;
    }
    return samplingFrequency;
  }

  double calculateSampleTimeMs(int sample) {
    return sample * 1000.0 / getSamplingFrequency();
  }

  int calculateSampleIndex(double ms) {
    return (ms / 1000.0 * getSamplingFrequency()).round();
  }

  bool getLastSeismic() {
    if (global.seismicPage.downloadingCsdId != -1) return false;

    var csd = global.itemsMan.getSelected<CSD>();
    if (csd == null) return false;

    global.seismicPage.downloadingCsdId = csd.id;

    var cc = SeismicRequestPackage();
    cc.setType(PackageType.GET_LAST_SEISMIC_WAVE);
    cc.setReceiver(csd.id);
    cc.setSender(RoutesManager.getLaptopAddress());
    cc.setZippedFlag(true);

    var tid = global.postManager.sendPackage(cc);
    tits.add(tid);
    return true;
  }

  bool getSeismic() {
    if (downloadingCsdId != -1) return false;

    var csd = global.itemsMan.getSelected<CSD>();
    if (csd == null) return false;

    global.seismicPage.downloadingCsdId = csd.id;

    var cc = SeismicRequestPackage();
    cc.setReceiver(csd.id);
    cc.setSender(RoutesManager.getLaptopAddress());
    cc.setZippedFlag(true);

    var tid = global.postManager.sendPackage(cc);
    tits.add(tid);
    return true;
  }

  void notSend() {
    downloadingCsdId != -1;
  }

  void plotSpectrum(List<double> freq, List<double> amp){
    spectrumSeries.clear();

    for (int i = 0; i < freq.length; i++){
      spectrumSeries.add(Point(freq[i], amp[i]));
    }
  }

  void plotSeismic() {
    List<int> centredSeismicValues = List<int>.from(seismicValues);
    alignCenter(centredSeismicValues);

    mainSeries.clear();

    for (int i = 0; i < centredSeismicValues.length; ++i) {
      double y = centredSeismicValues[i].toDouble();

      if (min > y) min = y.toDouble();
      if (max < y) max = y.toDouble();

      double x = calculateSampleTimeMs(i + 1) * 8 / 1000;
      mainSeries.add(Point(x, y));
    }
  }

  @override
  State createState() {
    _page = _SeismicPage();
    return _page;
  }
}

class _SeismicPage extends State<SeismicPage> with TickerProviderStateMixin {
  bool get wantKeepAlive => true;
  bool flagLoop = false, flagPlay = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget seismicChart = Container();
  Widget spectrumChart = Container();

  double freq = 100;

  PlayerState? _playerState;
  Duration? _duration, _position;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateChangeSubscription;
  AudioPlayer get player => widget.player;

  double volume = 0;

  Future<void> takeVolume() async {
    volume = await VolumeController().getVolume();
  }

  void initDurationAndPosition() {
    _playerState = player.state;
    player.getDuration().then(
          (value) => setState(() {
            _duration = value;
          }),
        );
    player.getCurrentPosition().then(
          (value) => setState(() {
            _position = value;
          }),
        );
    _initStreams();
  }

  void closeStream() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerStateChangeSubscription = player.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
    _pause();
  }

  Future<void> _play() async {
    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  void drawSpectrumChart(List<double> freq, List<double> amps) {
    widget.plotSpectrum(freq, amps);
    setState(() {
      spectrumChart = SfCartesianChart(
        borderWidth: 6,
        enableAxisAnimation: false,
        zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true,
            enableDoubleTapZooming: true,
            enableSelectionZooming: true,
            selectionRectBorderColor: Colors.red,
            selectionRectBorderWidth: 2,
            selectionRectColor: Colors.grey,
            enablePanning: true,
            zoomMode: ZoomMode.xy,
            maximumZoomLevel: 0.1),
        margin: EdgeInsets.zero,
        primaryXAxis: NumericAxis(
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          anchorRangeToVisiblePoints: false,
          maximumLabels: 5,
          minimum: 0,
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(),
          edgeLabelPlacement: EdgeLabelPlacement.hide,
          anchorRangeToVisiblePoints: false,
          labelPosition: ChartDataLabelPosition.inside,
          tickPosition: TickPosition.inside,
          plotOffset: 0,
          labelStyle: TextStyle(backgroundColor: Colors.white),
          maximumLabels: 4,
        ),
        series: <ColumnSeries<Point, double>>[
          ColumnSeries<Point, double>(
            color: Colors.green,
            enableTooltip: false,
            animationDuration: 0,
            dataSource: widget.spectrumSeries,
            xValueMapper: (Point p, _) => p.x.toDouble(),
            yValueMapper: (Point p, _) => p.y.toDouble(),
          ),
        ],
      );
    });
  }

  void drawSeismicChart() {
    setState(() {
      seismicChart = SfCartesianChart(
        borderWidth: 6,
        enableAxisAnimation: false,
        zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true,
            enableDoubleTapZooming: true,
            enableSelectionZooming: true,
            selectionRectBorderColor: Colors.red,
            selectionRectBorderWidth: 2,
            selectionRectColor: Colors.grey,
            enablePanning: true,
            zoomMode: ZoomMode.xy,
            maximumZoomLevel: 0.3),
        margin: EdgeInsets.zero,
        primaryXAxis: NumericAxis(
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          anchorRangeToVisiblePoints: false,
          maximumLabels: 5,
          minimum: 0,
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(),
          edgeLabelPlacement: EdgeLabelPlacement.hide,
          anchorRangeToVisiblePoints: false,
          labelPosition: ChartDataLabelPosition.inside,
          tickPosition: TickPosition.inside,
          plotOffset: 0,
          labelStyle: TextStyle(backgroundColor: Colors.white),
          maximumLabels: 4,
        ),
        series: <LineSeries<Point, double>>[
          LineSeries<Point, double>(
            color: Colors.blueAccent,
            enableTooltip: false,
            animationDuration: 0,
            dataSource: widget.mainSeries,
            xValueMapper: (Point p, _) => p.x.toDouble(),
            yValueMapper: (Point p, _) => p.y,
          ),
        ],
      );
    });
  }

  void cancelSeismicDownload() {
    widget.downloadingCsdId = -1;
    global.stopMedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Column(
          children: [
            Flexible(
              flex: 7,
              child: spectrumChart,
            ),
            Flexible(
              flex: 7,
              child: seismicChart,
            ),
            Flexible(
              flex: 1,
              child: Slider(
                onChanged: (value) {
                  final duration = _duration;
                  if (duration == null) {
                    return;
                  }
                  final position = value * duration.inMilliseconds;
                  player.seek(Duration(milliseconds: position.round()));
                },
                value: (_position != null &&
                        _duration != null &&
                        _position!.inMilliseconds > 0 &&
                        _position!.inMilliseconds < _duration!.inMilliseconds)
                    ? _position!.inMilliseconds / _duration!.inMilliseconds
                    : 0.0,
              ),
            ),
            Flexible(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(),
                      onPressed: () {
                        setState(() {
                          flagPlay = !flagPlay;
                          if (flagPlay) {
                            _pause();
                          } else {
                            _play();
                          }
                        });
                      },
                      child: flagPlay
                          ? const Icon(
                              Icons.play_arrow,
                            )
                          : const Icon(
                              Icons.pause,
                            ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                  const Flexible(
                    flex: 1,
                    child: Icon(Icons.music_note),
                  ),
                  Flexible(
                    flex: 10,
                    child: Slider(
                      min: 100,
                      max: 250,
                      onChanged: player.state == PlayerState.paused
                          ? (value) {
                              setState(() {
                                freq = value;
                                print(freq);
                              });
                            }
                          : null,
                      onChangeEnd: (val) => widget.refresh(),
                      value: freq,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          OutlinedButton(
            onPressed: widget.downloadingCsdId != -1 ? null : () => widget.getSeismic(),
            child: const Icon(Icons.show_chart),
          ),
          OutlinedButton(
            onPressed: widget.downloadingCsdId != -1 ? null : () => widget.getLastSeismic(),
            child: const Icon(
              Icons.show_chart,
              color: Colors.red,
            ),
          ),
          OutlinedButton(
            onPressed: widget.downloadingCsdId == -1 ? null : cancelSeismicDownload,
            child: const Icon(Icons.cancel_outlined),
          ),
        ],
      ),
    );
  }
}
