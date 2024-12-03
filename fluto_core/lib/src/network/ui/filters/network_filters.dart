import 'package:fluto_core/src/network/infospect_network_call.dart';
import 'package:flutter/material.dart';

class FiltersHandler {
  // final Set<InfospectNetworkCall> _networkCalls;

  // const FiltersHandler({required Set<InfospectNetworkCall> networkCalls}) : _networkCalls = networkCalls;

  static Iterable<InfospectNetworkCall> filterByMethod(String method, Iterable<InfospectNetworkCall> networkCalls) {
    return networkCalls.where((call) => call.method == method).toSet();
  }

  // Method to search network calls by a query
  static Iterable<InfospectNetworkCall> search(String query, Iterable<InfospectNetworkCall> networkCalls) {
    return networkCalls.where((call) {
      final String? url = call.request?.url.toString();
      if (url == null) return false;
      return url.toString().contains(query);
    });
  }

  // Method to filter network calls by status code
  static Iterable<InfospectNetworkCall> filterByStatusCode(
      int statusCode, Iterable<InfospectNetworkCall> networkCalls) {
    return networkCalls.where((call) {
      return call.response?.status == statusCode;
    });
  }

  // Method to filter network calls by status code range
  static Iterable<InfospectNetworkCall> filterByStatus(String status, Iterable<InfospectNetworkCall> networkCalls) {
    return networkCalls.where((call) {
      final String? statusString = call.response?.statusString;
      if (statusString == null) return false;
      return status == 'success' ? statusString.contains('OK') : !statusString.contains('OK');
    });
  }

  // add sort based on the time of the network call
  static Iterable<InfospectNetworkCall> sortByTime(Iterable<InfospectNetworkCall> networkCalls) {
    final list = networkCalls.toList();
    list.sort((a, b) {
      if (a.request == null || b.request == null) return 0;
      return b.request!.time.compareTo(a.request!.time);
    });
    return list;
  }

  // filter by Api type (GET, POST, PUT, DELETE)
  static Iterable<InfospectNetworkCall> filterByApiType(
      Iterable<String> selectedMethods, Iterable<InfospectNetworkCall> networkCalls) {
    return networkCalls.where((call) {
      return selectedMethods.contains(call.request?.method);
    });
  }
}

class NetworkFilters extends ChangeNotifier {
  NetworkFilters({
    required Set<InfospectNetworkCall> networkCalls,
  }) : _networkCalls = networkCalls;

  final Set<InfospectNetworkCall> _networkCalls;

  Set<InfospectNetworkCall> get filteredCalls {
    Iterable<InfospectNetworkCall> calls = Set.from(_networkCalls);

    if (query.isNotEmpty) {
      calls = FiltersHandler.search(query, calls);
    }
    if (_method.isNotEmpty) {
      calls = FiltersHandler.filterByMethod(_method, calls);
    }
    if (_status.isNotEmpty) {
      calls = FiltersHandler.filterByStatus(_status, calls);
    }
    if (_statusCode != -1) {
      calls = FiltersHandler.filterByStatusCode(_statusCode, calls);
    }
    if (selectedMethods.isNotEmpty) {
      calls = FiltersHandler.filterByApiType(selectedMethods, calls);
    }

    return FiltersHandler.sortByTime(calls).toSet();
  }

  void updateNetworkCalls(Set<InfospectNetworkCall> networkCalls) {
    _networkCalls.clear();
    _networkCalls.addAll(networkCalls);
    notifyListeners();
  }

  String _query = '';
  String get query => _query;
  void onQueryChanged(String newQuery) {
    _query = newQuery;
    notifyListeners();
  }

  String _method = '';
  void onMethodChanged(String newMethod) {
    _method = newMethod;
    notifyListeners();
  }

  String _status = '';
  void onStatusChanged(String newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  int _statusCode = -1;
  void onStatusCodeChanged(int newStatusCode) {
    _statusCode = newStatusCode;
    notifyListeners();
  }

  final Set<String> _selectedMethods = <String>{};
  Set<String> get selectedMethods => _selectedMethods;
  void onMethodSelected(String value) {
    _selectedMethods.add(value);
    notifyListeners();
  }

  void onMethodRemoved(String value) {
    _selectedMethods.remove(value);
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _method = '';
    _status = '';
    _statusCode = -1;
    notifyListeners();
  }
}
