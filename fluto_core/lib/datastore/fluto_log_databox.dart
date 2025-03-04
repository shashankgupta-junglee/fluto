// import 'package:fluto_core/fluto.dart';
// import 'package:hive/hive.dart';
//
// class FlutoLogBoxManager {
//   FlutoLogBoxManager._internal();
//
//   static final FlutoLogBoxManager _instance = FlutoLogBoxManager._internal();
//
//   factory FlutoLogBoxManager() => _instance;
//
//   Box<FlutoLogModel>? _box;
//
//   Future<void> init() async {
//     if (_box == null || !_box!.isOpen) {
//       _box = await Hive.openBox<FlutoLogModel>('flutoLogBox');
//     }
//   }
//
//   Box<FlutoLogModel> get box {
//     if (_box == null || !_box!.isOpen) {
//       throw Exception(
//           'FlutoLogBoxManager is not initialized. Call init() first.');
//     }
//     return _box!;
//   }
//
//   Future<void> close() async {
//     if (_box != null && _box!.isOpen) {
//       await _box!.close();
//       _box = null;
//     }
//   }
// }
