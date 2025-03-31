import 'package:flutter/material.dart';
import 'dart:io';
import '/src/network/ui/list/cubit/network_list_screen_cubit.dart';

/// Use case for handling app bar configuration
class AppBarConfigurationUseCase {
  
  /// Gets the initial app bar data
  AppBarData getInitialAppBarData() {
    return AppBarData(
      height: kToolbarHeight,
      hasFilters: false,
      platformOffset: Platform.isMacOS ? 25.0 : 0.0,
    );
  }
  
  /// Updates the app bar configuration based on the current filters
  AppBarData updateAppBarData(Set<String> selectedMethods) {
    final bool hasFilters = selectedMethods.isNotEmpty;
    final double platformOffset = (Platform.isMacOS || Platform.isWindows) ? 25.0 : 0.0;
    
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
}