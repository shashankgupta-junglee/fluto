// import 'package:fluto_core/core/navigation.dart';
// import 'package:fluto_core/core/pluggable.dart';
// import 'package:fluto_core/model/plugin_configuration.dart';
// import 'package:flutter/material.dart';
//
// class StorageTestPlugin extends Pluggable {
//   StorageTestPlugin({
//     required super.devIdentifier,
//   });
//
//   @override
//   Navigation get navigation => Navigation.byScreen(
//         screen: Scaffold(
//           appBar: AppBar(
//             title: const Text("SharedPrefTest"),
//           ),
//           body: Column(
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   // pluginRegister
//                   //     ?.loadPluginData()
//                   //     .then((value) => print(value));
//                 },
//                 child: const Text("get Data"),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   // pluginRegister?.savePluginData.call("");
//                 },
//                 child: const Text("set Data"),
//               ),
//             ],
//           ),
//         ),
//       );
//
//   @override
//   PluginConfiguration get pluginConfiguration => PluginConfiguration(
//         icon: Icons.storage,
//         description: 'Test Plugin Storage',
//         name: 'Storage Test',
//       );
// }
