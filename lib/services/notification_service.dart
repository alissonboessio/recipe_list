import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // singleton
  factory NotificationService() => _instance;

  NotificationService.internal();
  static final NotificationService _instance = NotificationService.internal();

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'backup_channel',
          'Backup Operations',
          channelDescription: 'Shows notifications for backup status',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await FlutterLocalNotificationsPlugin().show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
      title,
      body,
      notificationDetails,
    );
  }
}
