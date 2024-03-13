import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../radionet/BasePackage.dart';
import '../radionet/NetCommonPackages.dart';
import '../radionet/NetPackagesDataTypes.dart';
import '../core/NetDevice.dart';
import '../radionet/NetPhotoPackages.dart';
import '../radionet/NetSeismicPackage.dart';
import '../radionet/PackageTypes.dart';
import '../radionet/NetNetworkPackages.dart';
import '../radionet/RoutesManager.dart';
import '../core/CPD.dart';
import '../core/CSD.dart';
import '../core/MCD.dart';
import '../core/Marker.dart';
import '../core/RT.dart';
import '../global.dart' as global;

class DeviceParametersPage extends StatefulWidget with global.TIDManagement {
  List<String> array = [];
  List<DropdownMenuItem<String>> dropdownItems = [];
  String dropdownValue = '';
  late _DeviceParametersPage _page;

  Marker _cloneItem = Marker();

  void addDeviceInDropdown(int id, String type) {
    dropdownValue = id.toString();
    var newItem = DropdownMenuItem(
      value: dropdownValue,
      child: Text('$type '
          '#$id'),
    );
    dropdownItems.add(newItem);
  }

  void stdConnected(int stdId) {
    Timer(const Duration(seconds: 4), () {
      if ((global.listMapMarkers.isEmpty || global.flagCheckSPPU == false) && global.pageWithMap.coord() != null) {
        global.pageWithMap.createFirstSTDAutomatically(
            int.parse(global.STDNum), global.pageWithMap.coord()!.latitude, global.pageWithMap.coord()!.longitude);
      }
      var req = BasePackage.makeBaseRequest(stdId, PackageType.GET_MODEM_FREQUENCY);
      var tid = global.postManager.sendPackage(req);
      tits.add(tid);

      var tp = TimePackage();
      tp.setTime(DateTime.now());
      tp.setReceiver(stdId);
      tp.setSender(RoutesManager.getLaptopAddress());

      tid = global.postManager.sendPackage(tp);
      setRequests[tid] = tp;
      tits.add(tid);

      req = BasePackage.makeBaseRequest(stdId, PackageType.GET_ALLOWED_HOPS);
      tid = global.postManager.sendPackage(req);
      tits.add(tid);
      global.stdHopsCheckRequests.add(tid);
    });

    global.pollManager.startPollRoutines();
  }

  void changeDeviceInDropdown(int newId, String newType, String oldId) {
    addDeviceInDropdown(newId, newType);
    deleteDeviceInDropdown(int.parse(oldId));
    selectDeviceInDropdown(newId);
  }

  void deleteDeviceInDropdown(int id) {
    for (int i = 0; i < dropdownItems.length; i++) {
      if (dropdownItems[i].value == id.toString()) {
        dropdownItems.removeAt(i);
        if (i == dropdownItems.length && i > 0) {
          dropdownValue = dropdownItems[i - 1].value.toString();
        } else {
          dropdownValue = dropdownItems[i].value.toString();
        }
        break;
      }
    }
  }

  void selectDeviceInDropdown(int id) {
    for (int i = 0; i < dropdownItems.length; i++) {
      if (dropdownItems[i].value == id.toString()) {
        dropdownValue = dropdownItems[i].value.toString();
        _page.setAllNums();
        break;
      }
    }
  }

  void updateDevice() {
    _page.setAllNums();
  }

  @override
  void acknowledgeReceived(int tid, BasePackage basePackage) {
    _page.checkNewIdDevice();
    _page.setAllNums();
  }

  @override
  void dataReceived(int tid, BasePackage basePackage) {
    var type = basePackage.getType();
    var sender = basePackage.getSender();
    var nd = global.itemsMan.get<NetDevice>(sender);

    if (nd == null) return;

    if (basePackage is CoordinatesPackage) {
      global.listMapMarkers[sender]?.point.latitude = nd.latitude;
      global.listMapMarkers[sender]?.point.longitude = nd.longitude;
    } else if (basePackage is HopsPackage && type == PackageType.ALLOWED_HOPS) {
      if (nd is RT) {
        var rtMode = RoutesManager.getRtMode(nd.allowedHops);

        if (global.stdHopsCheckRequests.contains(tid)) {
          global.stdHopsCheckRequests.remove(tid);

          if (rtMode == RtMode.NoOne) {
            var hp = HopsPackage();
            hp.setType(PackageType.SET_ALLOWED_HOPS);
            hp.setSender(RoutesManager.getLaptopAddress());
            hp.setReceiver(basePackage.getPartner());

            hp.addHop(RoutesManager.getRtAllHop());
            hp.fillZeroHops();

            global.postManager.sendPackage(hp);
          }
        } else if (global.retransmissionRequests.contains(tid)) {
          global.retransmissionRequests.remove(tid);
        } else {
          _page.dialogAllowedHopsBuilder();
        }
      }
    } else if (basePackage is HopsPackage && type == PackageType.UNALLOWED_HOPS && nd is RT) {
      _page.dialogUnallowedHopsBuilder();
    }

    _page.setAllNums();
    _page.checkNewIdDevice();
  }

  void alarmReceived(BasePackage basePackage) {
    if (basePackage.getType() == PackageType.ALARM) {
      var package = basePackage as AlarmPackage;
      var bufDev = package.getSender();
      if (global.itemsMan.getAllIds().contains(bufDev)) {
        global.pageWithMap.alarmMapMarker(bufDev, package.getAlarmReason());
        addProtocolLine('Alarm: ${package.getAlarmType()} ${package.getAlarmReason()} (${package.getAlarmNumber()})');
      }
    }
  }

  @override
  void ranOutOfSendAttempts(int tid, BasePackage? pb) {
    tits.remove(tid);
    if (global.itemsMan.getAllIds().contains(pb!.getReceiver()) && global.listMapMarkers[pb.getReceiver()]!.markerData.notifier.active) {
      global.pageWithMap.deactivateMapMarker(global.listMapMarkers[pb.getReceiver()]!.markerData.id!);
      _page.checkNewIdDevice();
    }
  }

  void addProtocolLine(String line) {
    array.add(line);
    _page.checkNewIdDevice();
  }

  @override
  State createState() {
    _page = _DeviceParametersPage();
    return _page;
  }
}

class _DeviceParametersPage extends State<DeviceParametersPage> with AutomaticKeepAliveClientMixin<DeviceParametersPage> {
  @override
  bool get wantKeepAlive => true;
  ScrollController _scrollController = ScrollController();
  String? bufferDeviceType;
  TextEditingController _controllerId = TextEditingController();
  TextEditingController _controllerLongitude = TextEditingController();
  TextEditingController _controllerLatitude = TextEditingController();
  TextEditingController _controllerCameraSensitivity = TextEditingController();
  TextEditingController _controllerTransportSensitivity = TextEditingController();
  TextEditingController _controllerHumanSensitivity = TextEditingController();
  TextEditingController _controllerRatioTrToNoise = TextEditingController();
  TextEditingController _controllerRatioIntToPerson = TextEditingController();
  TextEditingController _controllerRatioPersonToTransport = TextEditingController();
  TextEditingController _controllerSingleTransport = TextEditingController();
  TextEditingController _controllerSinglePerson = TextEditingController();
  Color notSend = Colors.orange;
  Color defaultColor = Colors.white;
  Color trySend = Colors.yellow;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration.zero, (_) {
      setState(() {});
    });
  }

  void checkNewIdDevice() {
    setState(() {
      global.list = ListView.builder(
          reverse: true,
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: widget.array.length,
          itemBuilder: (context, i) {
            return Text(
              widget.array[i],
              textScaleFactor: 0.85,
            );
          });
      if (widget.array.length > 3) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  //Main settings

  void checkDevID(int newId, int oldId) {
    print('$newId  $oldId');
    setState(() {
      var listIdsBuf = global.itemsMan.getAllIds();
      if (oldId == newId) return;
      if (listIdsBuf.contains(newId)) {
        showError('This ID already exists');
        widget._cloneItem.id = oldId;
        return;
      }
      if (newId < 0 && newId > 256) {
        showError("Invalid ID \n ID can be from 1 to 255");
        widget._cloneItem.id = oldId;
        return;
      }
      if (listIdsBuf.contains(oldId)) {
        global.pageWithMap.changeMapMarkerID(oldId, newId);
        setAllNums();
      }
    });
  }

  void checkDevType(int id, String oldType, String newType) {
    setState(() {
      if (oldType == newType) {
        return;
      }
      if (newType == STD.Name() && global.flagCheckSPPU == true) {
        showError('STD on map');
        return;
      }
      if (newType != STD.Name() && oldType == STD.Name() && global.flagCheckSPPU == true) {
        global.flagCheckSPPU = false;
      }
      global.pageWithMap.changeMapMarkerType(id, oldType, newType);
      setAllNums();
    });
  }

  void takeTimeClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_TIME);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.dateTime] = global.SendingState.sendingState;
    });
  }

  void setTimeClick(int devId) {
    setState(() {
      TimePackage timePackage = TimePackage();
      timePackage.setReceiver(devId);
      timePackage.setSender(RoutesManager.getLaptopAddress());
      var tid = global.postManager.sendPackage(timePackage);

      widget.setRequests[tid] = timePackage;
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.dateTime] = global.SendingState.sendingState;
    });
  }

  void takeVersionClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_VERSION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.firmwareVersion] = global.SendingState.sendingState;
    });
  }

  //Coord settings

  void takeCordClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_COORDINATE);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.coordinates] = global.SendingState.sendingState;
    });
  }

  void setCordClick(int devId, double latitude, double longitude) {
    setState(() {
      if (global.itemsMan.get<MCD>(devId) != null) return;
      CoordinatesPackage coordinatesPackage = CoordinatesPackage();
      coordinatesPackage.setReceiver(devId);
      coordinatesPackage.setSender(RoutesManager.getLaptopAddress());
      coordinatesPackage.setLatitude(latitude);
      coordinatesPackage.setLongitude(longitude);
      var tid = global.postManager.sendPackage(coordinatesPackage);

      widget.setRequests[tid] = coordinatesPackage;
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.coordinates] = global.SendingState.sendingState;
    });
  }

  //Radio settings

  void takeSignalStrengthClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_INFORMATION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.signalStrength] = global.SendingState.sendingState;
    });
  }

  void takeAllowedHopsClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_ALLOWED_HOPS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.allowedHops] = global.SendingState.sendingState;
    });
  }

  void dialogAllowedHopsBuilder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Allowed hops'),
          content: Text(global.itemsMan.getSelected<RT>()!.allowedHops.toString()),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'))
          ],
        );
      },
    );
  }

  void takeUnallowedHopsClick(int devId) {
    setState(
      () {
        BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_UNALLOWED_HOPS);
        var tid = global.postManager.sendPackage(getInfo);
        widget.tits.add(tid);
        global.sendingState[devId]![global.ParametersGroup.unallowedHops] = global.SendingState.sendingState;
      },
    );
  }

  void dialogUnallowedHopsBuilder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unallowed hops'),
          content: Text(global.itemsMan.getSelected<RT>()!.unallowedHops.toString()),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'))
          ],
        );
      },
    );
  }

  void takeRetransmissionAllClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_ALLOWED_HOPS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.retransmissionRequests.add(tid);
      global.sendingState[devId]![global.ParametersGroup.rebroadcastToEveryone] = global.SendingState.sendingState;
    });
  }

  void setRetransmissionAllClick(int devId, bool checked) {
    setState(() {
      HopsPackage hopsPackage = HopsPackage();
      hopsPackage.setReceiver(devId);
      hopsPackage.setSender(RoutesManager.getLaptopAddress());
      hopsPackage.addHop(checked ? RoutesManager.getRtAllHop() : 0);
      hopsPackage.fillZeroHops();
      var tid = global.postManager.sendPackage(hopsPackage);
      widget.setRequests[tid] = hopsPackage;
      widget.tits.add(tid);
      global.retransmissionRequests.add(tid);
      global.sendingState[devId]![global.ParametersGroup.rebroadcastToEveryone] = global.SendingState.sendingState;
    });
  }

/*  void takePriorityClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_ALLOWED_HOPS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void setPriorityClick(int devId, bool priority) {
    setState(() {
      HopsPackage hopsPackage = HopsPackage();
      hopsPackage.setReceiver(devId);
      hopsPackage.setSender(RoutesManager.getLaptopAddress());
      hopsPackage.addHop(priority ? RoutesManager.getRtAllHop() : 0);
      hopsPackage.addHop(0);
      var tid = global.postManager.sendPackage(hopsPackage);
      widget.setRequests[tid] = hopsPackage;
      widget.tits.add(tid);
    });
  }*/

  void buttonResetRetransmissionClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.SET_DEFAULT_NETWORK);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  // Save/Reset settings
  //TODO Защита от дурня строка 7к в mainwindow.cpp

  void rebootDevice(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.REBOOT_SYSTEM);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void saveDeviceParam(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.SAVE_PARAMETERS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void returnDeviceToDefaultParam(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.SET_DEFAULT_PARAMETERS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  // Connected devices

  void takeInternalDeviceParamClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_STATE);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.onOffInDev] = global.SendingState.sendingState;
    });
  }

  void setInternalDeviceParamClick(int devId, int mask) {
    setState(() {
      StatePackage statePackage = StatePackage();
      statePackage.setReceiver(devId);
      statePackage.setSender(RoutesManager.getLaptopAddress());
      statePackage.setStateMask(mask);
      var tid = global.postManager.sendPackage(statePackage);
      widget.setRequests[tid] = statePackage;
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.onOffInDev] = global.SendingState.sendingState;
    });
  }

  void takeInternalDeviceStateClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_PERIPHERY);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.deviceStatus] = global.SendingState.sendingState;
    });
  }

  // Internal power

  void takeSafetyCatch(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_SAFETY_CATCH);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.safetyCatch] = global.SendingState.sendingState;
    });
  }

  void setSafetyCatch(int devId, bool safetyCatch) {
    setState(() {
      ExternalPowerSafetyCatchPackage externalPowerSafetyCatchPackage = ExternalPowerSafetyCatchPackage();
      externalPowerSafetyCatchPackage.setReceiver(devId);
      externalPowerSafetyCatchPackage.setSender(RoutesManager.getLaptopAddress());
      externalPowerSafetyCatchPackage.setSafetyCatchState(safetyCatch);
      var tid = global.postManager.sendPackage(externalPowerSafetyCatchPackage);
      widget.setRequests[tid] = externalPowerSafetyCatchPackage;
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.safetyCatch] = global.SendingState.sendingState;
    });
  }

  void takeAutoExtPower(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_AUTO_EXT_POWER);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.switchingBreak] = global.SendingState.sendingState;
    });
  }

  void setAutoExtPower(int devId, bool extPower, int delayS, int durationS) {
    setState(() {
      AutoExternalPowerPackage autoExternalPowerPackage = AutoExternalPowerPackage();
      autoExternalPowerPackage.setReceiver(devId);
      autoExternalPowerPackage.setSender(RoutesManager.getLaptopAddress());
      autoExternalPowerPackage.setActivationDelay(delayS);
      autoExternalPowerPackage.setImpulseDuration(durationS);
      autoExternalPowerPackage.setAutoExternalPowerModeState(extPower);
      var tid = global.postManager.sendPackage(autoExternalPowerPackage);
      widget.setRequests[tid] = autoExternalPowerPackage;
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.switchingBreak] = global.SendingState.sendingState;
    });
  }

  void takeExternalPowerClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_EXTERNAL_POWER);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.power] = global.SendingState.sendingState;
    });
  }

  void setExternalPowerClick(int devId, ExternalPower extFlag) {
    setState(() {
      ExternalPowerPackage externalPowerPackage = ExternalPowerPackage();
      externalPowerPackage.setReceiver(devId);
      externalPowerPackage.setSender(RoutesManager.getLaptopAddress());
      externalPowerPackage.setExternalPowerState(extFlag);
      var tid = global.postManager.sendPackage(externalPowerPackage);
      widget.setRequests[tid] = externalPowerPackage;
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.power] = global.SendingState.sendingState;
    });
  }

  // Power source

  void takeBatteryMonitorClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_BATTERY_MONITOR);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.powerSupply] = global.SendingState.sendingState;
    });
  }

  //Seismic settings

  void takeStateHumanTransportSensitivityClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_ALARM_REASON_MASK);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.humanTransport] = global.SendingState.sendingState;
    });
  }

  void setStateHumanTransportSensitivityClick(int devId, int mask) {
    setState(() {
      AlarmReasonMaskPackage alarmReasonMaskPackage = AlarmReasonMaskPackage();
      alarmReasonMaskPackage.setReceiver(devId);
      alarmReasonMaskPackage.setSender(RoutesManager.getLaptopAddress());
      alarmReasonMaskPackage.setAlarmReasonMask(mask);
      var tid = global.postManager.sendPackage(alarmReasonMaskPackage);
      widget.setRequests[tid] = alarmReasonMaskPackage;

      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.humanTransport] = global.SendingState.sendingState;
    });
  }

  void takeSignalSwingClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_SIGNAL_SWING);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.ratioSign] = global.SendingState.sendingState;
    });
  }

  void takeHumanSensitivityClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_HUMAN_SENSITIVITY);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.humSens] = global.SendingState.sendingState;
    });
  }

  void setHumanSensitivityClick(int devId, int sensitivity) {
    setState(() {
      HumanSensitivityPackage humanSensitivityPackage = HumanSensitivityPackage();
      humanSensitivityPackage.setReceiver(devId);
      humanSensitivityPackage.setSender(RoutesManager.getLaptopAddress());
      humanSensitivityPackage.setHumanSensitivity(sensitivity);
      var tid = global.postManager.sendPackage(humanSensitivityPackage);
      widget.setRequests[tid] = humanSensitivityPackage;
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.humSens] = global.SendingState.sendingState;
    });
  }

  void takeTransportSensitivityClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_TRANSPORT_SENSITIVITY);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.autoSens] = global.SendingState.sendingState;
    });
  }

  void setTransportSensitivityClick(int devId, int sensitivity) {
    setState(() {
      TransportSensitivityPackage transportSensitivityPackage = TransportSensitivityPackage();
      transportSensitivityPackage.setReceiver(devId);
      transportSensitivityPackage.setSender(RoutesManager.getLaptopAddress());
      transportSensitivityPackage.setTransportSensitivity(sensitivity);
      var tid = global.postManager.sendPackage(transportSensitivityPackage);
      widget.setRequests[tid] = transportSensitivityPackage;
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.autoSens] = global.SendingState.sendingState;
    });
  }

  void takeCriterionFilterClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_CRITERION_FILTER);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.critFilter] = global.SendingState.sendingState;
    });
  }

  void setCriterionFilterClick(int devId, CriterionFilter filter) {
    setState(() {
      CriterionFilterPackage criterionFilterPackage = CriterionFilterPackage();
      criterionFilterPackage.setReceiver(devId);
      criterionFilterPackage.setSender(RoutesManager.getLaptopAddress());
      criterionFilterPackage.setCriterionFilter(filter);
      var tid = global.postManager.sendPackage(criterionFilterPackage);
      widget.setRequests[tid] = criterionFilterPackage;
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.critFilter] = global.SendingState.sendingState;
    });
  }

  void takeSignalToNoiseClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_SIGNAL_TO_NOISE_RATIO);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.snr] = global.SendingState.sendingState;
    });
  }

  void setSignalToNoiseClick(int devId, int snr) {
    setState(() {
      SignalToNoiseRatioPackage signalToNoiseRatioPackage = SignalToNoiseRatioPackage();
      signalToNoiseRatioPackage.setReceiver(devId);
      signalToNoiseRatioPackage.setSender(RoutesManager.getLaptopAddress());
      signalToNoiseRatioPackage.setSignalToNoiseRatio(snr);
      var tid = global.postManager.sendPackage(signalToNoiseRatioPackage);
      widget.setRequests[tid] = signalToNoiseRatioPackage;
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.snr] = global.SendingState.sendingState;
    });
  }

  void takeCriterionRecognitionClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_CRITERION_RECOGNITION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.recogParam] = global.SendingState.sendingState;
    });
  }

  void setCriterionRecognitionClick(int devId, int index, List<int> value) {
    setState(() {
      CriterionRecognitionPackage criterionRecognitionPackage = CriterionRecognitionPackage();
      criterionRecognitionPackage.setReceiver(devId);
      criterionRecognitionPackage.setSender(RoutesManager.getLaptopAddress());
      for (int i = 0; i < index; i++) {
        criterionRecognitionPackage.setCriterion(i, value[i]);
      }
      var tid = global.postManager.sendPackage(criterionRecognitionPackage);
      widget.setRequests[tid] = criterionRecognitionPackage;
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.recogParam] = global.SendingState.sendingState;
    });
  }

  void takeEEPROMClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_EEPROM_FACTORS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.alarmFilter] = global.SendingState.sendingState;
    });
  }

  void setEEPROMClick(int devId, int singleHuman, int singleTransport, int seriesHuman, int seriesTransport) {
    setState(() {
      var device = global.itemsMan.getSelected<RT>()!;
      if (!device.EEPROMInitialized) {
        return;
      }

      EEPROMFactorsPackage pfp = EEPROMFactorsPackage();
      pfp.setReceiver(devId);
      pfp.setSender(RoutesManager.getLaptopAddress());
      pfp.setWakeNetworkResendTimeMs(device.wakeNetworkResendTimeMs);
      pfp.setAlarmResendTimeMs(device.alarmResendTimeMs);
      pfp.setSeismicResendTimeMs(device.seismicResendTimeMs);
      pfp.setPhotoResendTimeMs(device.photoResendTimeMs);
      pfp.setAlarmTriesResend(device.alarmTriesResend);
      pfp.setSeismicTriesResend(device.seismicTriesResend);
      pfp.setPhotoTriesResend(device.photoTriesResend);
      pfp.setPeriodicSendTelemetryTime10S(device.periodicSendTelemetryTime10s);
      pfp.setAfterSeismicAlarmPauseS(device.afterSeismicAlarmPauseS);
      pfp.setAfterLineAlarmPauseS(device.afterLineAlarmPauseS);
      pfp.setBatteryPeriodicUpdate10Min(device.batteryPeriodicUpdate10min);
      pfp.setBatteryVoltageThresholdAlarm100mV(device.batteryVoltageThresholdAlarm100mV);
      pfp.setBatteryResidueThresholdAlarmPC(device.batteryResidueThresholdAlarmPC);
      pfp.setBatteryPeriodicAlarmH(device.batteryPeriodicAlarmH);
      pfp.setDeviceType(device.deviceType);

      pfp.setHumanSignalsTreshold(singleHuman);
      pfp.setHumanIntervalsCount(seriesHuman);
      pfp.setTransportSignalsTreshold(singleTransport);
      pfp.setTransportIntervalsCount(seriesTransport);
      var tid = global.postManager.sendPackage(pfp);
      widget.setRequests[tid] = pfp;
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.alarmFilter] = global.SendingState.sendingState;
    });
  }

  //Camera settings

  void takePhotoParametersClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_PHOTO_PARAMETERS);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.cameraSettings] = global.SendingState.sendingState;
    });
  }

  void setPhotoParametersClick(int devId, int invLightSensitivity, PhotoImageCompression compressionRatio) {
    setState(() {
      PhotoParametersPackage photoParametersPackage = PhotoParametersPackage();
      photoParametersPackage.setReceiver(devId);
      photoParametersPackage.setSender(RoutesManager.getLaptopAddress());
      photoParametersPackage.setParameters(invLightSensitivity, compressionRatio);
      var tid = global.postManager.sendPackage(photoParametersPackage);
      widget.setRequests[tid] = photoParametersPackage;
      widget.tits.add(tid);
      global.sendingState[devId]![global.ParametersGroup.cameraSettings] = global.SendingState.sendingState;
    });
  }

  void takeAllInfoClick(int devId) {
    setState(() {
      BasePackage getInfo = BasePackage.makeBaseRequest(devId, PackageType.GET_ALL_INFORMATION);
      var tid = global.postManager.sendPackage(getInfo);
      widget.tits.add(tid);
    });
  }

  void showError(String? string) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(string!),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'))
          ],
        );
      },
    );
  }

  void setMyCordsForDevice() {
    setState(() {
      widget._cloneItem.latitude = global.pageWithMap.coord()!.latitude;
      widget._cloneItem.longitude = global.pageWithMap.coord()!.longitude;
      global.listMapMarkers[widget._cloneItem.id]!.point.latitude = widget._cloneItem.latitude;
      global.listMapMarkers[widget._cloneItem.id]!.point.longitude = widget._cloneItem.longitude;
      _controllerLatitude.text = widget._cloneItem.latitude.toStringAsFixed(6);
      _controllerLongitude.text = widget._cloneItem.longitude.toStringAsFixed(6);
    });
  }

  _changeId() {
    setState(() {widget._cloneItem.id = int.parse(_controllerId.text);
    global.initSendingState(widget._cloneItem.id);
    });
  }

  _changeLongitude() {
    setState(() => widget._cloneItem.longitude = double.parse(_controllerLongitude.text));
  }

  _changeLatitude() {
    setState(() => widget._cloneItem.latitude = double.parse(_controllerLatitude.text));
  }

  _changeHumanSensitivity() {
    var csd = widget._cloneItem as CSD;
    setState(() => csd.humanSensitivity = int.parse(_controllerHumanSensitivity.text));
  }

  _changeTransportSensitivity() {
    var csd = widget._cloneItem as CSD;
    setState(() => csd.transportSensitivity = int.parse(_controllerTransportSensitivity.text));
  }

  _changeRatioSNR() {
    var csd = widget._cloneItem as CSD;
    setState(() => csd.snr = int.parse(_controllerRatioTrToNoise.text));
  }

  _changeInterferencePerson() {
    var csd = widget._cloneItem as CSD;
    setState(() => csd.recognitionParameters[0] = int.parse(_controllerRatioIntToPerson.text));
  }

  _changePersonTransport() {
    var csd = widget._cloneItem as CSD;
    setState(() => csd.recognitionParameters[1] = int.parse(_controllerRatioPersonToTransport.text));
  }

  _changeSingleHuman() {
    var csd = widget._cloneItem as CSD;
    setState(() => csd.humanSignalsTreshold = int.parse(_controllerSinglePerson.text));
  }

  _changeSingleTransport() {
    var csd = widget._cloneItem as CSD;
    setState(() => csd.transportSignalsTreshold = int.parse(_controllerSingleTransport.text));
  }

  _changeCameraSensitivity() {
    var cpd = widget._cloneItem as CPD;
    setState(() => cpd.cameraSensitivity = int.parse(_controllerCameraSensitivity.text));
  }

  void setAllNums() {
    setState(() {
      var item = global.itemsMan.getSelected<Marker>();
      if (item == null) return;
      widget._cloneItem = item.clone();
      bufferDeviceType = widget._cloneItem.typeName();
      _controllerId.text = widget._cloneItem.id.toString();
      _controllerId.addListener(_changeId);

      _controllerLongitude.text = widget._cloneItem.longitude.toStringAsFixed(6);
      _controllerLongitude.addListener(_changeLongitude);
      _controllerLatitude.text = widget._cloneItem.latitude.toStringAsFixed(6);
      _controllerLatitude.addListener(_changeLatitude);

      if (widget._cloneItem is CSD) {
        var csd = widget._cloneItem as CSD;
        _controllerHumanSensitivity.text = csd.humanSensitivity.toString();
        _controllerHumanSensitivity.addListener(_changeHumanSensitivity);
        _controllerTransportSensitivity.text = csd.transportSensitivity.toString();
        _controllerTransportSensitivity.addListener(_changeTransportSensitivity);
        _controllerRatioTrToNoise.text = csd.snr.toString();
        _controllerRatioTrToNoise.addListener(_changeRatioSNR);
        _controllerRatioIntToPerson.text = csd.recognitionParameters[0].toString();
        _controllerRatioIntToPerson.addListener(_changeInterferencePerson);
        _controllerRatioPersonToTransport.text = csd.recognitionParameters[1].toString();
        _controllerRatioPersonToTransport.addListener(_changePersonTransport);
        _controllerSinglePerson.text = csd.humanSignalsTreshold.toString();
        _controllerSinglePerson.addListener(_changeSingleHuman);
        _controllerSingleTransport.text = csd.transportSignalsTreshold.toString();
        _controllerSingleTransport.addListener(_changeSingleTransport);
      }

      if (widget._cloneItem is CPD) {
        var cpd = widget._cloneItem as CPD;
        _controllerCameraSensitivity.text = cpd.cameraSensitivity.toString();
        _controllerCameraSensitivity.addListener(_changeCameraSensitivity);
      }
    });
  }

  Widget buildMainSettings(BuildContext context) {
    if (widget._cloneItem is! NetDevice) {
      return Container();
    }

    var nd = widget._cloneItem as NetDevice;

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('ID:'),
              ),
            ),
            Expanded(
              flex: 1,
              child: TextField(
                controller: _controllerId,
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => checkDevID(nd.id, global.itemsMan.getSelected<NetDevice>()!.id),
                icon: const Icon(Icons.check),
                color: Colors.green,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('Type:'),
              ),
            ),
            Expanded(
              flex: 1,
              child: DropdownButton<String>(
                alignment: AlignmentDirectional.topCenter,
                onChanged: (String? value) {
                  bufferDeviceType = value!;
                },
                value: bufferDeviceType,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_double_arrow_down),
                items: global.deviceTypeList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => checkDevType(nd.id, nd.typeName(), bufferDeviceType!),
                icon: const Icon(Icons.check),
                color: Colors.green,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('Date/time:'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[nd.id]![global.ParametersGroup.dateTime] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[nd.id]![global.ParametersGroup.dateTime] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Text(nd.time.toString().substring(0, 19), textAlign: TextAlign.center),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => takeTimeClick(nd.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setTimeClick(nd.id),
                    icon: const Icon(
                      Icons.access_time,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: SizedBox(
                width: 100,
                child: Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text('Firmware version:'),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[nd.id]![global.ParametersGroup.firmwareVersion] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[nd.id]![global.ParametersGroup.firmwareVersion] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Text(nd.firmwareVersion.toString(), textAlign: TextAlign.center),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => takeVersionClick(nd.id),
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCoordSettings(BuildContext context) {
    if (widget._cloneItem is! NetDevice) {
      return Container();
    }

    var nd = widget._cloneItem as NetDevice;

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('Latitude:'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[nd.id]![global.ParametersGroup.coordinates] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[nd.id]![global.ParametersGroup.coordinates] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: TextField(
                  controller: _controllerLatitude,
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => setMyCordsForDevice(),
                icon: const Icon(Icons.navigation),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('Longitude:'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[nd.id]![global.ParametersGroup.coordinates] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[nd.id]![global.ParametersGroup.coordinates] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: TextField(
                  controller: _controllerLongitude,
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => takeCordClick(nd.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setCordClick(nd.id, nd.latitude, nd.longitude),
                    icon: const Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildRadioSettings(BuildContext context) {
    if (widget._cloneItem is! RT) {
      return Container();
    }

    var rt = widget._cloneItem as RT;

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('Signal strength:'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[rt.id]![global.ParametersGroup.signalStrength] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[rt.id]![global.ParametersGroup.signalStrength] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Text(rt.RSSI.toString(), textAlign: TextAlign.center),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => takeSignalStrengthClick(rt.id),
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('Allowed hops:'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[rt.id]![global.ParametersGroup.allowedHops] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[rt.id]![global.ParametersGroup.allowedHops] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Text(''),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => takeAllowedHopsClick(rt.id),
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('Unallowed hops:'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[rt.id]![global.ParametersGroup.unallowedHops] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[rt.id]![global.ParametersGroup.unallowedHops] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Text(''),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => takeUnallowedHopsClick(rt.id),
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text("Rebroadcast to everyone:"),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[rt.id]![global.ParametersGroup.rebroadcastToEveryone] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[rt.id]![global.ParametersGroup.rebroadcastToEveryone] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Checkbox(
                    value: rt.allowedHops[0] == 65535 ? true : false,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value! == true) {
                          rt.allowedHops[0] = 65535;
                        } else {
                          rt.allowedHops[0] = 0;
                        }
                      });
                    }),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => takeRetransmissionAllClick(rt.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setRetransmissionAllClick(rt.id, rt.allowedHops[0] == 65535),
                    icon: const Icon(Icons.check),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              onPressed: () => buttonResetRetransmissionClick(rt.id),
              child: const Text('Reset retransmission'),
            ),
          ],
        ),
      ],
    );
  }

  void checkSaveSettingsButton(int devId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Do you really want to save all settings on selected device?"),
          actions: [
            TextButton(
              onPressed: () {
                saveDeviceParam(devId);
                Navigator.pop(context);
              },
              child: const Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void checkResetSettingsButton(int devId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Do you really want to reboot selected device?"),
          actions: [
            TextButton(
              onPressed: () {
                rebootDevice(devId);
                Navigator.pop(context);
              },
              child: const Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void checkFactoryResetSettingsButton(int devId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Do you really want to reset selected device to factory settings?"),
          actions: [
            TextButton(
              onPressed: () {
                returnDeviceToDefaultParam(devId);
                Navigator.pop(context);
              },
              child: const Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget buildDeviceSettings(BuildContext context) {
    if (widget._cloneItem is! NetDevice) {
      return Container();
    }

    var nd = widget._cloneItem as NetDevice;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        OutlinedButton(
          onPressed: () => checkResetSettingsButton(nd.id),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restart_alt),
              Text('Reboot device'),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () => checkSaveSettingsButton(nd.id),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save),
              Text('Save settings'),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () => checkFactoryResetSettingsButton(nd.id),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restore),
              Text('Factory reset'),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildConnectedDevices(BuildContext context) {
    if (widget._cloneItem is! RT) {
      return Container();
    }

    var rt = widget._cloneItem as RT;

    List<Widget> children = [];

    if (widget._cloneItem is RT) {
      children.add(
        const Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text("On/Off in. dev.:"),
            ),
          ],
        ),
      );
      children.add(
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text("In. dev. 1:"),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[rt.id]![global.ParametersGroup.onOffInDev] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[rt.id]![global.ParametersGroup.onOffInDev] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Checkbox(
                    value: rt.stateMask & DeviceState.MONITORING_LINE1 != 0,
                    onChanged: (bool? value) {
                      if (value!) {
                        rt.stateMask |= DeviceState.MONITORING_LINE1;
                      } else {
                        rt.stateMask &= ~DeviceState.MONITORING_LINE1;
                      }
                      setState(() {});
                    }),
              ),
            ),
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
          ],
        ),
      );
      children.add(
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text("In. dev. 2:"),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[rt.id]![global.ParametersGroup.onOffInDev] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[rt.id]![global.ParametersGroup.onOffInDev] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Checkbox(
                    value: rt.stateMask & DeviceState.MONITORING_LINE2 != 0,
                    onChanged: (bool? value) {
                      if (value!) {
                        rt.stateMask |= DeviceState.MONITORING_LINE2;
                      } else {
                        rt.stateMask &= ~DeviceState.MONITORING_LINE2;
                      }
                      setState(() {});
                    }),
              ),
            ),
            Expanded(
              flex: 1,
              child: (widget._cloneItem is! CSD && widget._cloneItem is! CPD)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => takeInternalDeviceParamClick(rt.id),
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.blue,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setInternalDeviceParamClick(rt.id, rt.stateMask),
                          icon: const Icon(Icons.check),
                          color: Colors.green,
                        ),
                      ],
                    )
                  : const SizedBox(
                      width: 100,
                    ),
            ),
          ],
        ),
      );
    }

    if (widget._cloneItem is CSD) {
      children.add(
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text("Geophone:"),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[rt.id]![global.ParametersGroup.onOffInDev] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[rt.id]![global.ParametersGroup.onOffInDev] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Checkbox(
                    value: rt.stateMask & DeviceState.MONITOR_SEISMIC != 0,
                    onChanged: (bool? value) {
                      if (value!) {
                        rt.stateMask |= DeviceState.MONITOR_SEISMIC;
                      } else {
                        rt.stateMask &= ~DeviceState.MONITOR_SEISMIC;
                      }
                      setState(() {});
                    }),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => takeInternalDeviceParamClick(rt.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setInternalDeviceParamClick(rt.id, rt.stateMask),
                    icon: const Icon(Icons.check),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (widget._cloneItem is CPD) {
      children.add(
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text("Camera trap:"),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[rt.id]![global.ParametersGroup.onOffInDev] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[rt.id]![global.ParametersGroup.onOffInDev] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Checkbox(
                    value: rt.stateMask & DeviceState.LINES_CAMERA_TRAP != 0,
                    onChanged: (bool? value) {
                      if (value!) {
                        rt.stateMask |= DeviceState.LINES_CAMERA_TRAP;
                      } else {
                        rt.stateMask &= ~DeviceState.LINES_CAMERA_TRAP;
                      }
                      setState(() {});
                    }),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => takeInternalDeviceParamClick(rt.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setInternalDeviceParamClick(rt.id, rt.stateMask),
                    icon: const Icon(Icons.check),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (widget._cloneItem is RT) {
      children.add(
        const Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text("Device status:"),
            ),
          ],
        ),
      );
      children.add(
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text("In. dev. 1:"),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[rt.id]![global.ParametersGroup.deviceStatus] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[rt.id]![global.ParametersGroup.deviceStatus] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Checkbox(
                    value: rt.peripheryMask & PeripheryMask.LINE1 != 0,
                    onChanged: (bool? value) {
                      if (value!) {
                        rt.peripheryMask |= PeripheryMask.LINE1;
                      } else {
                        rt.peripheryMask &= ~PeripheryMask.LINE1;
                      }
                      setState(() {});
                    }),
              ),
            ),
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
          ],
        ),
      );
      children.add(
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text("In. dev. 2:"),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[rt.id]![global.ParametersGroup.deviceStatus] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[rt.id]![global.ParametersGroup.deviceStatus] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Checkbox(
                    value: rt.peripheryMask & PeripheryMask.LINE2 != 0,
                    onChanged: (bool? value) {
                      if (value!) {
                        rt.peripheryMask |= PeripheryMask.LINE2;
                      } else {
                        rt.peripheryMask &= ~PeripheryMask.LINE2;
                      }

                      setState(() {});
                    }),
              ),
            ),
            Expanded(
              flex: 1,
              child: widget._cloneItem is CPD
                  ? SizedBox()
                  : IconButton(
                      onPressed: () => takeInternalDeviceStateClick(rt.id),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.blue,
                      ),
                    ),
            ),
          ],
        ),
      );
    }

    if (widget._cloneItem is CPD) {
      children.add(
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text("Camera:"),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[rt.id]![global.ParametersGroup.deviceStatus] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[rt.id]![global.ParametersGroup.deviceStatus] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Checkbox(
                    value: rt.peripheryMask & PeripheryMask.CAMERA != 0,
                    onChanged: (bool? value) {
                      if (value!) {
                        rt.peripheryMask |= PeripheryMask.CAMERA;
                      } else {
                        rt.peripheryMask &= ~PeripheryMask.CAMERA;
                      }

                      setState(() {});
                    }),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => takeInternalDeviceStateClick(rt.id),
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: children,
    );
  }

  Widget buildExtPower(BuildContext context) {
    if (widget._cloneItem is! RT) {
      return Container();
    }

    var rt = widget._cloneItem as RT;

    return Column(children: [
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text("Safety catch:"),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Container(
                color: global.sendingState[rt.id]![global.ParametersGroup.safetyCatch] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[rt.id]![global.ParametersGroup.safetyCatch] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Checkbox(
                    value: rt.extPowerSafetyCatchState,
                    onChanged: (bool? value) {
                      setState(() {
                        rt.extPowerSafetyCatchState = value!;
                      });
                    }),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => takeSafetyCatch(rt.id),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () => setSafetyCatch(rt.id, rt.extPowerSafetyCatchState),
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('Activation delay:'),
            ),
          ),
          Expanded(
            flex: 1,
            child: DropdownButton<int>(
              selectedItemBuilder: (BuildContext context) {
                return global.delayList.map((int value) {
                  return Align(
                    alignment: Alignment.center,
                    child: Text(
                      '$value sec',
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList();
              },
              isExpanded: true,
              items: global.delayList.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value sec'),
                );
              }).toList(),
              onChanged: rt.extPowerSafetyCatchState
                  ? (int? value) {
                      rt.autoExtPowerActivationDelaySec = value!;
                    }
                  : null,
              value: global.delayList.contains(rt.autoExtPowerActivationDelaySec) ? rt.autoExtPowerActivationDelaySec : null,
              icon: const Icon(Icons.keyboard_double_arrow_down),
            ),
          ),
          const Expanded(
            flex: 1,
            child: SizedBox(),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('Pulse duration:'),
            ),
          ),
          Expanded(
            flex: 1,
            child: DropdownButton<int>(
              selectedItemBuilder: (BuildContext context) {
                return global.impulseList.map((int value) {
                  return Align(
                    alignment: Alignment.center,
                    child: Text(
                      '$value sec',
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList();
              },
              isExpanded: true,
              items: global.impulseList.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value sec'),
                );
              }).toList(),
              onChanged: rt.extPowerSafetyCatchState
                  ? (int? value) {
                      rt.extPowerImpulseDurationSec = value!;
                    }
                  : null,
              value: global.impulseList.contains(rt.extPowerImpulseDurationSec) ? rt.extPowerImpulseDurationSec : null,
              icon: const Icon(Icons.keyboard_double_arrow_down),
            ),
          ),
          const Expanded(
            flex: 1,
            child: SizedBox(),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text("Switching by break:"),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[rt.id]![global.ParametersGroup.switchingBreak] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[rt.id]![global.ParametersGroup.switchingBreak] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: Checkbox(
                value: rt.autoExtPowerState,
                onChanged: global.itemsMan.getSelected<RT>() != null
                    ? global.itemsMan.getSelected<RT>()!.extPowerSafetyCatchState
                        ? (bool? value) {
                            setState(() {
                              rt.autoExtPowerState = value!;
                            });
                          }
                        : null
                    : null,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => takeAutoExtPower(rt.id),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setAutoExtPower(rt.id, rt.autoExtPowerState, rt.autoExtPowerActivationDelaySec, rt.extPowerImpulseDurationSec),
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text("Power:"),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[rt.id]![global.ParametersGroup.power] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[rt.id]![global.ParametersGroup.power] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: Checkbox(
                  value: rt.extPower.index != 0,
                  onChanged: (bool? value) {
                    setState(() {
                      value! ? rt.extPower = ExternalPower.ON : rt.extPower = ExternalPower.OFF;
                    });
                  }),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => takeExternalPowerClick(rt.id),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () => setExternalPowerClick(rt.id, rt.extPower),
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    ]);
  }

  Widget buildPowerSupply(BuildContext context) {
    if (widget._cloneItem is! RT) {
      return Container();
    }

    var rt = widget._cloneItem as RT;

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('Voltage, V:'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[rt.id]![global.ParametersGroup.powerSupply] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[rt.id]![global.ParametersGroup.powerSupply] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Text(rt.batMonVoltage.toStringAsFixed(2), textAlign: TextAlign.center),
              ),
            ),
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
          ],
        ),
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('Temperature, °С:'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[rt.id]![global.ParametersGroup.powerSupply] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[rt.id]![global.ParametersGroup.powerSupply] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Text(rt.batMonTemperature.toStringAsFixed(2), textAlign: TextAlign.center),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => takeBatteryMonitorClick(rt.id),
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSeismicSettings(BuildContext context) {
    if (widget._cloneItem is! CSD) {
      return Container();
    }

    var csd = widget._cloneItem as CSD;

    return Column(children: [
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text("Human:"),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[csd.id]![global.ParametersGroup.humanTransport] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[csd.id]![global.ParametersGroup.humanTransport] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: Checkbox(
                  value: csd.alarmReasonMask & AlarmReasonMask.HUMAN != 0,
                  onChanged: (bool? value) {
                    if (value!) {
                      csd.alarmReasonMask |= AlarmReasonMask.HUMAN;
                    } else {
                      csd.alarmReasonMask &= ~AlarmReasonMask.HUMAN;
                    }
                    setState(() {});
                  }),
            ),
          ),
          const Expanded(
            flex: 1,
            child: SizedBox(),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text("Transport:"),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[csd.id]![global.ParametersGroup.humanTransport] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[csd.id]![global.ParametersGroup.humanTransport] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: Checkbox(
                  value: csd.alarmReasonMask & AlarmReasonMask.AUTO != 0,
                  onChanged: (bool? value) {
                    if (value!) {
                      csd.alarmReasonMask |= AlarmReasonMask.AUTO;
                    } else {
                      csd.alarmReasonMask &= ~AlarmReasonMask.AUTO;
                    }
                    setState(() {});
                  }),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => takeStateHumanTransportSensitivityClick(csd.id),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () => setStateHumanTransportSensitivityClick(csd.id, csd.alarmReasonMask),
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('Signal swing:'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[csd.id]![global.ParametersGroup.ratioSign] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[csd.id]![global.ParametersGroup.ratioSign] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: Text(csd.signalSwing.toString(), textAlign: TextAlign.center),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () => takeSignalSwingClick(csd.id),
              icon: const Icon(
                Icons.refresh,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('Human sensitivity: (25-255)'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[csd.id]![global.ParametersGroup.humSens] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[csd.id]![global.ParametersGroup.humSens] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: TextField(
                controller: _controllerHumanSensitivity,
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => takeHumanSensitivityClick(csd.id),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    csd.humanSensitivity > 24 && csd.humanSensitivity < 256
                        ? setHumanSensitivityClick(global.itemsMan.getSelected<CSD>()!.id, csd.humanSensitivity)
                        : {
                            showError('Sensitivity from 25 to 255'),
                            csd.humanSensitivity = global.itemsMan.getSelected<CSD>()!.humanSensitivity,
                          };
                  },
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('Transport sensitivity: (25-255)'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[csd.id]![global.ParametersGroup.autoSens] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[csd.id]![global.ParametersGroup.autoSens] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: TextField(
                controller: _controllerTransportSensitivity,
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => takeTransportSensitivityClick(csd.id),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    csd.transportSensitivity > 24 && csd.transportSensitivity < 256
                        ? setTransportSensitivityClick(csd.id, csd.transportSensitivity)
                        : {
                            showError('Sensitivity from 25 to 255'),
                            csd.transportSensitivity = global.itemsMan.getSelected<CSD>()!.transportSensitivity
                          };
                  },
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('Criterion filter:'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[csd.id]![global.ParametersGroup.critFilter] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[csd.id]![global.ParametersGroup.critFilter] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: DropdownButton<CriterionFilter>(
                isExpanded: true,
                items: CriterionFilter.values.map<DropdownMenuItem<CriterionFilter>>((CriterionFilter value) {
                  return DropdownMenuItem<CriterionFilter>(
                    value: value,
                    child: Text(global.critFilter[value.index]),
                  );
                }).toList(),
                onChanged: (CriterionFilter? value) {
                  csd.criterionFilter = value!;
                },
                value: csd.criterionFilter,
                icon: const Icon(Icons.keyboard_double_arrow_down),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => takeCriterionFilterClick(csd.id),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () => setCriterionFilterClick(csd.id, csd.criterionFilter),
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('Ratio signal transport/noise: (5-40)'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[csd.id]![global.ParametersGroup.snr] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[csd.id]![global.ParametersGroup.snr] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: TextField(
                controller: _controllerRatioTrToNoise,
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => takeSignalToNoiseClick(csd.id),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    csd.snr > 4 && csd.snr < 41
                        ? setSignalToNoiseClick(csd.id, csd.snr)
                        : {showError('Ratio from 5 to 40'), csd.snr = global.itemsMan.getSelected<CSD>()!.snr};
                  },
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
      const Row(children: [
        Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text('Recognition parameters:'),
        ),
      ]),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text("Interference/Person"),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[csd.id]![global.ParametersGroup.recogParam] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[csd.id]![global.ParametersGroup.recogParam] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: TextField(
                controller: _controllerRatioIntToPerson,
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: SizedBox(),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('Person/Transport'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[csd.id]![global.ParametersGroup.recogParam] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[csd.id]![global.ParametersGroup.recogParam] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: TextField(
                controller: _controllerRatioPersonToTransport,
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => takeCriterionRecognitionClick(csd.id),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    csd.recognitionParameters[0] > -1 &&
                            csd.recognitionParameters[0] < 256 &&
                            csd.recognitionParameters[1] > -1 &&
                            csd.recognitionParameters[1] < 256
                        ? setCriterionRecognitionClick(csd.id, csd.recognitionParameters.length, csd.recognitionParameters)
                        : showError('Parameters from 0 to 255');
                  },
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
      const Row(children: [
        Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text('Alarm filtering:'),
        ),
      ]),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text("Single(human):"),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[csd.id]![global.ParametersGroup.alarmFilter] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[csd.id]![global.ParametersGroup.alarmFilter] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: TextField(
                controller: _controllerSinglePerson,
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: SizedBox(),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text("Serial(person):"),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[csd.id]![global.ParametersGroup.alarmFilter] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[csd.id]![global.ParametersGroup.alarmFilter] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: DropdownButton<int>(
                selectedItemBuilder: (BuildContext context) {
                  return global.serialHuman.map((int value) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$value in ${value}0 sec',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList();
                },
                isExpanded: true,
                items: global.serialHuman.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value in ${value}0 seconds'),
                  );
                }).toList(),
                onChanged: (int? value) {
                  csd.seriesHumanFilterTreshold = value!;
                },
                value: csd.seriesHumanFilterTreshold,
                icon: const Icon(Icons.keyboard_double_arrow_down),
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: SizedBox(),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text("Single(transport):"),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[csd.id]![global.ParametersGroup.alarmFilter] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[csd.id]![global.ParametersGroup.alarmFilter] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: TextField(
                controller: _controllerSingleTransport,
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: SizedBox(),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text("Serial(transport):"),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[csd.id]![global.ParametersGroup.alarmFilter] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[csd.id]![global.ParametersGroup.alarmFilter] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: DropdownButton<int>(
                selectedItemBuilder: (BuildContext context) {
                  return global.serialTransport.map((int value) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$value in ${value}0 sec',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList();
                },
                isExpanded: true,
                items: global.serialTransport.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value in ${value}0 seconds'),
                  );
                }).toList(),
                onChanged: (int? value) {
                  csd.seriesTransportFilterTreshold = value!;
                },
                value: csd.seriesTransportFilterTreshold,
                icon: const Icon(Icons.keyboard_double_arrow_down),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => takeEEPROMClick(csd.id),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    csd.humanSignalsTreshold > -1 &&
                            csd.humanSignalsTreshold < 256 &&
                            csd.transportSignalsTreshold > -1 &&
                            csd.transportSignalsTreshold < 256
                        ? {
                            csd.EEPROMInitialized
                                ? setEEPROMClick(csd.id, csd.humanSignalsTreshold, csd.transportSignalsTreshold,
                                    csd.seriesHumanFilterTreshold, csd.seriesTransportFilterTreshold)
                                : showError('Request data first'),
                          }
                        : showError('Parameters from 0 to 255');
                  },
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    ]);
  }

  Widget buildCameraSettings(BuildContext context) {
    if (widget._cloneItem is! CPD) {
      return Container();
    }

    var cpd = widget._cloneItem as CPD;

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('Sensitivity:'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[cpd.id]![global.ParametersGroup.cameraSettings] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[cpd.id]![global.ParametersGroup.cameraSettings] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: TextField(
                  controller: _controllerCameraSensitivity,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ),
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
          ],
        ),
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('Photo compression:'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[cpd.id]![global.ParametersGroup.cameraSettings] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[cpd.id]![global.ParametersGroup.cameraSettings] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: DropdownButton<PhotoImageCompression>(
                  isExpanded: true,
                  items: PhotoImageCompression.values.map<DropdownMenuItem<PhotoImageCompression>>((PhotoImageCompression value) {
                    return DropdownMenuItem<PhotoImageCompression>(
                      value: value,
                      child: Text(value.name),
                    );
                  }).toList(),
                  onChanged: (PhotoImageCompression? value) => cpd.cameraCompression = value!,
                  value: cpd.cameraCompression,
                  icon: const Icon(Icons.keyboard_double_arrow_down),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => takePhotoParametersClick(cpd.id),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      cpd.cameraSensitivity > -1 && cpd.cameraSensitivity < 256
                          ? setPhotoParametersClick(cpd.id, cpd.cameraSensitivity, cpd.cameraCompression)
                          : {
                              showError('Sensitivity from 0 to 255'),
                              cpd.cameraSensitivity = global.itemsMan.getSelected<CPD>()!.cameraSensitivity
                            };
                    },
                    icon: const Icon(Icons.check),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMCDSettings(BuildContext context) {
    if (widget._cloneItem is! MCD) {
      return Container();
    }

    var mcd = widget._cloneItem as MCD;

    return Column(children: [
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text("Priority:"),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[mcd.id]![global.ParametersGroup.priority] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[mcd.id]![global.ParametersGroup.priority] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: Checkbox(
                  value: mcd.priority,
                  onChanged: (bool? value) {
                    setState(() {
                      mcd.priority = value!;
                    });
                  }),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => takeRetransmissionAllClick(mcd.id),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () => setRetransmissionAllClick(mcd.id, mcd.priority),
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text("GPS:"),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: global.sendingState[mcd.id]![global.ParametersGroup.gps] == global.SendingState.notAnswerState
                  ? notSend
                  : global.sendingState[mcd.id]![global.ParametersGroup.gps] == global.SendingState.sendingState
                      ? trySend
                      : defaultColor,
              child: Checkbox(
                  value: mcd.GPSState,
                  onChanged: (bool? value) {
                    setState(() {
                      mcd.GPSState = value!;
                    });
                  }),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => takeExternalPowerClick(mcd.id),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () => setExternalPowerClick(mcd.id, mcd.GPSState ? ExternalPower.ON : ExternalPower.OFF),
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    ]);
  }

  Widget buildPowerMCD(BuildContext context) {
    if (widget._cloneItem is! MCD) {
      return Container();
    }

    var mcd = widget._cloneItem as MCD;

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('Voltage, V:'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: global.sendingState[mcd.id]![global.ParametersGroup.powerSupply] == global.SendingState.notAnswerState
                    ? notSend
                    : global.sendingState[mcd.id]![global.ParametersGroup.powerSupply] == global.SendingState.sendingState
                        ? trySend
                        : defaultColor,
                child: Text(mcd.batMonVoltage.toStringAsFixed(2), textAlign: TextAlign.center),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => takeBatteryMonitorClick(global.itemsMan.getSelected<NetDevice>()!.id),
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  final List<bool> _isOpenMain = List.filled(4, false);
  final List<bool> _isOpenCSD = List.filled(8, false);
  final List<bool> _isOpenCFU = List.filled(8, false);
  final List<bool> _isOpenRT = List.filled(7, false);
  final List<bool> _isOpenMCD = List.filled(5, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        actions: <Widget>[
          DropdownButton<String>(
            icon: const Icon(Icons.keyboard_double_arrow_down),
            value: widget.dropdownValue,
            items: widget.dropdownItems,
            onChanged: (String? value) {
              setState(() {
                widget.dropdownValue = value!;
                global.pageWithMap.unselectMapMarker();
                global.itemsMan.setSelected(int.parse(widget.dropdownValue));
                global.pageWithMap.selectMapMarker(global.itemsMan.getSelected<NetDevice>()!.id);
                global.mainBottomSelectedDev = Text(
                  '${global.itemsMan.getSelected<NetDevice>()!.typeName()} #${global.itemsMan.getSelected<NetDevice>()!.id}',
                  textScaleFactor: 1.4,
                );
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(
              visible: widget._cloneItem.typeName() == STD.Name(),
              child: ExpansionPanelList(
                elevation: 2,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isOpenMain[index] = !isExpanded;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Main'),
                      );
                    },
                    body: buildMainSettings(context),
                    isExpanded: _isOpenMain[0],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Coordinates'),
                      );
                    },
                    body: buildCoordSettings(context),
                    isExpanded: _isOpenMain[1],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Radio'),
                      );
                    },
                    body: buildRadioSettings(context),
                    isExpanded: _isOpenMain[2],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Save/Reset settings'),
                      );
                    },
                    body: buildDeviceSettings(context),
                    isExpanded: _isOpenMain[3],
                    canTapOnHeader: true,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget._cloneItem.typeName() == RT.Name(),
              child: ExpansionPanelList(
                elevation: 2,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isOpenRT[index] = !isExpanded;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Main'),
                      );
                    },
                    body: buildMainSettings(context),
                    isExpanded: _isOpenRT[0],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Coordinates'),
                      );
                    },
                    body: buildCoordSettings(context),
                    isExpanded: _isOpenRT[1],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Connected devices'),
                      );
                    },
                    body: buildConnectedDevices(context),
                    isExpanded: _isOpenRT[2],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('External power'),
                      );
                    },
                    body: buildExtPower(context),
                    isExpanded: _isOpenRT[3],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Radio'),
                      );
                    },
                    body: buildRadioSettings(context),
                    isExpanded: _isOpenRT[4],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Power supply'),
                      );
                    },
                    body: buildPowerSupply(context),
                    isExpanded: _isOpenRT[5],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Save/Reset settings'),
                      );
                    },
                    body: buildDeviceSettings(context),
                    isExpanded: _isOpenRT[6],
                    canTapOnHeader: true,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget._cloneItem.typeName() == CSD.Name(),
              child: ExpansionPanelList(
                elevation: 2,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isOpenCSD[index] = !isExpanded;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Main'),
                      );
                    },
                    body: buildMainSettings(context),
                    isExpanded: _isOpenCSD[0],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Coordinates'),
                      );
                    },
                    body: buildCoordSettings(context),
                    isExpanded: _isOpenCSD[1],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Connected devices'),
                      );
                    },
                    body: buildConnectedDevices(context),
                    isExpanded: _isOpenCSD[2],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('External power'),
                      );
                    },
                    body: buildExtPower(context),
                    isExpanded: _isOpenCSD[3],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Radio'),
                      );
                    },
                    body: buildRadioSettings(context),
                    isExpanded: _isOpenCSD[4],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Power supply'),
                      );
                    },
                    body: buildPowerSupply(context),
                    isExpanded: _isOpenCSD[5],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Seismic'),
                      );
                    },
                    body: buildSeismicSettings(context),
                    isExpanded: _isOpenCSD[6],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Save/Reset settings'),
                      );
                    },
                    body: buildDeviceSettings(context),
                    isExpanded: _isOpenCSD[7],
                    canTapOnHeader: true,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget._cloneItem.typeName() == CPD.Name(),
              child: ExpansionPanelList(
                elevation: 2,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isOpenCFU[index] = !isExpanded;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Main'),
                      );
                    },
                    body: buildMainSettings(context),
                    isExpanded: _isOpenCFU[0],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Coordinates'),
                      );
                    },
                    body: buildCoordSettings(context),
                    isExpanded: _isOpenCFU[1],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Connected devices'),
                      );
                    },
                    body: buildConnectedDevices(context),
                    isExpanded: _isOpenCFU[2],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('External power'),
                      );
                    },
                    body: buildExtPower(context),
                    isExpanded: _isOpenCFU[3],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Radio'),
                      );
                    },
                    body: buildRadioSettings(context),
                    isExpanded: _isOpenCFU[4],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Power supply'),
                      );
                    },
                    body: buildPowerSupply(context),
                    isExpanded: _isOpenCFU[5],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Camera'),
                      );
                    },
                    body: buildCameraSettings(context),
                    isExpanded: _isOpenCFU[6],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Save/Reset settings'),
                      );
                    },
                    body: buildDeviceSettings(context),
                    isExpanded: _isOpenCFU[7],
                    canTapOnHeader: true,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget._cloneItem.typeName() == MCD.Name(),
              child: ExpansionPanelList(
                elevation: 2,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isOpenMCD[index] = !isExpanded;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Main'),
                      );
                    },
                    body: buildMainSettings(context),
                    isExpanded: _isOpenMCD[0],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Coordinates'),
                      );
                    },
                    body: buildCoordSettings(context),
                    isExpanded: _isOpenMCD[1],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Power supply'),
                      );
                    },
                    body: buildPowerMCD(context),
                    isExpanded: _isOpenMCD[2],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('MCD'),
                      );
                    },
                    body: buildMCDSettings(context),
                    isExpanded: _isOpenMCD[3],
                    canTapOnHeader: true,
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Save/Reset settings'),
                      );
                    },
                    body: buildDeviceSettings(context),
                    isExpanded: _isOpenMCD[4],
                    canTapOnHeader: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
