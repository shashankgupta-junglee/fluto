import 'dart:async';
import 'dart:developer';
import 'package:fluto_core/src/extension/fluto_log_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fluto_core/src/model/fluto_log_model.dart';
import 'package:fluto_core/src/model/fluto_log_type.dart';

class FlutoLoggerProvider with ChangeNotifier {
  static const String _hiveBoxName = 'fluto_logs';
  Box<FlutoLogModel>? _logBox;
  List<FlutoLogModel> _localLogData = [];
  List<FlutoLogModel> get localLogData => List.unmodifiable(_localLogData);
  Timer? _debounce;
  DateTimeRange? dateTimeRange;

  Future<void> initHive() async {
    _logBox = await Hive.openBox<FlutoLogModel>(_hiveBoxName);
    syncLocalLogs();
  }

  void onDateRangeChange(DateTimeRange range, {String message = ""}) {
    dateTimeRange = range;
    onSearchLogs(
      dateTime: range,
      logMessage: message,
    );
    notifyListeners();
  }

  void clearDateRange({String logMessage = ""}) {
    _localLogData = [..._localLogData].map(
      (element) {
        bool isMessageMatch = element.logMessage.contains(logMessage);
        if (element.logType == FlutoLogType.error.toString()) {
          isMessageMatch = isMessageMatch &&
              ((element.stackTraceString ?? "").contains(logMessage) ||
                  (element.errorString ?? "").contains(logMessage));
        }

        return element.copyWith(
          canShow: isMessageMatch,
        );
      },
    ).toList();
    dateTimeRange = null;
    notifyListeners();
  }

  void clearSearch() {
    _localLogData = [..._localLogData].map(
      (element) {
        final isDateMatch = dateTimeRange.inRange(
          dateTime: element.logTime,
        );

        return element.copyWith(
          canShow: isDateMatch,
        );
      },
    ).toList();
    notifyListeners();
  }

  void onSearchLogs({
    String logMessage = "",
    DateTimeRange? dateTime,
  }) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      filterLogs(
        logMessage: logMessage,
      );
    });
  }

  void filterLogs({String logMessage = ""}) {
    _localLogData = [..._localLogData].map(
      (element) {
        bool isMessageMatch = element.logMessage.contains(logMessage);
        if (element.logType == FlutoLogType.error.toString()) {
          isMessageMatch = isMessageMatch &&
              ((element.stackTraceString ?? "").contains(logMessage) ||
                  (element.errorString ?? "").contains(logMessage));
        }
        final isDateMatch = dateTimeRange.inRange(dateTime: element.logTime);
        return element.copyWith(
          canShow: isMessageMatch && isDateMatch,
        );
      },
    ).toList();
    notifyListeners();
  }

  void syncLocalLogs() {
    _localLogData = (_logBox?.values ?? []).toList().cast<FlutoLogModel>();
    notifyListeners();
  }

  Future<void> _insertLog(
    String message, {
    required FlutoLogType type,
    Object? error,
    StackTrace? stackTrace,
    bool printLog = true,
  }) async {
    final logEntry = FlutoLogModel(
      logMessage: message,
      logType: type.name,
      logTime: DateTime.now(),
      errorString: error?.toString() ?? '',
      stackTraceString: stackTrace?.getFormattedError ?? '',
    );

    await _logBox?.add(logEntry);
    if (printLog) {
      log(message, name: type.name, error: error, stackTrace: stackTrace);
    }
  }

  Future<void> insertDebugLog(String message) async {
    await _insertLog(message, type: FlutoLogType.debug);
  }

  Future<void> insertInfoLog(String message) async {
    await _insertLog(message, type: FlutoLogType.info);
  }

  Future<void> insertWarningLog(String message) async {
    await _insertLog(message, type: FlutoLogType.warning);
  }

  Future<void> insertErrorLog(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) async {
    final formattedStackTrace =
        stackTrace?.toString().split('\n').take(5).join('\n') ?? '';
    final errorMessage = "Error: $error\nStackTrace:\n$formattedStackTrace";
    await _insertLog(
      errorMessage,
      type: FlutoLogType.error,
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> insertPrintLog(String message) async {
    await _insertLog(
      message,
      type: FlutoLogType.print,
      printLog: false,
    );
  }

  Future<void> clearLogs({FlutoLogType? type}) async {
    if (type == null) {
      await _logBox?.clear();
    } else {
      final keysToDelete = (_logBox?.keys ?? [])
          .where((key) => _logBox?.get(key)?.logType == type.name)
          .toList();
      for (final key in keysToDelete) {
        await _logBox?.delete(key);
      }
    }
    syncLocalLogs();
  }

  List<FlutoLogModel> getAllLogs({FlutoLogType logType = FlutoLogType.debug}) {
    return _localLogData
        .where(
          (element) => element.logType == logType.name,
        )
        .toList();
  }

  Map<Object?, Object?>? get getLogZones => {
        #logDebug: (
          String message, {
          Object? error,
          StackTrace? stackTrace,
        }) {
          insertDebugLog(message);
        },
        #logInfo: (
          String message, {
          Object? error,
          StackTrace? stackTrace,
        }) {
          insertInfoLog(message);
        },
        #logWarning: (
          String message, {
          Object? error,
          StackTrace? stackTrace,
        }) {
          insertWarningLog(message);
        },
        #logError: (
          String message, {
          Object? error,
          StackTrace? stackTrace,
        }) {
          insertErrorLog(
            message,
            error: error,
            stackTrace: stackTrace,
          );
        },
      };
}
