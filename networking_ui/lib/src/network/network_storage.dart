import 'infospect_network_call.dart';
import 'package:hive/hive.dart';

class NetworkStorage {
  final FlutoNetworkLazyBox _box;

  NetworkStorage(this._box) {
    init();
  }

  //TODO: Check If this init is required
  Future<void> init() async {
    final futures =
        await Future.wait(_box.keys.map((key) => getNetworkCall(key)));
    final calls = futures.whereType<InfospectNetworkCall>();
    // _networkCall.addAll(calls);

    //TODO: Use Streams for listening data
  }

  Future<void> addNetworkCall(InfospectNetworkCall call) async {
    try {
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
    await _box.clear();
  }
}

class FlutoNetworkLazyBox {
  final LazyBox _box;

  FlutoNetworkLazyBox(this._box);

  Future<void> clear() {
    return _box.clear();
  }

  Future get(key) {
    return _box.get(key);
  }

  Iterable get keys => _box.keys;

  Future<void> put(key, value) {
    return _box.put(key, value);
  }
}
