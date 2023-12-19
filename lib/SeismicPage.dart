import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projects/Application.dart';
import 'package:projects/BasePackage.dart';
import 'package:projects/NetCommonFunctions.dart';
import 'package:projects/NetCommonPackages.dart';
import 'package:projects/NetSeismicPackage.dart';
import 'package:projects/adpcmprocessor.dart';
import 'package:projects/core/Uint8Vector.dart';
import 'package:projects/seismogramfunctions.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'AllEnum.dart';
import 'RoutesManager.dart';
import 'global.dart' as global;

class SeismicHeader {
int flags = 0x0;
int rarify = 8;
int samplesCount = 0;
int discreteFreq = 2000; // Hz
int maxAmp = 0;

// Parse values from char data. Changes pointer position and dataSize value
bool init(Uint8List data){
  if (data.length < 8){
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

class SeismicPage extends StatefulWidget with TIDManagement {
  SeismicPage({super.key});
  late _SeismicPage _page;
  List<String> array = [];
  bool _isADPCM = false;
  SeismicHeader header = SeismicHeader();
  final ADPCMProcessor adpcmProcessor = ADPCMProcessor();
  List<int> rawValues = [], seismicValues = [];
  double min = 0, max = 0;
  final List<Point> mainSeries = [];

  var seicmicFile = Uint8Vector(0);

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

      //wave.splineFactor = header.rarify;
      //init = wave.init(pair.first, pair.second);
    } else {
      var valuesCount = filePart.length / 2;

      UnpackMan unpackMan = UnpackMan(filePart);

      for (int i = 0; i < valuesCount; ++i){
        var value = unpackMan.unpack<int>(2,true);
        print('values  ${value}');
        rawValues.add(value!);
      }
    //init = wave.init(rawValues.data(), rawValues.size());
    }
    //if (!init) return;
    //spline(wave);

    //seismicValues.clear();
    //seismicValues.insert(seismicValues.end(), wave.splineWave, wave.splineWave + wave.splineSize);

    seismicValues = rawValues;

    seicmicFile.add(filePart);
    print('Seismic part received ${filePart.length}');
    _page.drawChart();

  }

  void setSeismicFileSize(int fileSize) {
    seicmicFile = Uint8Vector(fileSize);
  }

  void lastPartCome() {
    //global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]?.markerData.downloadPhoto = false;
  }

  void clearSeismic(DateTime time) {
    _isADPCM = false;
    header = SeismicHeader();
    adpcmProcessor.clear();

    rawValues.clear();
    seismicValues.clear();

    _page.firstSeismic = Container();
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

  void plot(){
    List<int> centredSeismicValues = List<int>.from(seismicValues);
    alignCenter(centredSeismicValues);

    mainSeries.clear();

    for (int i = 0; i < centredSeismicValues.length; ++i) {
      double y = centredSeismicValues[i].toDouble();

      if (min > y) min = y.toDouble();
      if (max < y) max = y.toDouble();

      double x = calculateSampleTimeMs(i + 1) / 1000;

      mainSeries.add(Point(x, y));
    }
  }

  @override
  void acknowledgeReceived(int tid, BasePackage basePackage) {
    tits.remove(tid);
    array.add('acknowledgeReceived');
    global.dataComeFlag = true;
  }

  @override
  void dataReceived(int tid, BasePackage basePackage) {
    tits.remove(tid);
    if (basePackage.getType() == PackageType.SEISMIC_WAVE) {
      var package = basePackage as FilePartPackage;
      var bufDev = package.getSender();
    }
  }

  @override
  void ranOutOfSendAttempts(int tid, BasePackage? pb) {
    tits.remove(tid);
    if (global.itemsManager.getItemsIds().contains(pb!.getReceiver()) &&
        global.listMapMarkers[pb.getReceiver()]!.markerData.notifier.active) {
      global.pageWithMap.DeactivateMapMarker(global.listMapMarkers[pb.getReceiver()]!.markerData.id!);
      array.add('RanOutOfSendAttempts');
      global.dataComeFlag = true;
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget firstSeismic = Container(), secondSeismic = Container();

  void getLastSeismic(int id) {
    global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]?.markerData.downloadPhoto = true;

    var cc = SeismicRequestPackage();
    cc.setType(PackageType.GET_LAST_SEISMIC_WAVE);
    cc.setReceiver(id);
    cc.setSender(RoutesManager.getLaptopAddress());
    cc.setZippedFlag(false);

    var tid = global.postManager.sendPackage(cc);
  }

  void getSeismic(int id) {
    global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]?.markerData.downloadPhoto = true;

    var cc = SeismicRequestPackage();
    cc.setReceiver(id);
    cc.setSender(RoutesManager.getLaptopAddress());
    cc.setZippedFlag(false);

    var tid = global.postManager.sendPackage(cc);
  }

  void drawChart(){
    setState(() {
      firstSeismic = SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <LineSeries<Point, String>>[
          LineSeries<Point, String>(
            dataSource: widget.mainSeries,

            xValueMapper: (Point p, _) => (p.x * 8).toStringAsFixed(4),
            yValueMapper: (Point p, _) => p.y,
          ),
        ],
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Seismic'),
      ),
      body: InteractiveViewer(
        trackpadScrollCausesScale: true,
        maxScale: 5,
        child: Center(
          child: SizedBox(
            height: 300,
            width: 300,
            child: firstSeismic,
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => {
              getLastSeismic(global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]!.markerData.id!),
            },
            icon: const Icon(
              Icons.show_chart,
              color: Colors.red,
            ),
          ),
          IconButton(
            onPressed: () => {
              getSeismic(global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]!.markerData.id!),
              drawChart(),
            },
            icon: const Icon(Icons.show_chart),
          ),
        ],
      ),
    );
  }
}
