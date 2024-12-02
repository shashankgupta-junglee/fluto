import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PluginRegister {
  final GlobalKey<NavigatorState> pluginNavigatorKey;
  final AsyncValueSetter<String?> savePluginData;
  final AsyncValueGetter<String?> loadPluginData;
  PluginRegister({
    required this.pluginNavigatorKey,
    required this.savePluginData,
    required this.loadPluginData,
  });
}
