import 'package:fluto_core/core/navigation.dart';
import 'package:fluto_core/core/pluggable.dart';
import 'package:fluto_core/model/plugin_configuration.dart';
import 'package:flutter/material.dart';
import '/src/network/ui/list/screen/networks_list_screen.dart';
import '../network/network_inspector_router.dart';

/// Plugin that provides network inspection capabilities within Fluto
class NetworkInspectorPlugin extends Pluggable {
  /// Creates a new NetworkInspectorPlugin instance
  NetworkInspectorPlugin({
    required this.router, 
  }) : super(devIdentifier: "network_call");

  /// Storage controller for network calls
  final NetworkInspectorRouter router;

  @override
  Navigation get navigation => Navigation.byScreen(
        screen: NetworksListScreen(
          dataRouter: router,
        ),
      );

  @override
  PluginConfiguration get pluginConfiguration => PluginConfiguration(
        name: "Network Inspector",
        icon: Icons.bug_report,
        description: "Network call inspector",
      );
}