import 'package:flutter/material.dart';

import 'infospect_network_call.dart';
// import 'package:hive/hive.dart';

class NetworkStorage {

  ValueNotifier<Map<int, InfospectNetworkCall>> networkCall = ValueNotifier({});

  Set<InfospectNetworkCall> get networkCalls => networkCall.value.values.toSet();


  Future<void> addNetworkCall(InfospectNetworkCall call) async {
    try {
       networkCall.value[call.hashCode] = call;
    } catch (e) {
      throw Exception("Error adding network call\n$e");
    }
  }

  Future<InfospectNetworkCall?> getNetworkCall(int hashCode) async {
    try {
      final data =  networkCall.value[hashCode];
      if (data == null) return null;
      return data;
    } catch (e) {
      throw Exception("Error getting network call\n$e");
    }
  }
}