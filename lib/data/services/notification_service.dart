import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../../core/utils/time_utils.dart';
import '../models/medicine.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    _isInitialized = true;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Schedule notification(s) for a medicine
  /// For daily medicines, schedules one notification.
  /// For specific days, schedules one notification per selected day.
  Future<void> scheduleMedicineReminder(Medicine medicine) async {
    // Android notification details
    const androidDetails = AndroidNotificationDetails(
      'medicine_reminder_channel',
      'Medicine Reminders',
      channelDescription: 'Notifications for medicine reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (medicine.isDaily) {
      // Daily reminder - use time-based matching
      final scheduledTime = TimeUtils.getNextOccurrence(medicine.hour, medicine.minute);
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _notifications.zonedSchedule(
        medicine.notificationId,
        'Medicine Reminder',
        'Time to take ${medicine.name} - ${medicine.dosage}',
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: medicine.id,
      );

      debugPrint(
        'Scheduled daily notification for ${medicine.name} at ${TimeUtils.formatTime(medicine.hour, medicine.minute)}',
      );
    } else {
      // Specific days reminder - schedule one notification per day
      for (final day in medicine.selectedDays) {
        final scheduledTime = _getNextOccurrenceForDay(
          medicine.hour,
          medicine.minute,
          day,
        );
        final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

        // Create unique notification ID for each day
        final notificationId = _getNotificationIdForDay(medicine, day);

        await _notifications.zonedSchedule(
          notificationId,
          'Medicine Reminder',
          'Time to take ${medicine.name} - ${medicine.dosage}',
          tzScheduledTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: medicine.id,
        );

        final dayName = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day];
        debugPrint(
          'Scheduled notification for ${medicine.name} on $dayName at ${TimeUtils.formatTime(medicine.hour, medicine.minute)}',
        );
      }
    }
  }

  /// Get next occurrence for a specific day of week
  DateTime _getNextOccurrenceForDay(int hour, int minute, int targetDay) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // Find the next occurrence of the target day
    while (scheduledDate.weekday != targetDay || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Generate unique notification ID for a specific day
  int _getNotificationIdForDay(Medicine medicine, int day) {
    // Combine medicine ID hash with day to create unique ID
    return (medicine.id.hashCode + day * 1000).abs() % 2147483647;
  }

  /// Cancel a specific medicine reminder
  /// Cancels all notifications for the medicine (daily or per-day)
  Future<void> cancelMedicineReminder(Medicine medicine) async {
    // Cancel the main notification ID (for daily reminders)
    await _notifications.cancel(medicine.notificationId);

    // Cancel all day-specific notifications (for specific days reminders)
    for (int day = 1; day <= 7; day++) {
      final notificationId = _getNotificationIdForDay(medicine, day);
      await _notifications.cancel(notificationId);
    }

    debugPrint('Cancelled all notifications for ${medicine.name}');
  }

  /// Cancel all notifications
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    debugPrint('Cancelled all notifications');
  }

  /// Reschedule all medicine reminders
  Future<void> rescheduleAllReminders(List<Medicine> medicines) async {
    await cancelAllReminders();
    for (final medicine in medicines) {
      if (medicine.isActive) {
        await scheduleMedicineReminder(medicine);
      }
    }
  }

  /// Show an immediate notification (for testing)
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'medicine_reminder_channel',
      'Medicine Reminders',
      channelDescription: 'Notifications for medicine reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'Test Notification',
      'This is a test notification from Medicine Reminder',
      notificationDetails,
    );
  }
}
