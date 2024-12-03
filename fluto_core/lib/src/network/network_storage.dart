import 'package:fluto_core/src/network/infospect_network_call.dart';
import 'package:hive/hive.dart';

part 'network_storage_keys.dart';

class HiveValue<T> {
  final String key;
  final LazyBox _box;
  final dynamic Function(T value)? toJson;
  final T Function(dynamic value)? fromJson;

  HiveValue(
    this.key,
    this._box, {
    this.toJson,
    this.fromJson,
  });

  Future<T> get value async => fromJson?.call(await _box.get(key)) as T;
  Future<void> setValue(T value) {
    try {
      return _box.put(key, toJson?.call(value));
    } catch (e) {
      throw Exception("Error setting value for key: $key\n$e");
    }
  }
}

class NetworkStorage {
  final LazyBox _box;

  const NetworkStorage(this._box);

  HiveValue<Iterable<InfospectNetworkCall>> get networkCall {
    return HiveValue<Iterable<InfospectNetworkCall>>(
      _NetworkStorageKeys.network,
      _box,
      toJson: (value) => value.map((e) => e.toJson()).toList(),
      fromJson: (value) => (value as List).map((e) => InfospectNetworkCall.fromJson(e)),
    );
  }
}
