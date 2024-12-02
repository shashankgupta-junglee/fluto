import 'package:fluto_core/fluto.dart';
import 'package:flutter/material.dart';

extension FlutoExtension on FlutoLogModel {
  String get getFormattedLogTime {
    return '${logTime.year}-${logTime.month.toString().padLeft(2, '0')}-${logTime.day.toString().padLeft(2, '0')} '
        '${(logTime.hour % 12 == 0 ? 12 : logTime.hour % 12).toString().padLeft(2, '0')}:${logTime.minute.toString().padLeft(2, '0')}:${logTime.second.toString().padLeft(2, '0')} '
        '${logTime.hour < 12 ? 'AM' : 'PM'}';
  }
}

extension StackTraceFormatter on StackTrace {
  String get getFormattedError {
    return toString().split('\n').take(5).join('\n');
  }
}

extension StringExtensions on String {
  String get camelCase {
    return this[0].toUpperCase() + substring(1);
  }
}

extension DatetimeRangeExt on DateTimeRange? {
  bool inRange({required DateTime dateTime}) {
    final isDateMatch = this == null ||
        (dateTime.isAfter(this!.start) && dateTime.isBefore(this!.end));
    return isDateMatch;
  }

  String get dateRangeString {
    if (this == null) {
      return "No range selected";
    }
    String formatDateTime(DateTime date) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} '
          '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
    }

    return '${formatDateTime(this!.start)} - ${formatDateTime(this!.end)}';
  }
}
