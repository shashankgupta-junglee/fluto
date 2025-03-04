
import 'infospect_network_call.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

abstract class LazyNetworkBox {
  Iterable<dynamic> get keys;
  Future<void> put(dynamic key, dynamic value);
  Future<dynamic> get(dynamic key);
  Future<void> clear();
}

class NetworkStorage extends ChangeNotifier {
  final LazyNetworkBox _box;

  NetworkStorage(this._box) {
    notifyListeners();
    init();
  }

  Future<void> init() async {
    final futures = await Future.wait(_box.keys.map((key) => getNetworkCall(key)));
    final calls = futures.whereType<InfospectNetworkCall>();
    _networkCall.addAll(calls);
    notifyListeners();
  }

  final Set<InfospectNetworkCall> _networkCall = {};
  Set<InfospectNetworkCall> get networkCall => _networkCall;

  Future<void> addNetworkCall(InfospectNetworkCall call) async {
    try {
      _networkCall.add(call);
      await _box.put(call.hashCode, call.toJson());
    } catch (e) {
      throw Exception("Error adding network call\n$e");
    }
  }

  Future<InfospectNetworkCall?> getNetworkCall(int hashCode) async {
    try {
      final data = await _box.get(hashCode);
      if (data == null) return null;
      return InfospectNetworkCall.fromJson(data);
    } catch (e) {
      throw Exception("Error getting network call\n$e");
    }
  }

  Future<void> clear() async {
    _networkCall.clear();
    await _box.clear();
    notifyListeners();
  }
}

class FlutoNetworkStorage extends NetworkStorage {
  FlutoNetworkStorage({required LazyBox box})
      : super(FlutoNetworkLazyBox(box));

  @override
  Future<void> addNetworkCall(InfospectNetworkCall call) async {
    return super.addNetworkCall(call);
  }
}

class FlutoNetworkLazyBox extends LazyNetworkBox {
  final LazyBox _box;

  FlutoNetworkLazyBox(this._box);

  @override
  Future<void> clear() {
    return _box.clear();
  }

  @override
  Future get(key) {
    return _box.get(key);
  }

  @override
  Iterable get keys => _box.keys;

  @override
  Future<void> put(key, value) {
    return _box.put(key, value);
  }
}
