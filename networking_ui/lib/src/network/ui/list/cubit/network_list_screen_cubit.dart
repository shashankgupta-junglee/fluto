import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:networking_ui/src/network/domain/usecases/app_bar_configuration_usecase.dart';
import 'package:networking_ui/src/network/domain/usecases/fetch_network_calls_usecase.dart';
import 'package:networking_ui/src/network/domain/usecases/filter_network_calls_usecase.dart';
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
    required NetworkInspectorRouter storage,
  }) : _fetchNetworkCallsUseCase = FetchNetworkCallsUseCase(storage: storage),
       _filterNetworkCallsUseCase = FilterNetworkCallsUseCase(),
       _appBarConfigurationUseCase = AppBarConfigurationUseCase(),
       super(NetworkListScreenState(
         appBarData: AppBarConfigurationUseCase().getInitialAppBarData(),
       )) {
    // Initialize with current network calls
    _updateNetworkCalls();
    
    // Set up listener to update when network calls change
    _fetchNetworkCallsUseCase.addListener(_updateNetworkCalls);
  }
  
  /// Use case for fetching network calls
  final FetchNetworkCallsUseCase _fetchNetworkCallsUseCase;
  
  /// Use case for filtering network calls
  final FilterNetworkCallsUseCase _filterNetworkCallsUseCase;
  
  /// Use case for app bar configuration
  final AppBarConfigurationUseCase _appBarConfigurationUseCase;
  
  @override
  Future<void> close() {
    // Remove listener when cubit is closed
    _fetchNetworkCallsUseCase.removeListener(_updateNetworkCalls);
    return super.close();
  }
  
  /// Updates the network calls and applies current filters
  void _updateNetworkCalls() {
    final calls = _fetchNetworkCallsUseCase.getNetworkCalls();
    final filteredCalls = _filterNetworkCallsUseCase.applyFilters(
      calls,
      query: state.query,
      statusCode: state.statusCode,
      selectedMethods: state.selectedMethods,
    );
    
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
    final filteredCalls = _filterNetworkCallsUseCase.applyFilters(
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
    final filteredCalls = _filterNetworkCallsUseCase.applyFilters(
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
    
    final filteredCalls = _filterNetworkCallsUseCase.applyFilters(
      state.networkCalls,
      query: state.query,
      statusCode: state.statusCode,
      selectedMethods: updatedMethods,
    );
    
    // Update appbar data based on new filters
    final appBarData = _appBarConfigurationUseCase.updateAppBarData(updatedMethods);
    
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
    
    final filteredCalls = _filterNetworkCallsUseCase.applyFilters(
      state.networkCalls,
      query: state.query,
      statusCode: state.statusCode,
      selectedMethods: updatedMethods,
    );
    
    // Update appbar data based on new filters
    final appBarData = _appBarConfigurationUseCase.updateAppBarData(updatedMethods);
    
    emit(state.copyWith(
      selectedMethods: updatedMethods,
      filteredCalls: filteredCalls,
      appBarData: appBarData,
    ));
  }

  /// Clear all filters and refilter results
  void clearFilters() {
    final filteredCalls = _filterNetworkCallsUseCase.applyFilters(
      state.networkCalls,
      query: '',
      statusCode: '',
      selectedMethods: const {},
    );
    
    // Update appbar data with empty filters
    final appBarData = _appBarConfigurationUseCase.updateAppBarData(const {});
    
    emit(state.copyWith(
      query: '',
      statusCode: '',
      selectedMethods: const {},
      filteredCalls: filteredCalls,
      appBarData: appBarData,
    ));
  }
}