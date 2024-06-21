import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter i18n';

  @override
  String get settingsPage => 'Settings';

  @override
  String get mapPage => 'Map';

  @override
  String get devicesTablePage => 'Devices Table';

  @override
  String get deviceParametersPage => 'Device Parameters';

  @override
  String get imagePage => 'Photo';

  @override
  String get seismicPage => 'Seismic';

  @override
  String get scannerPage => 'Scanner';

  @override
  String get protocolPage => 'Protocol';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get checkBTSTD => 'BT STD';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get remoteBTDevices => 'Remote BT devices:';

  @override
  String get selectDevice => 'Select device';

  @override
  String get checkCOMSTD => 'COM STD';

  @override
  String get availableCOMDevices => 'Available COM devices:';

  @override
  String get checkTCPSTD => 'TCP STD';

  @override
  String get enterIpv4 => 'Enter IPv4 address and port:';

  @override
  String get port => 'Port';

  @override
  String get ipv4 => 'IPv4';

  @override
  String get ipv4AddressCanT => 'IPv4 address can\'t be empty';

  @override
  String get ipv4EnterCorrect => 'Enter correct IPv4 address';

  @override
  String get portCanT => 'IP port can\'t be empty';

  @override
  String get portEnterCorrect => 'Enter correct IP port';

  @override
  String deviceOffline(Object oldId) {
    return 'Device #$oldId offline';
  }

  @override
  String get markerName => 'Marker';

  @override
  String get airsName => 'A-IRS';

  @override
  String get cpdName => 'CPD';

  @override
  String get csdName => 'CSD';

  @override
  String get mcdName => 'MCD';

  @override
  String get netDeviceName => 'NetDevice';

  @override
  String get rtName => 'RT';

  @override
  String get stdName => 'STD';

  @override
  String deviceInDrop(Object id, Object type) {
    return '$type #$id';
  }

  @override
  String get id => 'ID';

  @override
  String get type => 'Type:';

  @override
  String get dateTime => 'Date/time:';

  @override
  String get firmwareVersion => 'Firmware version:';

  @override
  String get main => 'Main';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get connectedDevices => 'Connected devices';

  @override
  String get externalPower => 'External power';

  @override
  String get radio => 'Radio';

  @override
  String get saveResetSettings => 'Save/Reset settings';

  @override
  String get seismic => 'Seismic';

  @override
  String get camera => 'Camera';

  @override
  String get powerSupply => 'Power supply';

  @override
  String get latitude => 'Latitude:';

  @override
  String get longitude => 'Longitude:';

  @override
  String get signalStrength => 'Signal strength:';

  @override
  String get allowedHops => 'Allowed hops';

  @override
  String get unallowedHops => 'Unallowed hops';

  @override
  String get rebroadcastToEveryone => 'Retransmit to all:';

  @override
  String get resetRetransmission => 'Reset retransmissions';

  @override
  String get saveAlertDialog => 'Do you really want to save all settings on selected device?';

  @override
  String get buttonAccept => 'Accept';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get rebootDeviceDialog => 'Do you really want to reboot selected device?';

  @override
  String get factoryResetDialog => 'Do you really want to reset selected device to factory settings?';

  @override
  String get rebootDeviceButton => 'Reboot device';

  @override
  String get saveSettingsButton => 'Save settings';

  @override
  String get factoryResetButton => 'Factory reset';

  @override
  String get onOffInDev => 'On/Off in. dev.:';

  @override
  String get inDev1 => 'In. dev. 1:';

  @override
  String get inDev2 => 'In. dev. 2:';

  @override
  String get deviceStatus => 'Device status:';

  @override
  String get geophone => 'Geophone:';

  @override
  String get cameraTrap => 'Camera trap:';

  @override
  String get safetyCatch => 'Safety catch:';

  @override
  String get activationDelay => 'Activation delay:';

  @override
  String activationDelaySec(Object value) {
    return '$value sec.';
  }

  @override
  String get pulseDuration => 'Pulse duration:';

  @override
  String get turnOnDueBreakline => 'Turn on due to breakline:';

  @override
  String get power => 'Power:';

  @override
  String get voltage => 'Voltage, V:';

  @override
  String get temperature => 'Temperature, °С:';

  @override
  String get human => 'Human:';

  @override
  String get transport => 'Transport:';

  @override
  String get signalSwing => 'Signal swing:';

  @override
  String get humanSens => 'Human sensitivity:(25-255)';

  @override
  String get errorSens => 'Sensitivity from 0 to 255';

  @override
  String get transportSens => 'Transport sensitivity:(25-255)';

  @override
  String get criterionFilter => 'Criterion filter:';

  @override
  String get ratioSignal => 'Transport signal to noise ratio:(5-40)';

  @override
  String get errorRatio => 'Ratio from 5 to 40';

  @override
  String get recognitionParam => 'Recognition parameters:';

  @override
  String get interHum => 'Interference/Person';

  @override
  String get humTrans => 'Human/Transport';

  @override
  String get errorParam => 'Parameters from 0 to 255';

  @override
  String get alarmFiltr => 'Alarm filtering:';

  @override
  String get singleHum => 'Single(human):';

  @override
  String get serialHum => 'Series(human):';

  @override
  String get singleTrans => 'Single(transport):';

  @override
  String get serialTrans => 'Series(transport):';

  @override
  String get requestError => 'Request data first';

  @override
  String serialDrop(Object value) {
    return '$value in ${value}0 sec.';
  }

  @override
  String get oneOfThree => '1 of 3';

  @override
  String get twoOfThree => '2 of 3';

  @override
  String get threeOfThree => '3 of 3';

  @override
  String get twoOfFour => '2 of 4';

  @override
  String get threeOfFour => '3 of 4';

  @override
  String get fourOfFour => '4 of 4';

  @override
  String get idExist => 'This ID already exists';

  @override
  String get invalidId => 'Invalid ID \n ID can be from 1 to 255';

  @override
  String get stdOnMap => 'STD is already on the map';

  @override
  String alarmFromDevice(Object value) {
    return 'Alarm from device #$value';
  }

  @override
  String get reasonUnknown => 'UNKNOWN';

  @override
  String get reasonHuman => 'HUMAN';

  @override
  String get reasonAuto => 'AUTO';

  @override
  String get reasonBat => 'BATTERY';

  @override
  String get typeLine1 => 'LINE_1';

  @override
  String get typeLine2 => 'LINE_2';

  @override
  String get typeSeismic => 'SEISMIC';

  @override
  String get typeTrap => 'TRAP';

  @override
  String get typeRadiation => 'RADIATION';

  @override
  String get typeCatchOFF => 'EXT_POWER_SAFETY_CATCH_OFF';

  @override
  String get typePowerTriggered => 'AUTO_EXT_POWER_TRIGGERED';

  @override
  String get typeNo => 'NO';

  @override
  String get sensitivity => 'Sensitivity:';

  @override
  String get photoComp => 'Photo compression:';

  @override
  String get priority => 'Priority:';

  @override
  String get gps => 'GPS:';

  @override
  String get tresholdIRS => 'Treshold IRS:';

  @override
  String get apply => 'Apply';

  @override
  String get selectAll => 'Select All';

  @override
  String get unselectAll => 'Unselect All';

  @override
  String get clear => 'Clear';

  @override
  String get scanButton => 'Scan';

  @override
  String get mapped => 'Mapped';

  @override
  String operatorEventInfoNameAndLastName(Object value) {
    return '$value.';
  }

  @override
  String operatorEventInfoShortName(Object lastname, Object name, Object surname) {
    return '$surname $name$lastname';
  }

  @override
  String operatorEventInfoFullName(Object lastname, Object name, Object surname) {
    return '$surname $name $lastname';
  }

  @override
  String get questionSign => '?';

  @override
  String alarmsFilterSystemEvent(Object value1, Object value2) {
    return 'Alarms filter: H$value1, T$value2';
  }

  @override
  String get applicationLaunched => 'Application launched';

  @override
  String get applicationClosed => 'Application closed';

  @override
  String get adminMode => 'Admin mode';

  @override
  String get userMode => 'User mode';

  @override
  String get netTreeBuilding => 'NetTree building';

  @override
  String get netTreeDestroying => 'NetTree destroying';

  @override
  String get netTreeChanged => 'NetTree changed';

  @override
  String get httpOn => 'HTTP on';

  @override
  String get httpOff => 'HTTP off';

  @override
  String get httpError => 'HTTP error';

  @override
  String get pollStarted => 'Poll started';

  @override
  String get pollFinished => 'Poll finished';

  @override
  String variosEventsOperatorNameNotEmpty(Object value) {
    return ' from $value';
  }

  @override
  String variosEventsReportMessageNotEmpty(Object value) {
    return ': \n$value';
  }

  @override
  String variosEventsReport(Object value1, Object value2) {
    return 'Report$value1$value2';
  }

  @override
  String get statusOnline => 'Online';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusSTDConnected => 'STD connected';

  @override
  String get statusSTDDisconnected => 'STD disconnected';

  @override
  String get weakBattery => 'Weak battery';

  @override
  String get safetyCatchOff => 'Safety catch off';

  @override
  String get autoExtPower => 'Auto ext. power';

  @override
  String checkResult(Object value) {
    return 'Check result: $value';
  }

  @override
  String actionsTaken(Object value) {
    return 'Actions taken: $value';
  }

  @override
  String operatorName(Object value) {
    return 'Operator name: $value';
  }

  @override
  String operatorPosition(Object value) {
    return 'Operator position: $value';
  }

  @override
  String alarmEventTypeHuman(Object value) {
    return 'Human $value';
  }

  @override
  String alarmEventTypeTransport(Object value) {
    return 'Transport $value';
  }

  @override
  String numSign(Object value) {
    return '#$value';
  }

  @override
  String alarmEventBreakline(Object value1, Object value2, Object value3) {
    return 'Breakline #$value1 $value2 ($value3)';
  }

  @override
  String get alarmEventTypeBreakline => 'Breakline';

  @override
  String get alarmEventSeriesHuman => 'Human';

  @override
  String get alarmEventSeriesTransport => 'Transport';

  @override
  String alarmEventTypeSeries(Object value, Object value1, Object value2) {
    return '$value1 series $value2 (total: $value)';
  }

  @override
  String alarmEventTypeLfo(Object value) {
    return 'LFO (Devices: $value)';
  }

  @override
  String get phototrap => 'Phototrap';

  @override
  String alarmEventTypePhototrap(Object value) {
    return 'Phototrap (from #$value)';
  }

  @override
  String get alarmEventTypeRadiationLess => 'less x1.5';

  @override
  String get alarmEventTypeRadiationMore => 'more x255';

  @override
  String alarmEventTypeRadiation(Object value1, Object value2) {
    return 'Radiation #$value1 ($value2)';
  }

  @override
  String get commandEventTypeTimeSynchronised => 'Time synchronize';

  @override
  String get commandEventTypeBatteryChanged => 'Battery change';

  @override
  String get commandEventTypeExternalPowerOn => 'Ext. power on';

  @override
  String get commandEventTypeExternalPowerOff => 'Ext. power off';

  @override
  String get commandEventTypeDeviceRebooted => 'Reboot';

  @override
  String get commandEventTypeSettingsStored => 'Settings stored';

  @override
  String get commandEventTypeSettingsReset => 'Settings reset';

  @override
  String get commandEventTypeExtPowerSafetyCatchOn => 'Safety catch on';

  @override
  String get commandEventTypeExtPowerSafetyCatchOff => 'Safety catch off';

  @override
  String commandEventOperatorTypeLocalOperatorSent(Object value) {
    return 'Executed by local operator #$value.';
  }

  @override
  String commandEventOperatorTypeRemoteOperatorSent(Object value) {
    return 'Executed by remote operator #$value.';
  }

  @override
  String get commandEventOperatorTypeAutomaticsSent => 'Executed by script.';

  @override
  String get failedToSendCommand => 'Failed to send command.';

  @override
  String commandEventOperatorTypeLocalOperatorFailed(Object value) {
    return 'Attempted by local operator #$value.';
  }

  @override
  String commandEventOperatorTypeRemoteOperatorFailed(Object value) {
    return 'Attempted by remote operator #$value.';
  }

  @override
  String get commandEventOperatorTypeAutomaticsFailed => 'Attempted by script.';

  @override
  String coordinatesEvents(Object value1, Object value2) {
    return 'Coordinates: $value1, $value2';
  }

  @override
  String get internalDevicesCommandEventStateBreakline1 => 'Breakline 1';

  @override
  String get internalDevicesCommandEventStateBreakline2 => 'Breakline 2';

  @override
  String get internalDevicesCommandEventStatePhototrapBreakline => 'Phototrap breakline';

  @override
  String get internalDevicesCommandEventStateGeophone => 'Geophone';

  @override
  String internalDevices(Object value) {
    return 'Internal devices: $value';
  }

  @override
  String chanelNumber(Object value) {
    return 'Channel #$value';
  }

  @override
  String get min => 'Min';

  @override
  String get low => 'Low';

  @override
  String get med => 'Med';

  @override
  String get high => 'High';

  @override
  String get max => 'Max';

  @override
  String cameraLightTresholdAndCompression(Object value1, Object value2) {
    return 'Camera: $value1, $value2';
  }

  @override
  String phototrapTriggerID(Object value) {
    return 'Phototrap trigger: #$value';
  }

  @override
  String recognitionClasses(Object value) {
    return 'Recognition classes: $value';
  }

  @override
  String get undefined => 'Undefined';

  @override
  String thresholdNameAndValue(Object value1, Object value2) {
    return '$value1 threshold: $value2';
  }

  @override
  String stepThreshold(Object value) {
    return 'Step threshold: $value Hz';
  }

  @override
  String recognCrit(Object value) {
    return 'Recogn. crit.: $value';
  }

  @override
  String get onePerTen => '1 per 10';

  @override
  String get twoPerTwenty => '2 per 20';

  @override
  String get threePerThirty => '3 per 30';

  @override
  String filter(Object value1, Object value2, Object value3, Object value4) {
    return 'Filter: H$value1 - $value2, T$value3 - $value4';
  }

  @override
  String snr(Object value) {
    return 'SNR: $value';
  }

  @override
  String get on => 'on';

  @override
  String get off => 'off';

  @override
  String extPower(Object value) {
    return 'var ext. power $value';
  }

  @override
  String get all => 'All';

  @override
  String radTreshold(Object value1, Object value2) {
    return 'Rad. threshold. $value1: $value2';
  }

  @override
  String get device => 'Device';

  @override
  String get alarmPoll => 'Alarm poll';

  @override
  String get savePoll => 'Save poll';

  @override
  String get regularPoll => 'Regular poll';

  @override
  String get initPoll => 'Init poll';

  @override
  String get stdPoll => 'STD poll';

  @override
  String get offlinePoll => 'Offline poll';
}
