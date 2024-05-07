import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'global.dart' as global;

class LocalNotificationService {
  LocalNotificationService();
  final _localNotificationService = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings = InitializationSettings(android: androidInitializationSettings, iOS: null);

    await _localNotificationService.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        print('onDidReceiveNotificationResponse');
        print('notification(${notificationResponse.id}) action tapped: '
            '${notificationResponse.actionId} with'
            ' payload: ${notificationResponse.payload}');
        if (notificationResponse.actionId == 'yes_action'){
          global.pageWithMap.updateBottom(int.parse(notificationResponse.payload!));
          global.devicesTablePage.ref();
        }
      },
    );
  }

  Future<NotificationDetails> _notificationDetails() async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'description',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      actions: <AndroidNotificationAction>[
      AndroidNotificationAction(
        'yes_action', // ID of the action
        'Skip', // Label of the action
        showsUserInterface: true,
      ),
    ],
    );
    return const NotificationDetails(
      android: androidNotificationDetails,
      iOS: null,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required int payload,
  }) async {
    final details = await _notificationDetails();
    await _localNotificationService.show(id, title, body, details, payload: payload.toString());
  }

  void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
    print('id $id');
  }

  void onSelectNotification(String? payload) {
    print('payload $payload');
  }
}
