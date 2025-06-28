import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';
import 'package:medication_reminder/helpers/database_helper.dart';
import 'package:medication_reminder/models/dose_history.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Define a high-importance channel for Android
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'medicine_channel_id', // id must match when scheduling
    'Medicine Reminders', // title
    description: 'Channel for medicine reminder notifications',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  Future<void> init() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    // Create a high-importance notification channel (Android 8+)
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Create the channel if it doesn’t already exist
      await androidPlugin.createNotificationChannel(channel);

      // We rely on permission_handler to request POST_NOTIFICATIONS at runtime (see main.dart).
    }
    // Handle notification action buttons
  Future<void> _handleNotificationResponse(NotificationResponse response) async {
    try {
      final payload = response.payload;
      if (payload == null) return;
      final Map<String, dynamic> data = jsonDecode(payload);
      final int medicineId = data['medicineId'];
      final String title = data['title'];
      final String body = data['body'];

      switch (response.actionId) {
        case 'TAKEN':
          // Record dose in DB
          await DatabaseHelper().addDoseRecord(
            DoseHistory(medicineId: medicineId, takenAt: DateTime.now()),
          );
          break;
        case 'SNOOZE':
          // Schedule a one-off notification 10 minutes later
          final int newId = response.id + 900000; // ensure uniqueness
          final tz.TZDateTime snoozeTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 10));
          await flutterLocalNotificationsPlugin.zonedSchedule(
            newId,
            title,
            body,
            snoozeTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'medicine_channel_id',
                'Medicine Reminders',
                channelDescription: 'Channel for medicine reminder notifications',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true,
          );
          break;
      }
    } catch (_) {
      // silently ignore malformed payloads
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleDailyNotification({required int id, required String title, required String body, required TimeOfDay time}) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_channel_id',
          'Medicine Reminders',
          channelDescription: 'Channel for medicine reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          actions: const [
            AndroidNotificationAction('TAKEN', 'تم تناولها', showsUserInterface: true, cancelNotification: true),
            AndroidNotificationAction('SNOOZE', 'غفوة 10 دقائق', showsUserInterface: true),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: jsonEncode({'medicineId': id ~/ 1000, 'title': title, 'body': body}),
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}