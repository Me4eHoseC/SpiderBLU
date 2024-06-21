import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// Main application title
  ///
  /// In en, this message translates to:
  /// **'Flutter i18n'**
  String get appTitle;

  /// No description provided for @settingsPage.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPage;

  /// No description provided for @mapPage.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapPage;

  /// No description provided for @devicesTablePage.
  ///
  /// In en, this message translates to:
  /// **'Devices Table'**
  String get devicesTablePage;

  /// No description provided for @deviceParametersPage.
  ///
  /// In en, this message translates to:
  /// **'Device Parameters'**
  String get deviceParametersPage;

  /// No description provided for @imagePage.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get imagePage;

  /// No description provided for @seismicPage.
  ///
  /// In en, this message translates to:
  /// **'Seismic'**
  String get seismicPage;

  /// No description provided for @scannerPage.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get scannerPage;

  /// No description provided for @protocolPage.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get protocolPage;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @checkBTSTD.
  ///
  /// In en, this message translates to:
  /// **'BT STD'**
  String get checkBTSTD;

  /// No description provided for @bluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get bluetooth;

  /// No description provided for @remoteBTDevices.
  ///
  /// In en, this message translates to:
  /// **'Remote BT devices:'**
  String get remoteBTDevices;

  /// No description provided for @selectDevice.
  ///
  /// In en, this message translates to:
  /// **'Select device'**
  String get selectDevice;

  /// No description provided for @checkCOMSTD.
  ///
  /// In en, this message translates to:
  /// **'COM STD'**
  String get checkCOMSTD;

  /// No description provided for @availableCOMDevices.
  ///
  /// In en, this message translates to:
  /// **'Available COM devices:'**
  String get availableCOMDevices;

  /// No description provided for @checkTCPSTD.
  ///
  /// In en, this message translates to:
  /// **'TCP STD'**
  String get checkTCPSTD;

  /// No description provided for @enterIpv4.
  ///
  /// In en, this message translates to:
  /// **'Enter IPv4 address and port:'**
  String get enterIpv4;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @ipv4.
  ///
  /// In en, this message translates to:
  /// **'IPv4'**
  String get ipv4;

  /// No description provided for @ipv4AddressCanT.
  ///
  /// In en, this message translates to:
  /// **'IPv4 address can\'t be empty'**
  String get ipv4AddressCanT;

  /// No description provided for @ipv4EnterCorrect.
  ///
  /// In en, this message translates to:
  /// **'Enter correct IPv4 address'**
  String get ipv4EnterCorrect;

  /// No description provided for @portCanT.
  ///
  /// In en, this message translates to:
  /// **'IP port can\'t be empty'**
  String get portCanT;

  /// No description provided for @portEnterCorrect.
  ///
  /// In en, this message translates to:
  /// **'Enter correct IP port'**
  String get portEnterCorrect;

  /// No description provided for @deviceOffline.
  ///
  /// In en, this message translates to:
  /// **'Device #{oldId} offline'**
  String deviceOffline(Object oldId);

  /// No description provided for @markerName.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get markerName;

  /// No description provided for @airsName.
  ///
  /// In en, this message translates to:
  /// **'A-IRS'**
  String get airsName;

  /// No description provided for @cpdName.
  ///
  /// In en, this message translates to:
  /// **'CPD'**
  String get cpdName;

  /// No description provided for @csdName.
  ///
  /// In en, this message translates to:
  /// **'CSD'**
  String get csdName;

  /// No description provided for @mcdName.
  ///
  /// In en, this message translates to:
  /// **'MCD'**
  String get mcdName;

  /// No description provided for @netDeviceName.
  ///
  /// In en, this message translates to:
  /// **'NetDevice'**
  String get netDeviceName;

  /// No description provided for @rtName.
  ///
  /// In en, this message translates to:
  /// **'RT'**
  String get rtName;

  /// No description provided for @stdName.
  ///
  /// In en, this message translates to:
  /// **'STD'**
  String get stdName;

  /// No description provided for @deviceInDrop.
  ///
  /// In en, this message translates to:
  /// **'{type} #{id}'**
  String deviceInDrop(Object id, Object type);

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type:'**
  String get type;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date/time:'**
  String get dateTime;

  /// No description provided for @firmwareVersion.
  ///
  /// In en, this message translates to:
  /// **'Firmware version:'**
  String get firmwareVersion;

  /// No description provided for @main.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get main;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @connectedDevices.
  ///
  /// In en, this message translates to:
  /// **'Connected devices'**
  String get connectedDevices;

  /// No description provided for @externalPower.
  ///
  /// In en, this message translates to:
  /// **'External power'**
  String get externalPower;

  /// No description provided for @radio.
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get radio;

  /// No description provided for @saveResetSettings.
  ///
  /// In en, this message translates to:
  /// **'Save/Reset settings'**
  String get saveResetSettings;

  /// No description provided for @seismic.
  ///
  /// In en, this message translates to:
  /// **'Seismic'**
  String get seismic;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @powerSupply.
  ///
  /// In en, this message translates to:
  /// **'Power supply'**
  String get powerSupply;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude:'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude:'**
  String get longitude;

  /// No description provided for @signalStrength.
  ///
  /// In en, this message translates to:
  /// **'Signal strength:'**
  String get signalStrength;

  /// No description provided for @allowedHops.
  ///
  /// In en, this message translates to:
  /// **'Allowed hops'**
  String get allowedHops;

  /// No description provided for @unallowedHops.
  ///
  /// In en, this message translates to:
  /// **'Unallowed hops'**
  String get unallowedHops;

  /// No description provided for @rebroadcastToEveryone.
  ///
  /// In en, this message translates to:
  /// **'Retransmit to all:'**
  String get rebroadcastToEveryone;

  /// No description provided for @resetRetransmission.
  ///
  /// In en, this message translates to:
  /// **'Reset retransmissions'**
  String get resetRetransmission;

  /// No description provided for @saveAlertDialog.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to save all settings on selected device?'**
  String get saveAlertDialog;

  /// No description provided for @buttonAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get buttonAccept;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @rebootDeviceDialog.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to reboot selected device?'**
  String get rebootDeviceDialog;

  /// No description provided for @factoryResetDialog.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to reset selected device to factory settings?'**
  String get factoryResetDialog;

  /// No description provided for @rebootDeviceButton.
  ///
  /// In en, this message translates to:
  /// **'Reboot device'**
  String get rebootDeviceButton;

  /// No description provided for @saveSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get saveSettingsButton;

  /// No description provided for @factoryResetButton.
  ///
  /// In en, this message translates to:
  /// **'Factory reset'**
  String get factoryResetButton;

  /// No description provided for @onOffInDev.
  ///
  /// In en, this message translates to:
  /// **'On/Off in. dev.:'**
  String get onOffInDev;

  /// No description provided for @inDev1.
  ///
  /// In en, this message translates to:
  /// **'In. dev. 1:'**
  String get inDev1;

  /// No description provided for @inDev2.
  ///
  /// In en, this message translates to:
  /// **'In. dev. 2:'**
  String get inDev2;

  /// No description provided for @deviceStatus.
  ///
  /// In en, this message translates to:
  /// **'Device status:'**
  String get deviceStatus;

  /// No description provided for @geophone.
  ///
  /// In en, this message translates to:
  /// **'Geophone:'**
  String get geophone;

  /// No description provided for @cameraTrap.
  ///
  /// In en, this message translates to:
  /// **'Camera trap:'**
  String get cameraTrap;

  /// No description provided for @safetyCatch.
  ///
  /// In en, this message translates to:
  /// **'Safety catch:'**
  String get safetyCatch;

  /// No description provided for @activationDelay.
  ///
  /// In en, this message translates to:
  /// **'Activation delay:'**
  String get activationDelay;

  /// No description provided for @activationDelaySec.
  ///
  /// In en, this message translates to:
  /// **'{value} sec.'**
  String activationDelaySec(Object value);

  /// No description provided for @pulseDuration.
  ///
  /// In en, this message translates to:
  /// **'Pulse duration:'**
  String get pulseDuration;

  /// No description provided for @turnOnDueBreakline.
  ///
  /// In en, this message translates to:
  /// **'Turn on due to breakline:'**
  String get turnOnDueBreakline;

  /// No description provided for @power.
  ///
  /// In en, this message translates to:
  /// **'Power:'**
  String get power;

  /// No description provided for @voltage.
  ///
  /// In en, this message translates to:
  /// **'Voltage, V:'**
  String get voltage;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature, °С:'**
  String get temperature;

  /// No description provided for @human.
  ///
  /// In en, this message translates to:
  /// **'Human:'**
  String get human;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport:'**
  String get transport;

  /// No description provided for @signalSwing.
  ///
  /// In en, this message translates to:
  /// **'Signal swing:'**
  String get signalSwing;

  /// No description provided for @humanSens.
  ///
  /// In en, this message translates to:
  /// **'Human sensitivity:(25-255)'**
  String get humanSens;

  /// No description provided for @errorSens.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity from 0 to 255'**
  String get errorSens;

  /// No description provided for @transportSens.
  ///
  /// In en, this message translates to:
  /// **'Transport sensitivity:(25-255)'**
  String get transportSens;

  /// No description provided for @criterionFilter.
  ///
  /// In en, this message translates to:
  /// **'Criterion filter:'**
  String get criterionFilter;

  /// No description provided for @ratioSignal.
  ///
  /// In en, this message translates to:
  /// **'Transport signal to noise ratio:(5-40)'**
  String get ratioSignal;

  /// No description provided for @errorRatio.
  ///
  /// In en, this message translates to:
  /// **'Ratio from 5 to 40'**
  String get errorRatio;

  /// No description provided for @recognitionParam.
  ///
  /// In en, this message translates to:
  /// **'Recognition parameters:'**
  String get recognitionParam;

  /// No description provided for @interHum.
  ///
  /// In en, this message translates to:
  /// **'Interference/Person'**
  String get interHum;

  /// No description provided for @humTrans.
  ///
  /// In en, this message translates to:
  /// **'Human/Transport'**
  String get humTrans;

  /// No description provided for @errorParam.
  ///
  /// In en, this message translates to:
  /// **'Parameters from 0 to 255'**
  String get errorParam;

  /// No description provided for @alarmFiltr.
  ///
  /// In en, this message translates to:
  /// **'Alarm filtering:'**
  String get alarmFiltr;

  /// No description provided for @singleHum.
  ///
  /// In en, this message translates to:
  /// **'Single(human):'**
  String get singleHum;

  /// No description provided for @serialHum.
  ///
  /// In en, this message translates to:
  /// **'Series(human):'**
  String get serialHum;

  /// No description provided for @singleTrans.
  ///
  /// In en, this message translates to:
  /// **'Single(transport):'**
  String get singleTrans;

  /// No description provided for @serialTrans.
  ///
  /// In en, this message translates to:
  /// **'Series(transport):'**
  String get serialTrans;

  /// No description provided for @requestError.
  ///
  /// In en, this message translates to:
  /// **'Request data first'**
  String get requestError;

  /// No description provided for @serialDrop.
  ///
  /// In en, this message translates to:
  /// **'{value} in {value}0 sec.'**
  String serialDrop(Object value);

  /// No description provided for @oneOfThree.
  ///
  /// In en, this message translates to:
  /// **'1 of 3'**
  String get oneOfThree;

  /// No description provided for @twoOfThree.
  ///
  /// In en, this message translates to:
  /// **'2 of 3'**
  String get twoOfThree;

  /// No description provided for @threeOfThree.
  ///
  /// In en, this message translates to:
  /// **'3 of 3'**
  String get threeOfThree;

  /// No description provided for @twoOfFour.
  ///
  /// In en, this message translates to:
  /// **'2 of 4'**
  String get twoOfFour;

  /// No description provided for @threeOfFour.
  ///
  /// In en, this message translates to:
  /// **'3 of 4'**
  String get threeOfFour;

  /// No description provided for @fourOfFour.
  ///
  /// In en, this message translates to:
  /// **'4 of 4'**
  String get fourOfFour;

  /// No description provided for @idExist.
  ///
  /// In en, this message translates to:
  /// **'This ID already exists'**
  String get idExist;

  /// No description provided for @invalidId.
  ///
  /// In en, this message translates to:
  /// **'Invalid ID \n ID can be from 1 to 255'**
  String get invalidId;

  /// No description provided for @stdOnMap.
  ///
  /// In en, this message translates to:
  /// **'STD is already on the map'**
  String get stdOnMap;

  /// No description provided for @alarmFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Alarm from device #{value}'**
  String alarmFromDevice(Object value);

  /// No description provided for @reasonUnknown.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get reasonUnknown;

  /// No description provided for @reasonHuman.
  ///
  /// In en, this message translates to:
  /// **'HUMAN'**
  String get reasonHuman;

  /// No description provided for @reasonAuto.
  ///
  /// In en, this message translates to:
  /// **'AUTO'**
  String get reasonAuto;

  /// No description provided for @reasonBat.
  ///
  /// In en, this message translates to:
  /// **'BATTERY'**
  String get reasonBat;

  /// No description provided for @typeLine1.
  ///
  /// In en, this message translates to:
  /// **'LINE_1'**
  String get typeLine1;

  /// No description provided for @typeLine2.
  ///
  /// In en, this message translates to:
  /// **'LINE_2'**
  String get typeLine2;

  /// No description provided for @typeSeismic.
  ///
  /// In en, this message translates to:
  /// **'SEISMIC'**
  String get typeSeismic;

  /// No description provided for @typeTrap.
  ///
  /// In en, this message translates to:
  /// **'TRAP'**
  String get typeTrap;

  /// No description provided for @typeRadiation.
  ///
  /// In en, this message translates to:
  /// **'RADIATION'**
  String get typeRadiation;

  /// No description provided for @typeCatchOFF.
  ///
  /// In en, this message translates to:
  /// **'EXT_POWER_SAFETY_CATCH_OFF'**
  String get typeCatchOFF;

  /// No description provided for @typePowerTriggered.
  ///
  /// In en, this message translates to:
  /// **'AUTO_EXT_POWER_TRIGGERED'**
  String get typePowerTriggered;

  /// No description provided for @typeNo.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get typeNo;

  /// No description provided for @sensitivity.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity:'**
  String get sensitivity;

  /// No description provided for @photoComp.
  ///
  /// In en, this message translates to:
  /// **'Photo compression:'**
  String get photoComp;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority:'**
  String get priority;

  /// No description provided for @gps.
  ///
  /// In en, this message translates to:
  /// **'GPS:'**
  String get gps;

  /// No description provided for @tresholdIRS.
  ///
  /// In en, this message translates to:
  /// **'Treshold IRS:'**
  String get tresholdIRS;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @unselectAll.
  ///
  /// In en, this message translates to:
  /// **'Unselect All'**
  String get unselectAll;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @scanButton.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanButton;

  /// No description provided for @mapped.
  ///
  /// In en, this message translates to:
  /// **'Mapped'**
  String get mapped;

  /// No description provided for @operatorEventInfoNameAndLastName.
  ///
  /// In en, this message translates to:
  /// **'{value}.'**
  String operatorEventInfoNameAndLastName(Object value);

  /// No description provided for @operatorEventInfoShortName.
  ///
  /// In en, this message translates to:
  /// **'{surname} {name}{lastname}'**
  String operatorEventInfoShortName(Object lastname, Object name, Object surname);

  /// No description provided for @operatorEventInfoFullName.
  ///
  /// In en, this message translates to:
  /// **'{surname} {name} {lastname}'**
  String operatorEventInfoFullName(Object lastname, Object name, Object surname);

  /// No description provided for @questionSign.
  ///
  /// In en, this message translates to:
  /// **'?'**
  String get questionSign;

  /// No description provided for @alarmsFilterSystemEvent.
  ///
  /// In en, this message translates to:
  /// **'Alarms filter: H{value1}, T{value2}'**
  String alarmsFilterSystemEvent(Object value1, Object value2);

  /// No description provided for @applicationLaunched.
  ///
  /// In en, this message translates to:
  /// **'Application launched'**
  String get applicationLaunched;

  /// No description provided for @applicationClosed.
  ///
  /// In en, this message translates to:
  /// **'Application closed'**
  String get applicationClosed;

  /// No description provided for @adminMode.
  ///
  /// In en, this message translates to:
  /// **'Admin mode'**
  String get adminMode;

  /// No description provided for @userMode.
  ///
  /// In en, this message translates to:
  /// **'User mode'**
  String get userMode;

  /// No description provided for @netTreeBuilding.
  ///
  /// In en, this message translates to:
  /// **'NetTree building'**
  String get netTreeBuilding;

  /// No description provided for @netTreeDestroying.
  ///
  /// In en, this message translates to:
  /// **'NetTree destroying'**
  String get netTreeDestroying;

  /// No description provided for @netTreeChanged.
  ///
  /// In en, this message translates to:
  /// **'NetTree changed'**
  String get netTreeChanged;

  /// No description provided for @httpOn.
  ///
  /// In en, this message translates to:
  /// **'HTTP on'**
  String get httpOn;

  /// No description provided for @httpOff.
  ///
  /// In en, this message translates to:
  /// **'HTTP off'**
  String get httpOff;

  /// No description provided for @httpError.
  ///
  /// In en, this message translates to:
  /// **'HTTP error'**
  String get httpError;

  /// No description provided for @pollStarted.
  ///
  /// In en, this message translates to:
  /// **'Poll started'**
  String get pollStarted;

  /// No description provided for @pollFinished.
  ///
  /// In en, this message translates to:
  /// **'Poll finished'**
  String get pollFinished;

  /// No description provided for @variosEventsOperatorNameNotEmpty.
  ///
  /// In en, this message translates to:
  /// **' from {value}'**
  String variosEventsOperatorNameNotEmpty(Object value);

  /// No description provided for @variosEventsReportMessageNotEmpty.
  ///
  /// In en, this message translates to:
  /// **': \n{value}'**
  String variosEventsReportMessageNotEmpty(Object value);

  /// No description provided for @variosEventsReport.
  ///
  /// In en, this message translates to:
  /// **'Report{value1}{value2}'**
  String variosEventsReport(Object value1, Object value2);

  /// No description provided for @statusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get statusOffline;

  /// No description provided for @statusSTDConnected.
  ///
  /// In en, this message translates to:
  /// **'STD connected'**
  String get statusSTDConnected;

  /// No description provided for @statusSTDDisconnected.
  ///
  /// In en, this message translates to:
  /// **'STD disconnected'**
  String get statusSTDDisconnected;

  /// No description provided for @weakBattery.
  ///
  /// In en, this message translates to:
  /// **'Weak battery'**
  String get weakBattery;

  /// No description provided for @safetyCatchOff.
  ///
  /// In en, this message translates to:
  /// **'Safety catch off'**
  String get safetyCatchOff;

  /// No description provided for @autoExtPower.
  ///
  /// In en, this message translates to:
  /// **'Auto ext. power'**
  String get autoExtPower;

  /// No description provided for @checkResult.
  ///
  /// In en, this message translates to:
  /// **'Check result: {value}'**
  String checkResult(Object value);

  /// No description provided for @actionsTaken.
  ///
  /// In en, this message translates to:
  /// **'Actions taken: {value}'**
  String actionsTaken(Object value);

  /// No description provided for @operatorName.
  ///
  /// In en, this message translates to:
  /// **'Operator name: {value}'**
  String operatorName(Object value);

  /// No description provided for @operatorPosition.
  ///
  /// In en, this message translates to:
  /// **'Operator position: {value}'**
  String operatorPosition(Object value);

  /// No description provided for @alarmEventTypeHuman.
  ///
  /// In en, this message translates to:
  /// **'Human {value}'**
  String alarmEventTypeHuman(Object value);

  /// No description provided for @alarmEventTypeTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport {value}'**
  String alarmEventTypeTransport(Object value);

  /// No description provided for @numSign.
  ///
  /// In en, this message translates to:
  /// **'#{value}'**
  String numSign(Object value);

  /// No description provided for @alarmEventBreakline.
  ///
  /// In en, this message translates to:
  /// **'Breakline #{value1} {value2} ({value3})'**
  String alarmEventBreakline(Object value1, Object value2, Object value3);

  /// No description provided for @alarmEventTypeBreakline.
  ///
  /// In en, this message translates to:
  /// **'Breakline'**
  String get alarmEventTypeBreakline;

  /// No description provided for @alarmEventSeriesHuman.
  ///
  /// In en, this message translates to:
  /// **'Human'**
  String get alarmEventSeriesHuman;

  /// No description provided for @alarmEventSeriesTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get alarmEventSeriesTransport;

  /// No description provided for @alarmEventTypeSeries.
  ///
  /// In en, this message translates to:
  /// **'{value1} series {value2} (total: {value})'**
  String alarmEventTypeSeries(Object value, Object value1, Object value2);

  /// No description provided for @alarmEventTypeLfo.
  ///
  /// In en, this message translates to:
  /// **'LFO (Devices: {value})'**
  String alarmEventTypeLfo(Object value);

  /// No description provided for @phototrap.
  ///
  /// In en, this message translates to:
  /// **'Phototrap'**
  String get phototrap;

  /// No description provided for @alarmEventTypePhototrap.
  ///
  /// In en, this message translates to:
  /// **'Phototrap (from #{value})'**
  String alarmEventTypePhototrap(Object value);

  /// No description provided for @alarmEventTypeRadiationLess.
  ///
  /// In en, this message translates to:
  /// **'less x1.5'**
  String get alarmEventTypeRadiationLess;

  /// No description provided for @alarmEventTypeRadiationMore.
  ///
  /// In en, this message translates to:
  /// **'more x255'**
  String get alarmEventTypeRadiationMore;

  /// No description provided for @alarmEventTypeRadiation.
  ///
  /// In en, this message translates to:
  /// **'Radiation #{value1} ({value2})'**
  String alarmEventTypeRadiation(Object value1, Object value2);

  /// No description provided for @commandEventTypeTimeSynchronised.
  ///
  /// In en, this message translates to:
  /// **'Time synchronize'**
  String get commandEventTypeTimeSynchronised;

  /// No description provided for @commandEventTypeBatteryChanged.
  ///
  /// In en, this message translates to:
  /// **'Battery change'**
  String get commandEventTypeBatteryChanged;

  /// No description provided for @commandEventTypeExternalPowerOn.
  ///
  /// In en, this message translates to:
  /// **'Ext. power on'**
  String get commandEventTypeExternalPowerOn;

  /// No description provided for @commandEventTypeExternalPowerOff.
  ///
  /// In en, this message translates to:
  /// **'Ext. power off'**
  String get commandEventTypeExternalPowerOff;

  /// No description provided for @commandEventTypeDeviceRebooted.
  ///
  /// In en, this message translates to:
  /// **'Reboot'**
  String get commandEventTypeDeviceRebooted;

  /// No description provided for @commandEventTypeSettingsStored.
  ///
  /// In en, this message translates to:
  /// **'Settings stored'**
  String get commandEventTypeSettingsStored;

  /// No description provided for @commandEventTypeSettingsReset.
  ///
  /// In en, this message translates to:
  /// **'Settings reset'**
  String get commandEventTypeSettingsReset;

  /// No description provided for @commandEventTypeExtPowerSafetyCatchOn.
  ///
  /// In en, this message translates to:
  /// **'Safety catch on'**
  String get commandEventTypeExtPowerSafetyCatchOn;

  /// No description provided for @commandEventTypeExtPowerSafetyCatchOff.
  ///
  /// In en, this message translates to:
  /// **'Safety catch off'**
  String get commandEventTypeExtPowerSafetyCatchOff;

  /// No description provided for @commandEventOperatorTypeLocalOperatorSent.
  ///
  /// In en, this message translates to:
  /// **'Executed by local operator #{value}.'**
  String commandEventOperatorTypeLocalOperatorSent(Object value);

  /// No description provided for @commandEventOperatorTypeRemoteOperatorSent.
  ///
  /// In en, this message translates to:
  /// **'Executed by remote operator #{value}.'**
  String commandEventOperatorTypeRemoteOperatorSent(Object value);

  /// No description provided for @commandEventOperatorTypeAutomaticsSent.
  ///
  /// In en, this message translates to:
  /// **'Executed by script.'**
  String get commandEventOperatorTypeAutomaticsSent;

  /// No description provided for @failedToSendCommand.
  ///
  /// In en, this message translates to:
  /// **'Failed to send command.'**
  String get failedToSendCommand;

  /// No description provided for @commandEventOperatorTypeLocalOperatorFailed.
  ///
  /// In en, this message translates to:
  /// **'Attempted by local operator #{value}.'**
  String commandEventOperatorTypeLocalOperatorFailed(Object value);

  /// No description provided for @commandEventOperatorTypeRemoteOperatorFailed.
  ///
  /// In en, this message translates to:
  /// **'Attempted by remote operator #{value}.'**
  String commandEventOperatorTypeRemoteOperatorFailed(Object value);

  /// No description provided for @commandEventOperatorTypeAutomaticsFailed.
  ///
  /// In en, this message translates to:
  /// **'Attempted by script.'**
  String get commandEventOperatorTypeAutomaticsFailed;

  /// No description provided for @coordinatesEvents.
  ///
  /// In en, this message translates to:
  /// **'Coordinates: {value1}, {value2}'**
  String coordinatesEvents(Object value1, Object value2);

  /// No description provided for @internalDevicesCommandEventStateBreakline1.
  ///
  /// In en, this message translates to:
  /// **'Breakline 1'**
  String get internalDevicesCommandEventStateBreakline1;

  /// No description provided for @internalDevicesCommandEventStateBreakline2.
  ///
  /// In en, this message translates to:
  /// **'Breakline 2'**
  String get internalDevicesCommandEventStateBreakline2;

  /// No description provided for @internalDevicesCommandEventStatePhototrapBreakline.
  ///
  /// In en, this message translates to:
  /// **'Phototrap breakline'**
  String get internalDevicesCommandEventStatePhototrapBreakline;

  /// No description provided for @internalDevicesCommandEventStateGeophone.
  ///
  /// In en, this message translates to:
  /// **'Geophone'**
  String get internalDevicesCommandEventStateGeophone;

  /// No description provided for @internalDevices.
  ///
  /// In en, this message translates to:
  /// **'Internal devices: {value}'**
  String internalDevices(Object value);

  /// No description provided for @chanelNumber.
  ///
  /// In en, this message translates to:
  /// **'Channel #{value}'**
  String chanelNumber(Object value);

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @med.
  ///
  /// In en, this message translates to:
  /// **'Med'**
  String get med;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @cameraLightTresholdAndCompression.
  ///
  /// In en, this message translates to:
  /// **'Camera: {value1}, {value2}'**
  String cameraLightTresholdAndCompression(Object value1, Object value2);

  /// No description provided for @phototrapTriggerID.
  ///
  /// In en, this message translates to:
  /// **'Phototrap trigger: #{value}'**
  String phototrapTriggerID(Object value);

  /// No description provided for @recognitionClasses.
  ///
  /// In en, this message translates to:
  /// **'Recognition classes: {value}'**
  String recognitionClasses(Object value);

  /// No description provided for @undefined.
  ///
  /// In en, this message translates to:
  /// **'Undefined'**
  String get undefined;

  /// No description provided for @thresholdNameAndValue.
  ///
  /// In en, this message translates to:
  /// **'{value1} threshold: {value2}'**
  String thresholdNameAndValue(Object value1, Object value2);

  /// No description provided for @stepThreshold.
  ///
  /// In en, this message translates to:
  /// **'Step threshold: {value} Hz'**
  String stepThreshold(Object value);

  /// No description provided for @recognCrit.
  ///
  /// In en, this message translates to:
  /// **'Recogn. crit.: {value}'**
  String recognCrit(Object value);

  /// No description provided for @onePerTen.
  ///
  /// In en, this message translates to:
  /// **'1 per 10'**
  String get onePerTen;

  /// No description provided for @twoPerTwenty.
  ///
  /// In en, this message translates to:
  /// **'2 per 20'**
  String get twoPerTwenty;

  /// No description provided for @threePerThirty.
  ///
  /// In en, this message translates to:
  /// **'3 per 30'**
  String get threePerThirty;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter: H{value1} - {value2}, T{value3} - {value4}'**
  String filter(Object value1, Object value2, Object value3, Object value4);

  /// No description provided for @snr.
  ///
  /// In en, this message translates to:
  /// **'SNR: {value}'**
  String snr(Object value);

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get off;

  /// No description provided for @extPower.
  ///
  /// In en, this message translates to:
  /// **'var ext. power {value}'**
  String extPower(Object value);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @radTreshold.
  ///
  /// In en, this message translates to:
  /// **'Rad. threshold. {value1}: {value2}'**
  String radTreshold(Object value1, Object value2);

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @alarmPoll.
  ///
  /// In en, this message translates to:
  /// **'Alarm poll'**
  String get alarmPoll;

  /// No description provided for @savePoll.
  ///
  /// In en, this message translates to:
  /// **'Save poll'**
  String get savePoll;

  /// No description provided for @regularPoll.
  ///
  /// In en, this message translates to:
  /// **'Regular poll'**
  String get regularPoll;

  /// No description provided for @initPoll.
  ///
  /// In en, this message translates to:
  /// **'Init poll'**
  String get initPoll;

  /// No description provided for @stdPoll.
  ///
  /// In en, this message translates to:
  /// **'STD poll'**
  String get stdPoll;

  /// No description provided for @offlinePoll.
  ///
  /// In en, this message translates to:
  /// **'Offline poll'**
  String get offlinePoll;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
