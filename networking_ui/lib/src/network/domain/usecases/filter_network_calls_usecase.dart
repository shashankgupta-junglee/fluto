import '/src/network/infospect_network_call.dart';

/// Use case for filtering network calls based on different criteria
class FilterNetworkCallsUseCase {

  /// Applies all filters to a set of network calls
  Set<InfospectNetworkCall> applyFilters(
    Set<InfospectNetworkCall> calls, {
    required String query,
    required String statusCode,
    required Set<String> selectedMethods,
  }) {
    Iterable<InfospectNetworkCall> filteredCalls = calls;
    
    // Filter by status code
    if (statusCode.isNotEmpty) {
      filteredCalls = filterByStatusCode(statusCode, filteredCalls);
    }
    
    // Filter by method
    if (selectedMethods.isNotEmpty) {
      filteredCalls = filterByApiType(selectedMethods, filteredCalls);
    }
    
    // Filter by search query
    if (query.isNotEmpty) {
      filteredCalls = search(query, filteredCalls);
    }
    
    // Sort by time (newest first)
    filteredCalls = sortByTime(filteredCalls);
    
    return filteredCalls.toSet();
  }
  
  /// Filter network calls by search query
  Iterable<InfospectNetworkCall> search(
      String query, Iterable<InfospectNetworkCall> networkCalls) {
    if (query.isEmpty) return networkCalls;
    
    return networkCalls.where((call) {
      final url = call.request?.url;
      if (url == null) return false;
      return url.toString().toLowerCase().contains(query.toLowerCase());
    });
  }

  /// Sort network calls by time (newest first)
  Iterable<InfospectNetworkCall> sortByTime(
      Iterable<InfospectNetworkCall> networkCalls) {
    final list = networkCalls.toList();
    list.sort((a, b) {
      if (a.request == null || b.request == null) return 0;
      return b.request!.time.compareTo(a.request!.time);
    });
    return list;
  }

  /// Filter network calls by API method type (GET, POST, etc.)
  Iterable<InfospectNetworkCall> filterByApiType(
      Iterable<String> selectedMethods,
      Iterable<InfospectNetworkCall> networkCalls) {
    if (selectedMethods.isEmpty) return networkCalls;
    
    return networkCalls.where((call) {
      final method = call.request?.method.toString().toUpperCase();
      return selectedMethods.contains(method);
    });
  }
  
  /// Filter network calls by status code ranges (success, error, etc.)
  Iterable<InfospectNetworkCall> filterByStatusCode(
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