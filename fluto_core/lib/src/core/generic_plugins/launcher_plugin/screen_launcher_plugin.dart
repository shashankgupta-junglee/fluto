import 'package:fluto_core/core/navigation.dart';
import 'package:fluto_core/core/pluggable.dart';
import 'package:fluto_core/model/plugin_configuration.dart';
import 'package:fluto_core/src/change_flavour/change_flavour_screen.dart';
import 'package:fluto_core/src/change_location/change_location_screen.dart';
import 'package:fluto_core/src/storage_view/lib/src/models/storage_driver.dart';
import 'package:fluto_core/src/storage_view/lib/src/ui/controller/storage_viewer_controller.dart';
import 'package:fluto_core/src/storage_view/lib/src/ui/storage_view_ui.dart';
import 'package:flutter/material.dart';

class ScreenLauncherPlugin extends Pluggable {
  final Widget screen;
  final String name;
  final IconData icon;
  final String description;

  ScreenLauncherPlugin({
    required super.devIdentifier,
    required this.screen,
    required this.name,
    this.icon = Icons.bug_report,
    this.description = "",
  });

  @override
  Navigation get navigation => Navigation.byScreen(
        // globalContext: context!,
        screen: screen,
      );

  @override
  PluginConfiguration get pluginConfiguration => PluginConfiguration(
        name: name,
        icon: icon,
        description: description,
      );
}

class InternalStoragePlugin extends Pluggable {
  InternalStoragePlugin({
    required StorageDriver storageDriver,
  })  : _provider = StorageViewerController(storageDriver),
        super(devIdentifier: "internal_storage_plugin");

  final StorageViewerController _provider;

  @override
  Navigation get navigation => Navigation.byScreen(
        // globalContext: context!,
        screen: StorageView(
          storageViewerController: _provider,
        ),
      );

  @override
  PluginConfiguration get pluginConfiguration => PluginConfiguration(
        name: "Internal Storage Viewer",
        icon: Icons.storage,
        description: "View and clear shared preferences",
      );
}

class ChangeFlavourPlugin extends Pluggable {
  ChangeFlavourPlugin({
    required this.router,
    required this.config,
  }) : super(devIdentifier: "ChangeFlavourPlugin");

  final ChangeFlavourRouter router;
  final ChangeFlavourConfig config;
  @override
  Navigation get navigation => Navigation.byScreen(
        // globalContext: context!,
        screen: ChangeFlavourScreen(
          router: router,
          config: config,
        ),
      );

  @override
  PluginConfiguration get pluginConfiguration => PluginConfiguration(
        name: "Change Flavour",
        icon: Icons.settings,
        description: "Change the flavour of the app",
      );
}
class ChangeLocationPlugin extends Pluggable {
  ChangeLocationPlugin({
    required this.router,
  }) : super(devIdentifier: "ChangeLocationPlugin");

  final ChangeLocationRouter router;

  @override
  Navigation get navigation => Navigation.byScreen(
        // globalContext: context!,
        screen: ChangeLocationScreen(
          router: router,
        ),
      );

  @override
  PluginConfiguration get pluginConfiguration => PluginConfiguration(
        name: "Change Location",
        icon: Icons.location_on,
        description: "Change the latitude and longitude of the app's location settings",
      );
}
