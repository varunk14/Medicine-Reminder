import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeUtils {
  /// Formats hour and minute into 12-hour format (e.g., "9:00 AM")
  static String formatTime(int hour, int minute) {
    final time = TimeOfDay(hour: hour, minute: minute);
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Converts TimeOfDay to minutes since midnight for sorting
  static int timeToMinutes(int hour, int minute) {
    return hour * 60 + minute;
  }

  /// Gets the next occurrence of the given time
  /// If the time has already passed today, returns tomorrow's date
  static DateTime getNextOccurrence(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Formats a DateTime to a readable string
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
  }
}
