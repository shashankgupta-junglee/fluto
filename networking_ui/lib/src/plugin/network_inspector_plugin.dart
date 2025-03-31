import 'package:fluto_core/core/navigation.dart';
import 'package:fluto_core/core/pluggable.dart';
import 'package:fluto_core/model/plugin_configuration.dart';
import 'package:flutter/material.dart';
import 'package:networking_ui/networking_ui.dart';

class NetworkInspectorPlugin extends Pluggable {
  NetworkInspectorPlugin({
    required this.controller,
  }) : super(devIdentifier: "network_call");

  final NetworkInspectorPluginController controller;

  @override
  Navigation get navigation => Navigation.byScreen(
        screen: NetworksListScreen(
          storage: controller.networkStorage!,
        ),
      );

  @override
  PluginConfiguration get pluginConfiguration => PluginConfiguration(
        name: "Network Inspector",
        icon: Icons.bug_report,
        description: "Network call inspector",
      );
}

class NetworkInspectorPluginController {
  NetworkStorage? networkStorage;
  NetworkCallInterceptor? interceptor;

  Future<void> init() async {
    // Create a new instance of NetworkStorage (doesn't require parameters)
    networkStorage = NetworkStorage();
    // Initialize the interceptor with the storage
    interceptor = NetworkCallInterceptor.init(networkStorage!);
  }
}
