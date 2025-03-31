import 'package:flutter/material.dart';

import 'infospect_network_call.dart';

abstract class NetworkInspectorRouter {
    ValueNotifier<Map<int, InfospectNetworkCall>> get networkCall;
  Future<void> addNetworkCall(InfospectNetworkCall call);
  Future<InfospectNetworkCall?> getNetworkCall(int hashCode);
}

class NetworkInspectorRouterImpl extends NetworkInspectorRouter {
  @override
  ValueNotifier<Map<int, InfospectNetworkCall>> networkCall = ValueNotifier({});

  @override
  Future<void> addNetworkCall(InfospectNetworkCall call) async {
    try {
      networkCall.value[call.hashCode] = call;
    } catch (e) {
      throw Exception("Error adding network call\n$e");
    }
  }

  @override
  Future<InfospectNetworkCall?> getNetworkCall(int hashCode) async {
    try {
      final data = networkCall.value[hashCode];
      if (data == null) return null;
      return data;
    } catch (e) {
      throw Exception("Error getting network call\n$e");
    }
  }
}
