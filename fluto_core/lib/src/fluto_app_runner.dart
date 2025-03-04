// import 'dart:async';
//
// import 'package:fluto_core/fluto.dart';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:provider/provider.dart';
//
// import 'fluto_network_storage.dart';
// import 'logger/logger_provider.dart';
//
// class FlutoAppRunner {
//   // static final FlutoAppRunner _instance = FlutoAppRunner._internal();
//   // late FlutoLoggerProvider _loggerProvider;
//   // late NetworkStorage _networkStorage;
//   // late UnityMessageStorage unityMessageStorage;
//
//   // factory FlutoAppRunner() {
//   //   return _instance;
//   // }
//
//   // FlutoAppRunner._internal() {
//   //   _loggerProvider = FlutoLoggerProvider();
//   // }
//
//   Future<void> _initialize() async {
//     // final LazyBox box = await Hive.openLazyBox('UnityProvider');
//     // unityMessageStorage = FlutoUnityMessageStorage(box: box);
//     // await unityMessageStorage.init();
//     // UnityMessageInterceptor.init(unityMessageStorage);
//   }
//
//   Future<void> runFlutoRunner({
//     required Widget child,
//     Future<void> Function()? onInit,
//     void Function(Object error, StackTrace stack)? onError,
//   }) async {
//     WidgetsFlutterBinding.ensureInitialized();
//     BindingBase.debugZoneErrorsAreFatal = true;
//
//     await runZonedGuarded(
//       () async {
//         WidgetsFlutterBinding.ensureInitialized();
//
//         try {
//
//           await Hive.initFlutter();
//
//           if (!Hive.isAdapterRegistered(FlutoLogModelAdapter().typeId)) {
//             Hive.registerAdapter(FlutoLogModelAdapter());
//           }
//           if (!Hive.isAdapterRegistered(FlutoLogTypeAdapter().typeId)) {
//             Hive.registerAdapter(FlutoLogTypeAdapter());
//           }
//
//           BindingBase.debugZoneErrorsAreFatal = false;
//           await _loggerProvider.initHive(
//
//           );
//
//           if (onInit != null) {
//             await onInit();
//           }
//           // final LazyBox box = await Hive.openLazyBox('NetworkProvider');
//           // _networkStorage = FlutoNetworkStorage(
//           //     box: box);
//           // await _networkStorage.init();
//           // NetworkCallInterceptor.init(_networkStorage);
//
//           await _initialize();
//
//           runApp(
//             MultiProvider(
//               providers: [
//                 ChangeNotifierProvider.value(
//                   value: _loggerProvider,
//                 ),
//               ],
//               child: child,
//             ),
//           );
//         } catch (error, stackTrace) {
//           onError?.call(error, stackTrace);
//           _loggerProvider.insertErrorLog(
//             error.toString(),
//             error: error,
//             stackTrace: stackTrace,
//           );
//           FlutterError.reportError(
//             FlutterErrorDetails(
//               exception: error,
//               stack: stackTrace,
//               library: 'FlutoAppRunner',
//               context: ErrorDescription('Failed to initialize application'),
//             ),
//           );
//           rethrow;
//         }
//       },
//       (error, stackTrace) {
//         onError?.call(error, stackTrace);
//         _loggerProvider.insertErrorLog(
//           error.toString(),
//           error: error,
//           stackTrace: stackTrace,
//         );
//         FlutterError.reportError(
//           FlutterErrorDetails(
//             exception: error,
//             stack: stackTrace,
//             library: 'FlutoAppRunner',
//             context: ErrorDescription('Unhandled error in application zone'),
//           ),
//         );
//       },
//       zoneSpecification: ZoneSpecification(
//         print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
//           _loggerProvider.insertPrintLog(line);
//           parent.print(zone, line);
//         },
//       ),
//       zoneValues: _loggerProvider.getLogZones,
//     );
//   }
//
//   FlutoLoggerProvider get loggerProvider => _loggerProvider;
//   // NetworkStorage get networkStorage => _networkStorage;
// }
