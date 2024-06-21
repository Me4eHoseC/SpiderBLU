import 'app_localizations.dart';

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Flutter i18n';

  @override
  String get settingsPage => 'Настройки';

  @override
  String get mapPage => 'Карта';

  @override
  String get devicesTablePage => 'Список Устройств';

  @override
  String get deviceParametersPage => 'Параметры Устройств';

  @override
  String get imagePage => 'Фото';

  @override
  String get seismicPage => 'Сейсмика';

  @override
  String get scannerPage => 'Сканер';

  @override
  String get protocolPage => 'Протокол';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get language => 'Язык';

  @override
  String get checkBTSTD => 'BT STD';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get remoteBTDevices => 'Обнаруженные BT устройства:';

  @override
  String get selectDevice => 'Выберете устройство';

  @override
  String get checkCOMSTD => 'COM СППУ';

  @override
  String get availableCOMDevices => 'Обнаруженные COM устройства:';

  @override
  String get checkTCPSTD => 'TCP СППУ';

  @override
  String get enterIpv4 => 'Введите IPv4 адрес и порт:';

  @override
  String get port => 'Порт';

  @override
  String get ipv4 => 'IPv4';

  @override
  String get ipv4AddressCanT => 'IPv4 адрес не может быть пустым';

  @override
  String get ipv4EnterCorrect => 'Введите корректный IPv4 адрес';

  @override
  String get portCanT => 'IP порт не может быть пустым';

  @override
  String get portEnterCorrect => 'Введите корректный IP порт';

  @override
  String deviceOffline(Object oldId) {
    return 'Устройство #$oldId выключено';
  }

  @override
  String get markerName => 'Маркер';

  @override
  String get airsName => 'А-ИКД';

  @override
  String get cpdName => 'КФУ';

  @override
  String get csdName => 'КСД';

  @override
  String get mcdName => 'МУК';

  @override
  String get netDeviceName => 'NetDevice';

  @override
  String get rtName => 'РТ';

  @override
  String get stdName => 'СППУ';

  @override
  String deviceInDrop(Object id, Object type) {
    return '$type #$id';
  }

  @override
  String get id => 'ИД:';

  @override
  String get type => 'Тип:';

  @override
  String get dateTime => 'Дата/Время:';

  @override
  String get firmwareVersion => 'Версия прошивки:';

  @override
  String get main => 'Основные';

  @override
  String get coordinates => 'Координаты';

  @override
  String get connectedDevices => 'Подключенные устройства';

  @override
  String get externalPower => 'Внешнее питание';

  @override
  String get radio => 'Радиосеть';

  @override
  String get saveResetSettings => 'Сохранение/Сброс настроек';

  @override
  String get seismic => 'Сейсмика';

  @override
  String get camera => 'Камера';

  @override
  String get powerSupply => 'Источник питания';

  @override
  String get latitude => 'Широта:';

  @override
  String get longitude => 'Долгота:';

  @override
  String get signalStrength => 'Мощность сигнала:';

  @override
  String get allowedHops => 'Разрешенные хопы:';

  @override
  String get unallowedHops => 'Запрещенные хопы:';

  @override
  String get rebroadcastToEveryone => 'Ретранслировать всем:';

  @override
  String get resetRetransmission => 'Сброс ретрансляций';

  @override
  String get saveAlertDialog => 'Сохранить все настройки на выбранном устройстве?';

  @override
  String get buttonAccept => 'Принять';

  @override
  String get buttonCancel => 'Отмена';

  @override
  String get rebootDeviceDialog => 'Перезапустить выбранное устройство?';

  @override
  String get factoryResetDialog => 'Вернуть заводские настройки на выбранном устройстве?';

  @override
  String get rebootDeviceButton => 'Перезапуск устройства';

  @override
  String get saveSettingsButton => 'Сохранить настройки';

  @override
  String get factoryResetButton => 'Возврат к заводским';

  @override
  String get onOffInDev => 'Вкл/выкл внеш. устр.:';

  @override
  String get inDev1 => 'Внеш. устр. 1:';

  @override
  String get inDev2 => 'Внеш. устр. 2:';

  @override
  String get deviceStatus => 'Статус устройства:';

  @override
  String get geophone => 'Геофон:';

  @override
  String get cameraTrap => 'Фотоловушка:';

  @override
  String get safetyCatch => 'Предохранитель:';

  @override
  String get activationDelay => 'Задержка активации:';

  @override
  String activationDelaySec(Object value) {
    return '$value сек.';
  }

  @override
  String get pulseDuration => 'Длительность импульса:';

  @override
  String get turnOnDueBreakline => 'Включение по обрывной:';

  @override
  String get power => 'Питание:';

  @override
  String get voltage => 'Напряжение, V:';

  @override
  String get temperature => 'Температура, °С:';

  @override
  String get human => 'Человек:';

  @override
  String get transport => 'Транспорт:';

  @override
  String get signalSwing => 'Размах сигнала:';

  @override
  String get humanSens => 'Чувствительность по человеку:(25-255)';

  @override
  String get errorSens => 'Чувствительность от 0 до 255';

  @override
  String get transportSens => 'Чувствительность по транспорту:(25-255)';

  @override
  String get criterionFilter => 'Критерийный фильтр:';

  @override
  String get ratioSignal => 'Отношение сигнал транспорта/шум:(5-40)';

  @override
  String get errorRatio => 'Соотношение от 5 до 40';

  @override
  String get recognitionParam => 'Параметры распознавания:';

  @override
  String get interHum => 'Помеха/Человек';

  @override
  String get humTrans => 'Человек/Транспорт';

  @override
  String get errorParam => 'Значение параметров от 0 до 255';

  @override
  String get alarmFiltr => 'Фильтры тревог:';

  @override
  String get singleHum => 'Одиночные \n(человек):';

  @override
  String get serialHum => 'Серийные (человек):';

  @override
  String get singleTrans => 'Одиночные (транспорт):';

  @override
  String get serialTrans => 'Серийные (транспорт):';

  @override
  String get requestError => 'Сначала запросите данные';

  @override
  String serialDrop(Object value) {
    return '$value в ${value}0 сек.';
  }

  @override
  String get oneOfThree => '1 за 3';

  @override
  String get twoOfThree => '2 за 3';

  @override
  String get threeOfThree => '3 за 3';

  @override
  String get twoOfFour => '2 за 4';

  @override
  String get threeOfFour => '3 за 4';

  @override
  String get fourOfFour => '4 за 4';

  @override
  String get idExist => 'Устройство с этим ИД уже нанесено';

  @override
  String get invalidId => 'Неверный ИД \n ИД может быть от 1 до 255';

  @override
  String get stdOnMap => 'СППУ уже нанесен';

  @override
  String alarmFromDevice(Object value) {
    return 'Тревога с устр. #$value:';
  }

  @override
  String get reasonUnknown => 'НЕИЗВЕСТНО';

  @override
  String get reasonHuman => 'ЧЕЛОВЕК';

  @override
  String get reasonAuto => 'ТРАНСПОРТ';

  @override
  String get reasonBat => 'БАТАРЕЯ';

  @override
  String get typeLine1 => 'ОБРЫВНАЯ_1';

  @override
  String get typeLine2 => 'ОБРЫВНАЯ_2';

  @override
  String get typeSeismic => 'СЕЙСМИКА';

  @override
  String get typeTrap => 'ФОТОЛОВУШКА';

  @override
  String get typeRadiation => 'РАДИАЦИЯ';

  @override
  String get typeCatchOFF => 'ПРЕДОХРАНИТЕЛЬ_СНЯТ';

  @override
  String get typePowerTriggered => 'АВТОВЗВЕДЕНИЕ_ВКЛЮЧЕНО';

  @override
  String get typeNo => 'НЕТ';

  @override
  String get sensitivity => 'Чувствительность:';

  @override
  String get photoComp => 'Сжатие фото:';

  @override
  String get priority => 'Приоритет:';

  @override
  String get gps => 'GPS:';

  @override
  String get tresholdIRS => 'Порог ИКД:';

  @override
  String get apply => 'Принять';

  @override
  String get selectAll => 'Выбрать все';

  @override
  String get unselectAll => 'Снять выбор';

  @override
  String get clear => 'Очистить';

  @override
  String get scanButton => 'Скан.';

  @override
  String get mapped => 'На Карте';

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
    return 'Фильтр тревог: Ч$value1, Т$value2';
  }

  @override
  String get applicationLaunched => 'Приложение запущено';

  @override
  String get applicationClosed => 'Приложение закрыто';

  @override
  String get adminMode => 'Режим администратора';

  @override
  String get userMode => 'Режим пользователя';

  @override
  String get netTreeBuilding => 'Построение сетевого дерева';

  @override
  String get netTreeDestroying => 'Разрушение сетевого дерева';

  @override
  String get netTreeChanged => 'Изменение сетевого дерева';

  @override
  String get httpOn => 'HTTP вкл';

  @override
  String get httpOff => 'HTTP выкл';

  @override
  String get httpError => 'HTTP ошибка';

  @override
  String get pollStarted => 'Опрос начат';

  @override
  String get pollFinished => 'Опрос закончен';

  @override
  String variosEventsOperatorNameNotEmpty(Object value) {
    return ' от $value';
  }

  @override
  String variosEventsReportMessageNotEmpty(Object value) {
    return ': \n$value';
  }

  @override
  String variosEventsReport(Object value1, Object value2) {
    return 'Отчёт$value1$value2';
  }

  @override
  String get statusOnline => 'Онлайн';

  @override
  String get statusOffline => 'Оффлайн';

  @override
  String get statusSTDConnected => 'СППУ подключено';

  @override
  String get statusSTDDisconnected => 'СППУ отключено';

  @override
  String get weakBattery => 'Низкий заряд';

  @override
  String get safetyCatchOff => 'Предохранитель снят';

  @override
  String get autoExtPower => 'Авто. внеш. питание';

  @override
  String checkResult(Object value) {
    return 'Проверка результата: $value';
  }

  @override
  String actionsTaken(Object value) {
    return 'Принятые меры: $value';
  }

  @override
  String operatorName(Object value) {
    return 'Имя оператора: $value';
  }

  @override
  String operatorPosition(Object value) {
    return 'Operator position: $value';
  }

  @override
  String alarmEventTypeHuman(Object value) {
    return 'Человек $value';
  }

  @override
  String alarmEventTypeTransport(Object value) {
    return 'Транспорт $value';
  }

  @override
  String numSign(Object value) {
    return '#$value';
  }

  @override
  String alarmEventBreakline(Object value1, Object value2, Object value3) {
    return 'Обрывная #$value1 $value2 ($value3)';
  }

  @override
  String get alarmEventTypeBreakline => 'Обрывная';

  @override
  String get alarmEventSeriesHuman => 'Человек';

  @override
  String get alarmEventSeriesTransport => 'Транспорт';

  @override
  String alarmEventTypeSeries(Object value, Object value1, Object value2) {
    return '$value1 серия $value2 (всего: $value)';
  }

  @override
  String alarmEventTypeLfo(Object value) {
    return 'НЛЦ (Устройства: $value)';
  }

  @override
  String get phototrap => 'Фотоловушка';

  @override
  String alarmEventTypePhototrap(Object value) {
    return 'Фотоловушка (с #$value)';
  }

  @override
  String get alarmEventTypeRadiationLess => 'меньше x1.5';

  @override
  String get alarmEventTypeRadiationMore => 'больше x255';

  @override
  String alarmEventTypeRadiation(Object value1, Object value2) {
    return 'Радиация #$value1 ($value2)';
  }

  @override
  String get commandEventTypeTimeSynchronised => 'Синхр. время';

  @override
  String get commandEventTypeBatteryChanged => 'Замена батареи';

  @override
  String get commandEventTypeExternalPowerOn => 'Внеш. пит. вкл';

  @override
  String get commandEventTypeExternalPowerOff => 'Внеш. пит. выкл';

  @override
  String get commandEventTypeDeviceRebooted => 'Перезапуск';

  @override
  String get commandEventTypeSettingsStored => 'Настройки сохранены';

  @override
  String get commandEventTypeSettingsReset => 'Настройки сброшены';

  @override
  String get commandEventTypeExtPowerSafetyCatchOn => 'Предохранитель вкл';

  @override
  String get commandEventTypeExtPowerSafetyCatchOff => 'Предохранитель выкл';

  @override
  String commandEventOperatorTypeLocalOperatorSent(Object value) {
    return 'Выполнено локальным оператором #$value.';
  }

  @override
  String commandEventOperatorTypeRemoteOperatorSent(Object value) {
    return 'Выполнено удаленным оператором #$value.';
  }

  @override
  String get commandEventOperatorTypeAutomaticsSent => 'Выполнено скриптом.';

  @override
  String get failedToSendCommand => 'Провалена попытка отправки команды.';

  @override
  String commandEventOperatorTypeLocalOperatorFailed(Object value) {
    return 'Попытка локального оператора #$value.';
  }

  @override
  String commandEventOperatorTypeRemoteOperatorFailed(Object value) {
    return 'Попытка скрипта.';
  }

  @override
  String get commandEventOperatorTypeAutomaticsFailed => 'Attempted by script.';

  @override
  String coordinatesEvents(Object value1, Object value2) {
    return 'Координаты: $value1, $value2';
  }

  @override
  String get internalDevicesCommandEventStateBreakline1 => 'Обрывная 1';

  @override
  String get internalDevicesCommandEventStateBreakline2 => 'Обрывная 2';

  @override
  String get internalDevicesCommandEventStatePhototrapBreakline => 'Фотоловушка';

  @override
  String get internalDevicesCommandEventStateGeophone => 'Геофон';

  @override
  String internalDevices(Object value) {
    return 'Внешние устройства: $value';
  }

  @override
  String chanelNumber(Object value) {
    return 'Канал #$value';
  }

  @override
  String get min => 'Мин';

  @override
  String get low => 'Низ';

  @override
  String get med => 'Ср';

  @override
  String get high => 'Выс';

  @override
  String get max => 'Макс';

  @override
  String cameraLightTresholdAndCompression(Object value1, Object value2) {
    return 'Камера: $value1, $value2';
  }

  @override
  String phototrapTriggerID(Object value) {
    return 'Триггер фотоловушки: #$value';
  }

  @override
  String recognitionClasses(Object value) {
    return 'Классы распознования: $value';
  }

  @override
  String get undefined => 'Неопределено';

  @override
  String thresholdNameAndValue(Object value1, Object value2) {
    return '$value1 порог: $value2';
  }

  @override
  String stepThreshold(Object value) {
    return 'Порог шага: $value Hz';
  }

  @override
  String recognCrit(Object value) {
    return 'Распозн. крит.: $value';
  }

  @override
  String get onePerTen => '1 за 10';

  @override
  String get twoPerTwenty => '2 за 20';

  @override
  String get threePerThirty => '3 за 30';

  @override
  String filter(Object value1, Object value2, Object value3, Object value4) {
    return 'Фильтр: Ч$value1 - $value2, Т$value3 - $value4';
  }

  @override
  String snr(Object value) {
    return 'SNR: $value';
  }

  @override
  String get on => 'вкл';

  @override
  String get off => 'выкл';

  @override
  String extPower(Object value) {
    return 'Внеш. пит. $value';
  }

  @override
  String get all => 'Всё';

  @override
  String radTreshold(Object value1, Object value2) {
    return 'Порог рад. $value1: $value2';
  }

  @override
  String get device => 'Устройство';

  @override
  String get alarmPoll => 'Опрос тревог';

  @override
  String get savePoll => 'Опрос сохраненных';

  @override
  String get regularPoll => 'Регулярный опрос';

  @override
  String get initPoll => 'Стартовый опрос';

  @override
  String get stdPoll => 'Опрос СППУ';

  @override
  String get offlinePoll => 'Опрос оффлайн устройств';
}
