import 'package:flutter/foundation.dart';
import '/src/network/network_storage.dart';
import '/src/network/infospect_network_call.dart';

/// Use case for fetching network calls from storage
class FetchNetworkCallsUseCase {
  /// Constructor for FetchNetworkCallsUseCase
  FetchNetworkCallsUseCase({
    required this.storage,
  });

  /// The network storage router
  final NetworkInspectorRouter storage;
  
  /// Returns a ValueNotifier that listens to changes in network calls
  ValueNotifier<Map<int, InfospectNetworkCall>> get networkCallsNotifier => storage.networkCall;
  
  /// Gets the current set of network calls
  Set<InfospectNetworkCall> getNetworkCalls() {
    return storage.networkCall.value.values.toSet();
  }
  
  /// Adds a listener to the network call notifier
  void addListener(VoidCallback listener) {
    storage.networkCall.addListener(listener);
  }
  
  /// Removes a listener from the network call notifier
  void removeListener(VoidCallback listener) {
    storage.networkCall.removeListener(listener);
  }
}