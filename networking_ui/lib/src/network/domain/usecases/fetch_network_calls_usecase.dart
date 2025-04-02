import 'dart:async';
import '../../network_inspector_router.dart';
import '/src/network/infospect_network_call.dart';

/// Use case for fetching network calls from storage
class FetchNetworkCallsUseCase {
  /// Constructor for FetchNetworkCallsUseCase
  FetchNetworkCallsUseCase({
    required NetworkInspectorRouter router,
  }) : _router = router;

  /// The network storage router
  final NetworkInspectorRouter _router;
  
  /// Returns a stream of network calls
  Stream<Map<int, InfospectNetworkCall>> get networkCallsStream => _router.networkCallStream;
  
  /// Gets the current set of network calls
  Set<InfospectNetworkCall> getNetworkCalls() {
    return _router.networkCall.values.toSet();
  }
}