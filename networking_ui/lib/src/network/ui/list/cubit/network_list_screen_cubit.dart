import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:networking_ui/src/network/network_storage.dart';
import '/src/network/infospect_network_call.dart';
import 'dart:io';

/// Data class for AppBar configuration
class AppBarData {
  final double height;
  final bool hasFilters;
  final double platformOffset;
  
  const AppBarData({
    required this.height,
    required this.hasFilters,
    required this.platformOffset,
  });
  
  /// Creates a copy of the current AppBarData with specified fields replaced
  AppBarData copyWith({
    double? height,
    bool? hasFilters,
    double? platformOffset,
  }) {
    return AppBarData(
      height: height ?? this.height,
      hasFilters: hasFilters ?? this.hasFilters,
      platformOffset: platformOffset ?? this.platformOffset,
    );
  }
}

/// State for the Network List Screen
class NetworkListScreenState {
  final String query;
  final String statusCode;
  final Set<String> selectedMethods;
  final Set<InfospectNetworkCall> networkCalls;
  final Set<InfospectNetworkCall> filteredCalls;
  final AppBarData appBarData;
  
  const NetworkListScreenState({
    this.query = '',
    this.statusCode = '',
    this.selectedMethods = const {},
    this.networkCalls = const {},
    this.filteredCalls = const {},
    this.appBarData = const AppBarData(
      height: kToolbarHeight,
      hasFilters: false,
      platformOffset: 0.0,
    ),
  });
  
  /// Creates a copy of the current state with specified fields replaced
  NetworkListScreenState copyWith({
    String? query,
    String? statusCode,
    Set<String>? selectedMethods,
    Set<InfospectNetworkCall>? networkCalls,
    Set<InfospectNetworkCall>? filteredCalls,
    AppBarData? appBarData,
  }) {
    return NetworkListScreenState(
      query: query ?? this.query,
      statusCode: statusCode ?? this.statusCode,
      selectedMethods: selectedMethods ?? this.selectedMethods,
      networkCalls: networkCalls ?? this.networkCalls,
      filteredCalls: filteredCalls ?? this.filteredCalls,
      appBarData: appBarData ?? this.appBarData,
    );
  }
}

/// Cubit for managing Network List Screen state and operations
class NetworkListScreenCubit extends Cubit<NetworkListScreenState> {
  NetworkListScreenCubit({
    required this.storage,
  }) : super(NetworkListScreenState(
          appBarData: AppBarData(
            height: kToolbarHeight,
            hasFilters: false,
            platformOffset: Platform.isMacOS ? 25.0 : 0.0,
          ),
       )) {
    // Initialize with current network calls
    _updateNetworkCalls();
    
    // Set up listener to update when network calls change
    storage.networkCall.addListener(_updateNetworkCalls);
  }

  /// The network storage router
  final NetworkInspectorRouter storage;
  
  @override
  Future<void> close() {
    // Remove listener when cubit is closed
    storage.networkCall.removeListener(_updateNetworkCalls);
    return super.close();
  }
  
  /// Updates the appbar configuration based on current filters
  AppBarData _updateAppBarData(Set<String> selectedMethods) {
    final bool hasFilters = selectedMethods.isNotEmpty;
    final double platformOffset = Platform.isMacOS ? 25.0 : 0.0;
    
    // Calculate height based on platform and filter state
    final double baseHeight = kToolbarHeight;
    final double filterHeight = hasFilters ? 30.0 : 0.0;
    final double paddingHeight = hasFilters ? 10.0 : 0.0;
    
    final double totalHeight = baseHeight + filterHeight + paddingHeight + platformOffset;
    
    return AppBarData(
      height: totalHeight,
      hasFilters: hasFilters,
      platformOffset: platformOffset,
    );
  }
  
  /// Updates the network calls and applies current filters
  void _updateNetworkCalls() {
    final calls = storage.networkCall.value.values.toSet();
    final filteredCalls = _applyFilters(calls);
    
    emit(state.copyWith(
      networkCalls: calls,
      filteredCalls: filteredCalls,
    ));
  }
  
  /// Refreshes network calls from the source (primarily for manual refresh)
  void refreshNetworkCalls() {
    _updateNetworkCalls();
  }
  
  /// Update the search query and refilter results
  void onQueryChanged(String newQuery) {
    final filteredCalls = _applyFilters(
      state.networkCalls,
      query: newQuery,
      statusCode: state.statusCode,
      selectedMethods: state.selectedMethods,
    );
    
    emit(state.copyWith(
      query: newQuery,
      filteredCalls: filteredCalls,
    ));
  }

  /// Update the status code filter and refilter results
  void onStatusCodeChanged(String newStatusCode) {
    final filteredCalls = _applyFilters(
      state.networkCalls,
      query: state.query,
      statusCode: newStatusCode,
      selectedMethods: state.selectedMethods,
    );
    
    emit(state.copyWith(
      statusCode: newStatusCode,
      filteredCalls: filteredCalls,
    ));
  }

  /// Toggle a method in the selected methods set and refilter results
  void onMethodSelected(String method) {
    final Set<String> updatedMethods = Set.from(state.selectedMethods);
    
    if (updatedMethods.contains(method)) {
      updatedMethods.remove(method);
    } else {
      updatedMethods.add(method);
    }
    
    final filteredCalls = _applyFilters(
      state.networkCalls,
      query: state.query,
      statusCode: state.statusCode,
      selectedMethods: updatedMethods,
    );
    
    // Update appbar data based on new filters
    final appBarData = _updateAppBarData(updatedMethods);
    
    emit(state.copyWith(
      selectedMethods: updatedMethods,
      filteredCalls: filteredCalls,
      appBarData: appBarData,
    ));
  }

  /// Remove a method from the selected methods set and refilter results
  void onMethodRemoved(String method) {
    final Set<String> updatedMethods = Set.from(state.selectedMethods);
    updatedMethods.remove(method);
    
    final filteredCalls = _applyFilters(
      state.networkCalls,
      query: state.query,
      statusCode: state.statusCode,
      selectedMethods: updatedMethods,
    );
    
    // Update appbar data based on new filters
    final appBarData = _updateAppBarData(updatedMethods);
    
    emit(state.copyWith(
      selectedMethods: updatedMethods,
      filteredCalls: filteredCalls,
      appBarData: appBarData,
    ));
  }

  /// Clear all filters and refilter results
  void clearFilters() {
    final filteredCalls = _applyFilters(
      state.networkCalls,
      query: '',
      statusCode: '',
      selectedMethods: const {},
    );
    
    // Update appbar data with empty filters
    final appBarData = _updateAppBarData(const {});
    
    emit(state.copyWith(
      query: '',
      statusCode: '',
      selectedMethods: const {},
      filteredCalls: filteredCalls,
      appBarData: appBarData,
    ));
  }
  
  /// Apply filters to network calls
  Set<InfospectNetworkCall> _applyFilters(
    Set<InfospectNetworkCall> calls, {
    String? query,
    String? statusCode,
    Set<String>? selectedMethods,
  }) {
    query ??= state.query;
    statusCode ??= state.statusCode;
    selectedMethods ??= state.selectedMethods;
    
    Iterable<InfospectNetworkCall> filteredCalls = calls;
    
    // Filter by status code
    if (statusCode.isNotEmpty) {
      filteredCalls = _filterByStatusCode(statusCode, filteredCalls);
    }
    
    // Filter by method
    if (selectedMethods.isNotEmpty) {
      filteredCalls = _filterByApiType(selectedMethods, filteredCalls);
    }
    
    // Filter by search query
    if (query.isNotEmpty) {
      filteredCalls = _search(query, filteredCalls);
    }
    
    // Sort by time (newest first)
    filteredCalls = _sortByTime(filteredCalls);
    
    return filteredCalls.toSet();
  }
  
  /// Filter network calls by search query
  Iterable<InfospectNetworkCall> _search(
      String query, Iterable<InfospectNetworkCall> networkCalls) {
    if (query.isEmpty) return networkCalls;
    
    return networkCalls.where((call) {
      final url = call.request?.url;
      if (url == null) return false;
      return url.toString().toLowerCase().contains(query.toLowerCase());
    });
  }

  /// Sort network calls by time (newest first)
  Iterable<InfospectNetworkCall> _sortByTime(
      Iterable<InfospectNetworkCall> networkCalls) {
    final list = networkCalls.toList();
    list.sort((a, b) {
      if (a.request == null || b.request == null) return 0;
      return b.request!.time.compareTo(a.request!.time);
    });
    return list;
  }

  /// Filter network calls by API method type (GET, POST, etc.)
  Iterable<InfospectNetworkCall> _filterByApiType(
      Iterable<String> selectedMethods,
      Iterable<InfospectNetworkCall> networkCalls) {
    if (selectedMethods.isEmpty) return networkCalls;
    
    return networkCalls.where((call) {
      final method = call.request?.method.toString().toUpperCase();
      return selectedMethods.contains(method);
    });
  }
  
  /// Filter network calls by status code ranges (success, error, etc.)
  Iterable<InfospectNetworkCall> _filterByStatusCode(
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