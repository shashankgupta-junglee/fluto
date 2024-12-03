import 'package:fluto_core/src/network/infospect_network_call.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'network_storage.dart';
import 'package:flutter/foundation.dart';

class NetworkProvider extends ChangeNotifier {
  NetworkProvider({required this.storage}) {}

  static Future<NetworkProvider> init() async {
    await Hive.initFlutter();
    final LazyBox box = await Hive.openLazyBox('NetworkProvider');
    final NetworkStorage storage = NetworkStorage(box);
    final NetworkProvider provider = NetworkProvider(storage: storage);
    return provider;
  }

  final NetworkStorage storage;

  final Set<InfospectNetworkCall> _networkCalls = {};
  Set<InfospectNetworkCall> get networkCalls => _networkCalls;

  Future<void> loadPreviousCalls() async {
    _networkCalls.addAll(await storage.networkCall.value);
    notifyListeners();
  }

  void addCall(InfospectNetworkCall call) {
    _networkCalls.add(call);
    storage.networkCall.setValue(_networkCalls);
    notifyListeners();
  }

  void removeCall(InfospectNetworkCall call) {
    _networkCalls.remove(call);
    storage.networkCall.setValue(_networkCalls);
    notifyListeners();
  }
}
