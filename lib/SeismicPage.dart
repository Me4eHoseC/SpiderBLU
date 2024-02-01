import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projects/BasePackage.dart';
import 'package:projects/NetCommonFunctions.dart';
import 'package:projects/NetCommonPackages.dart';
import 'package:projects/NetSeismicPackage.dart';
import 'package:projects/adpcmProcessor.dart';
import 'package:projects/core/Marker.dart';
import 'package:projects/seismogramFunctions.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'AllEnum.dart';
import 'RoutesManager.dart';
import 'core/CSD.dart';
import 'global.dart' as global;

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

class SeismicPage extends StatefulWidget with global.TIDManagement {
  SeismicPage({super.key});
  late _SeismicPage _page;
  List<String> array = [];
  bool _isADPCM = false;
  SeismicHeader header = SeismicHeader();
  final ADPCMProcessor adpcmProcessor = ADPCMProcessor();
  List<int> rawValues = [], seismicValues = [];
  double min = 0, max = 0;
  final List<Point> mainSeries = [];

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
    _page.drawChart();
  }

  void lastPartCome() {
    //global.listMapMarkers[global.itemsManager.getSelectedDevice()?.id]?.markerData.downloadPhoto = false;
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

  bool getLastSeismic() {
    if (downloadingCsdId != -1) return false;

    var csd = global.itemsMan.getSelected<CSD>();
    if (csd == null) return false;

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

    var cc = SeismicRequestPackage();
    cc.setReceiver(csd.id);
    cc.setSender(RoutesManager.getLaptopAddress());
    cc.setZippedFlag(true);

    var tid = global.postManager.sendPackage(cc);
    tits.add(tid);
    return true;
  }

  void plot() {
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
    }
  }

  @override
  void ranOutOfSendAttempts(int tid, BasePackage? pb) {
    tits.remove(tid);
    if (global.itemsMan.getAllIds().contains(pb!.getReceiver()) && global.listMapMarkers[pb.getReceiver()]!.markerData.notifier.active) {
      global.pageWithMap.deactivateMapMarker(global.listMapMarkers[pb.getReceiver()]!.markerData.id!);
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
  bool flag = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget firstSeismic = Container(), secondSeismic = Container();

  void drawChart() {
    setState(() {
      firstSeismic = SfCartesianChart(
        enableAxisAnimation: false,
        zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true,
            enableDoubleTapZooming: true,
            enableSelectionZooming: true,
            selectionRectBorderColor: Colors.red,
            selectionRectBorderWidth: 2,
            selectionRectColor: Colors.grey,
            enablePanning: true,
            zoomMode: ZoomMode.x,
            maximumZoomLevel: 0.5),
        margin: EdgeInsets.zero,
        primaryXAxis: NumericAxis(
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          anchorRangeToVisiblePoints: false,
          maximumLabels: 5,
          minimum: 0,
        ),
        series: <LineSeries<Point, double>>[
          LineSeries<Point, double>(
            animationDuration: 0,
            dataSource: widget.mainSeries,
            xValueMapper: (Point p, _) => p.x.toDouble(),
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
        title: const Text('Seismic'),
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20.0),
        trackpadScrollCausesScale: true,
        maxScale: 5,
        child: Center(
          child: SizedBox(
            height: 250,
            width: 350,
            child: firstSeismic,
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              widget.getLastSeismic();
              drawChart();
            },
            icon: const Icon(
              Icons.show_chart,
              color: Colors.red,
            ),
          ),
          IconButton(
            onPressed: () {
              widget.getSeismic();
              drawChart();
            },
            icon: const Icon(Icons.show_chart),
          ),
        ],
      ),
    );
  }
}
