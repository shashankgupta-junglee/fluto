// import 'package:fluto_core/fluto.dart';
// import 'package:hive/hive.dart';
//
// class FlutoNetworkLazyBox extends LazyNetworkBox {
//   final LazyBox _box;
//
//   FlutoNetworkLazyBox(this._box);
//
//   @override
//   Future<void> clear() {
//     return _box.clear();
//   }
//
//   @override
//   Future get(key) {
//     return _box.get(key);
//   }
//
//   @override
//   Iterable get keys => _box.keys;
//
//   @override
//   Future<void> put(key, value) {
//     return _box.put(key, value);
//   }
// }

// class FlutoUnityStorageLazyBox extends LazyUnityBox {
//   final LazyBox _box;
//
//   FlutoUnityStorageLazyBox(this._box);
//
//   @override
//   Future<void> clear() {
//     return _box.clear();
//   }
//
//   @override
//   Future get(key) {
//     return _box.get(key);
//   }
//
//   @override
//   Iterable get keys => _box.keys;
//
//   @override
//   Future<void> put(key, value) {
//     return _box.put(key, value);
//   }
// }
//
// class FlutoUnityMessageStorage extends UnityMessageStorage {
//   FlutoUnityMessageStorage({
//     required LazyBox box,
//   }) : super(FlutoUnityStorageLazyBox(box));
//
//   @override
//   Future<void> addNetworkCall(UnityMessageModel call) async {
//     return super.addNetworkCall(call);
//   }
// }
//
// class FlutoNetworkStorage extends NetworkStorage {
//   FlutoNetworkStorage({required LazyBox box})
//       : super(FlutoNetworkLazyBox(box));
//
//   @override
//   Future<void> addNetworkCall(InfospectNetworkCall call) async {
//     return super.addNetworkCall(call);
//   }
// }
