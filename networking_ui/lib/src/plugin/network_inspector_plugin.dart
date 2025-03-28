import 'package:fluto_core/core/navigation.dart';
import 'package:fluto_core/core/pluggable.dart';
import 'package:fluto_core/model/plugin_configuration.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:networking_ui/networking_ui.dart';

class NetworkInspectorPlugin extends Pluggable {
  NetworkInspectorPlugin({
    required this.controller,
  }) : super(devIdentifier: "network_call");

  final NetworkInspectorPluginController controller;

  @override
  Navigation get navigation => Navigation.byScreen(
        // globalContext: context!,
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

  void init() async {
    final LazyBox box = await Hive.openLazyBox('NetworkProvider');
    networkStorage = NetworkStorage(FlutoNetworkLazyBox(box));
    await networkStorage?.init();
    interceptor = NetworkCallInterceptor.init(networkStorage!);
  }
}
