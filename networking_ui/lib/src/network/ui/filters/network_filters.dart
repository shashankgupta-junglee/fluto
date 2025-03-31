import 'package:flutter/material.dart';
import '/src/network/infospect_network_call.dart';

/// Handler for filtering network calls based on different criteria
class FiltersHandler {
  /// Filters network calls based on search query
  static Iterable<InfospectNetworkCall> search(
      String query, Iterable<InfospectNetworkCall> networkCalls) {
    if (query.isEmpty) return networkCalls;
    
    return networkCalls.where((call) {
      final url = call.request?.url;
      if (url == null) return false;
      return url.toString().toLowerCase().contains(query.toLowerCase());
    });
  }

  /// Sorts network calls by time (newest first)
  static Iterable<InfospectNetworkCall> sortByTime(
      Iterable<InfospectNetworkCall> networkCalls) {
    final list = networkCalls.toList();
    list.sort((a, b) {
      if (a.request == null || b.request == null) return 0;
      return b.request!.time.compareTo(a.request!.time);
    });
    return list;
  }

  /// Filters network calls by API method type (GET, POST, etc.)
  static Iterable<InfospectNetworkCall> filterByApiType(
      Iterable<String> selectedMethods,
      Iterable<InfospectNetworkCall> networkCalls) {
    if (selectedMethods.isEmpty) return networkCalls;
    
    return networkCalls.where((call) {
      final method = call.request?.method.toString().toUpperCase();
      return selectedMethods.contains(method);
    });
  }
  
  /// Filters network calls by status code ranges (success, error, etc.)
  static Iterable<InfospectNetworkCall> filterByStatusCode(
      String statusCode, Iterable<InfospectNetworkCall> networkCalls) {
    if (statusCode.isEmpty) return networkCalls;
    
    return networkCalls.where((call) {
      final status = call.response?.status ?? -1;
      switch (statusCode.toLowerCase()) {
        case 'success':
          return status >= 200 && status < 300;
        case 'error':
          return status >= 400 || status == -1;
        default:
          return true;
      }
    });
  }
}

/// Manages filtering state and operations for network calls
class NetworkFilters extends ChangeNotifier {
  NetworkFilters({
    required this.networkCallsGetter,
  });

  /// Function to get the current set of network calls
  final ValueGetter<Set<InfospectNetworkCall>> networkCallsGetter;
  
  String _query = '';
  String _statusCode = '';
  final Set<String> _selectedMethods = {};

  /// Current search query
  String get query => _query;
  
  /// Current status code filter
  String get statusCode => _statusCode;
  
  /// Currently selected API methods
  Set<String> get selectedMethods => _selectedMethods;

  /// Gets filtered network calls based on current filters
  Set<InfospectNetworkCall> get filteredCalls {
    // Start with all network calls
    Iterable<InfospectNetworkCall> calls = Set.from(networkCallsGetter.call());
    
    // Apply filters sequentially
    if (_statusCode.isNotEmpty) {
      calls = FiltersHandler.filterByStatusCode(_statusCode, calls);
    }
    
    if (_selectedMethods.isNotEmpty) {
      calls = FiltersHandler.filterByApiType(_selectedMethods, calls);
    }
    
    if (_query.isNotEmpty) {
      calls = FiltersHandler.search(_query, calls);
    }
    
    // Sort by time (newest first)
    calls = FiltersHandler.sortByTime(calls);
    
    return calls.toSet();
  }

  /// Updates the search query
  void onQueryChanged(String newQuery) {
    _query = newQuery;
    notifyListeners();
  }

  /// Updates the status code filter
  void onStatusCodeChanged(String newStatusCode) {
    _statusCode = newStatusCode;
    notifyListeners();
  }

  /// Toggles a method in the selected methods set
  void onMethodSelected(String method) {
    if (_selectedMethods.contains(method)) {
      _selectedMethods.remove(method);
    } else {
      _selectedMethods.add(method);
    }
    notifyListeners();
  }

  /// Removes a method from the selected methods set
  void onMethodRemoved(String method) {
    _selectedMethods.remove(method);
    notifyListeners();
  }

  /// Clears all filters
  void clearFilters() {
    _query = '';
    _statusCode = '';
    _selectedMethods.clear();
    notifyListeners();
  }
}
