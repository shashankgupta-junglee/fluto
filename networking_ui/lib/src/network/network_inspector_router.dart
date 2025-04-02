import 'dart:async';
import 'infospect_network_call.dart';

abstract class NetworkInspectorRouter {
  Map<int, InfospectNetworkCall> get networkCall;
  Stream<Map<int, InfospectNetworkCall>> get networkCallStream;
  Future<void> addNetworkCall(InfospectNetworkCall call);
}

class NetworkInspectorRouterImpl extends NetworkInspectorRouter {

  final Map<int, InfospectNetworkCall> _networkCall = {};

  final StreamController<Map<int, InfospectNetworkCall>> _streamController = StreamController.broadcast();

  @override
  Stream<Map<int, InfospectNetworkCall>> get networkCallStream => _streamController.stream;

  @override
  Future<void> addNetworkCall(InfospectNetworkCall call) async {
    try {
      _networkCall[call.hashCode] = call;
      _streamController.add(_networkCall);
    } catch (e) {
      throw Exception("Error adding network call\n$e");
    }
  }

  @override
  Map<int, InfospectNetworkCall> get networkCall => _networkCall;
}
