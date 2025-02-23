// import 'package:fluto_core/core/navigation.dart';
// import 'package:fluto_core/core/pluggable.dart';
// import 'package:fluto_core/model/plugin_configuration.dart';
// import 'package:flutter/material.dart';
//
// class ClickLauncherPlugin extends Pluggable {
//   final String name;
//   final IconData icon;
//   final String description;
//   final VoidCallback onClick;
//
//   ClickLauncherPlugin({
//     required super.devIdentifier,
//     required this.name,
//     required this.onClick,
//     this.icon = Icons.bug_report,
//     this.description = "",
//   });
//
//   @override
//   Navigation get navigation => Navigation(onClick);
//
//   @override
//   PluginConfiguration get pluginConfiguration =>
//       PluginConfiguration(name: name, icon: icon, description: description);
//
//   @override
//   FlutoPluginManager? get pluginManager => null;
// }
