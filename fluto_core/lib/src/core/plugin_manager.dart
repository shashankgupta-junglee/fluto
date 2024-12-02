import 'package:fluto_core/core/pluggable.dart';
import 'package:fluto_core/fluto.dart';
import 'package:fluto_core/src/logger/log_viewer.dart';
import 'package:fluto_core/src/shared_preference/shared_preference_viewer.dart';
import 'package:flutter/material.dart';

abstract class FlutoPluginRegistrar {
  static Map<String, Pluggable> defaultPlugins = {
    "Log-Viewer": ScreenLauncherPlugin(
      devIdentifier: 'one',
      screen: const LogViewer(),
      name: "Log-Viewer",
    ),
    "Shared-Preferences-Viwer": ScreenLauncherPlugin(
      devIdentifier: 'two',
      screen: const SharedPreferencesViewer(),
      name: "Shared-Preferences-Viwer",
      icon: Icons.storage,
    ),
  };
  static final Map<String, Pluggable> _plugins = {};

  static Map<String, Pluggable> get plugins => _plugins;
  static List<Pluggable> get pluginList => _plugins.values.toList();

  static void registerPlugin(Pluggable plugin) {
    _plugins.addEntries([MapEntry(plugin.devIdentifier, plugin)]);
  }

  static void unregisterPlugin(Pluggable plugin) {
    _plugins.remove(plugin);
  }

  static void unregisterPluginById(String pluginId) {
    return _plugins.removeWhere((key, value) => key == pluginId);
  }

  static void unregisterAllPlugins() {
    _plugins.clear();
  }

  static void registerAllPlugins([List<Pluggable>? plugins]) {
    if (plugins != null) {
      _plugins.addEntries(plugins.map((e) => MapEntry(e.devIdentifier, e)));
    }
  }
}
