import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Quote Pool
  static final List<String> _quotes = [
    "Take a deep breath. Today is for your peace.",
    "Before the world asks anything of you, give something to yourself.",
    "Your mental health is your superpower.",
    "Slow down — your soul deserves gentleness.",
    "Today, choose calm over chaos.",
    "A peaceful mind builds a powerful life.",
    "You are allowed to rest. You are allowed to heal.",
    "Begin today with kindness toward yourself.",
    "Your well-being is not optional — it’s essential.",
    "Make time for your heart before time runs out."
  ];

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS settings (default permissions false, request later)
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> requestPermissions() async {
     await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
     await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleDailyNotification() async {
    await cancelNotifications(); // Clear any existing to avoid duplicates

    final String quote = _quotes[Random().nextInt(_quotes.length)];

    await _notificationsPlugin.zonedSchedule(
      0, // ID
      'Good Morning 🌞',
      quote,
      _nextInstanceOfSevenAM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mindnest_daily_channel',
          'Daily Mindfulness',
          channelDescription: 'Daily inspirational quotes for mindfulness',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Recurring daily at time
    );

    if (kDebugMode) {
      print("Notification scheduled for 7:00 AM daily: $quote");
    }
  }

  static tz.TZDateTime _nextInstanceOfSevenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 7);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> cancelNotifications() async {
    await _notificationsPlugin.cancelAll();
     if (kDebugMode) {
      print("All notifications cancelled");
    }
  }
}
