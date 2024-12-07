import 'dart:async';

import 'package:fluto_core/fluto.dart';
import 'package:fluto_core/src/provider/screen_record_provider.dart';

import 'package:fluto_core/src/provider/supabase_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:networking_ui/networking_ui.dart';
import 'package:provider/provider.dart';
import 'package:unity_message_ui/unity_message_ui.dart';

import 'fluto_network_storage.dart';
import 'logger/logger_provider.dart';

class FlutoAppRunner {
  static final FlutoAppRunner _instance = FlutoAppRunner._internal();
  late FlutoLoggerProvider _loggerProvider;
  late NetworkStorage _networkStorage;
  late UnityMessageStorage unityMessageStorage;
  late SupabaseProvider _supabaseProvider;
  late ScreenRecordProvider _screenRecordProvider;

  factory FlutoAppRunner() {
    return _instance;
  }

  FlutoAppRunner._internal() {
    _loggerProvider = FlutoLoggerProvider();
    _supabaseProvider = SupabaseProvider();
    _screenRecordProvider = ScreenRecordProvider();
  }

  Future<void> _initialize() async {
    final LazyBox box = await Hive.openLazyBox('UnityProvider');
    unityMessageStorage = FlutoUnityMessageStorage(box: box);
    await unityMessageStorage.init();
    UnityMessageInterceptor.init(unityMessageStorage);
  }

  Future<void> runFlutoRunner({
    required Widget child,
    Future<void> Function()? onInit,
    void Function(Object error, StackTrace stack)? onError,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    BindingBase.debugZoneErrorsAreFatal = true;

    await runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        await dotenv.load(fileName: ".env");

        try {
          await _supabaseProvider.initSupabase();
          await Hive.initFlutter();

          if (!Hive.isAdapterRegistered(FlutoLogModelAdapter().typeId)) {
            Hive.registerAdapter(FlutoLogModelAdapter());
          }
          if (!Hive.isAdapterRegistered(FlutoLogTypeAdapter().typeId)) {
            Hive.registerAdapter(FlutoLogTypeAdapter());
          }

          BindingBase.debugZoneErrorsAreFatal = false;
          await _loggerProvider.initHive(
            supabase: _supabaseProvider.supabase,
          );
          await _screenRecordProvider.init(
            supabase: _supabaseProvider.supabase,
          );
          if (onInit != null) {
            await onInit();
          }
          final LazyBox box = await Hive.openLazyBox('NetworkProvider');
          _networkStorage = FlutoNetworkStorage(
              box: box, supabase: _supabaseProvider.supabase);
          await _networkStorage.init();
          NetworkCallInterceptor.init(_networkStorage);

          await _initialize();

          runApp(
            MultiProvider(
              providers: [
                ChangeNotifierProvider.value(
                  value: _loggerProvider,
                ),
                ChangeNotifierProvider.value(
                  value: _supabaseProvider,
                ),
                ChangeNotifierProvider.value(
                  value: _screenRecordProvider,
                ),
              ],
              child: child,
            ),
          );
        } catch (error, stackTrace) {
          onError?.call(error, stackTrace);
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
              context: ErrorDescription('Failed to initialize application'),
            ),
          );
          rethrow;
        }
      },
      (error, stackTrace) {
        onError?.call(error, stackTrace);
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
  NetworkStorage get networkStorage => _networkStorage;
}
