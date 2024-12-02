import 'dart:async';

import 'package:fluto_core/fluto.dart';
import 'package:fluto_core/src/shared_preference/shared_preference_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'logger/logger_provider.dart';

class FlutoAppRunner {
  static final FlutoAppRunner _instance = FlutoAppRunner._internal();
  late FlutoLoggerProvider _loggerProvider;
  late SharedPreferencesProvider _sharedPreferencesProvider;

  factory FlutoAppRunner() {
    return _instance;
  }

  FlutoAppRunner._internal() {
    _loggerProvider = FlutoLoggerProvider();
    _sharedPreferencesProvider = SharedPreferencesProvider();
  }

  Future<void> runFlutoRunner({
    required Widget child,
  }) async {
    await runZonedGuarded(
      () async {
        BindingBase.debugZoneErrorsAreFatal = true;
        WidgetsFlutterBinding.ensureInitialized();

        try {
          await Hive.initFlutter();

          if (!Hive.isAdapterRegistered(FlutoLogModelAdapter().typeId)) {
            Hive.registerAdapter(FlutoLogModelAdapter());
          }
          if (!Hive.isAdapterRegistered(FlutoLogTypeAdapter().typeId)) {
            Hive.registerAdapter(FlutoLogTypeAdapter());
          }

          BindingBase.debugZoneErrorsAreFatal = false;

          await _loggerProvider.initHive();

          runApp(
              MultiProvider(
              providers: [
                ChangeNotifierProvider.value(
                  value: _loggerProvider,
                ),
                ChangeNotifierProvider.value(
                  value: _sharedPreferencesProvider,
                ),
              ],
              child: child,
            ),
          );
        } catch (error, stackTrace) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'FlutoAppRunner',
              context: ErrorDescription('Failed to initialize application'),
            ),
          );
          rethrow;
        }
      },
      (error, stackTrace) {
        _loggerProvider.insertErrorLog(
          error.toString(),
          error: error,
          stackTrace: stackTrace,
        );
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'FlutoAppRunner',
            context: ErrorDescription('Unhandled error in application zone'),
          ),
        );
      },
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          _loggerProvider.insertPrintLog(line);
          parent.print(zone, line);
        },
      ),
      zoneValues: _loggerProvider.getLogZones,
    );
  }

  FlutoLoggerProvider get loggerProvider => _loggerProvider;
}
