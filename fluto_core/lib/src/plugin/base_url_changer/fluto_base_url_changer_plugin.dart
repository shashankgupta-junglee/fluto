// import 'dart:async';
// import 'dart:convert';
// import 'package:fluto_core/core/navigation.dart';
// import 'package:fluto_core/core/pluggable.dart';
// import 'package:fluto_core/model/plugin_configuration.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// class FlutoDynamicBaseUrlManager
//     extends FlutoPluginManager<FlutoBaseUrlChangePluginModel> {
//   final AsyncValueGetter<String> initialBaseUrl;
//
//   ///Dynamic Base URl means SavedBaseUrl or InitialBaseUrl
//   Future<String?> getDynamicBaseUrl() async {
//     final savedData = await getSavedBaseUrl();
//
//     return savedData ?? await initialBaseUrl.call();
//   }
//
//   Future<String?> getSavedBaseUrl() async {
//     final savedData = await register.loadPluginData.call();
//     if (savedData?.isNotEmpty ?? false) {
//       final savedPluginData =
//           FlutoBaseUrlChangePluginModel.fromJson(savedData!);
//
//       if (savedPluginData.savedBaseUrl.isNotEmpty) {
//         return savedPluginData.savedBaseUrl;
//       }
//     }
//     return null;
//   }
//
//   Future<Uri> getHttpUri(String url) async {
//     final parsedUrl = Uri.parse(url);
//
//     final dynamicBaseUrl = Uri.tryParse(await getDynamicBaseUrl() ?? "");
//
//     if (dynamicBaseUrl == null) return parsedUrl;
//
//     ///TO get new url
//     return parsedUrl.replace(
//         scheme: dynamicBaseUrl.scheme, host: dynamicBaseUrl.host);
//   }
//
//   FlutoDynamicBaseUrlManager(this.initialBaseUrl);
//
//   @override
//   FlutoBaseUrlChangePluginModel? modelFromString(String? value) {
//     if (value == null) return null;
//     return FlutoBaseUrlChangePluginModel.fromJson(value);
//   }
//
//   @override
//   String? stringToModel(FlutoBaseUrlChangePluginModel? model) {
//     return model?.toJson();
//   }
// }
//
// class FlutoDynamicBaseUrlPlugin extends Pluggable {
//   final FlutoDynamicBaseUrlManager flutoDynamicBaseUrlManager;
//   FlutoDynamicBaseUrlPlugin({
//     required super.devIdentifier,
//     required this.flutoDynamicBaseUrlManager,
//   });
//
//   @override
//   Navigation get navigation => Navigation.byScreen(
//         // globalContext: context!,
//         screen: PlutoDynamicBaseUrlScreen(plugin: this),
//       );
//
//   @override
//   PluginConfiguration get pluginConfiguration => PluginConfiguration(
//         name: "Base Url",
//         icon: Icons.network_check,
//         description: "Dynamic BaseUrl changer",
//       );
//   @override
//   FlutoPluginManager getPluginManager() => flutoDynamicBaseUrlManager;
// }
//
// class PlutoDynamicBaseUrlScreen extends StatefulWidget {
//   const PlutoDynamicBaseUrlScreen({super.key, required this.plugin});
//
//   final FlutoDynamicBaseUrlPlugin plugin;
//
//   @override
//   State<PlutoDynamicBaseUrlScreen> createState() =>
//       _PlutoDynamicBaseUrlScreenState();
// }
//
// class _PlutoDynamicBaseUrlScreenState extends State<PlutoDynamicBaseUrlScreen> {
//   FlutoBaseUrlChangePluginModel savedPluginData =
//       FlutoBaseUrlChangePluginModel("");
//
//   final currentBaseUrlTextCtr = TextEditingController();
//
//   final newBaseUrlTextCtr = TextEditingController();
//
//   Timer? _debounce;
//
//   @override
//   void initState() {
//     super.initState();
//     loadCurrentBaseUrl();
//   }
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     super.dispose();
//   }
//
//   void loadCurrentBaseUrl() async {
//     final savedData = await widget.plugin.pluginRegister?.loadPluginData.call();
//     if (savedData?.isNotEmpty ?? false) {
//       savedPluginData = FlutoBaseUrlChangePluginModel.fromJson(savedData!);
//     } else {
//       savedPluginData = FlutoBaseUrlChangePluginModel("");
//     }
//
//     if (savedPluginData.savedBaseUrl.isNotEmpty) {
//       currentBaseUrlTextCtr.text = savedPluginData.savedBaseUrl;
//       if (mounted) {
//         setState(() {});
//       }
//     } else {
//       final currentBaseUrlSetInManager =
//           await widget.plugin.flutoDynamicBaseUrlManager.initialBaseUrl.call();
//       currentBaseUrlTextCtr.text = currentBaseUrlSetInManager;
//       if (mounted) {
//         setState(() {});
//       }
//     }
//   }
//
//   String? get _errorText {
//     // at any time, we can get the text from _controller.value.text
//     final text = newBaseUrlTextCtr.value.text;
//     // Note: you can do your own custom validation here
//     // Move this logic this outside the widget for more testable code
//     if (text.isEmpty) {
//       return 'Can\'t be empty';
//     }
//     if (text.length < 12) {
//       return 'Too short';
//     }
//
//     if (text == currentBaseUrlTextCtr.text) {
//       return "Should not same as Current Base Url";
//     }
//
//     final generatedUrl = Uri.tryParse(text);
//     final isValidLink = generatedUrl?.hasAbsolutePath ?? false;
//
//     if (!isValidLink) {
//       return "Not Valid Link";
//     }
//
//     final generatedCurrentUrl = Uri.tryParse(currentBaseUrlTextCtr.text);
//
//     if (generatedCurrentUrl?.scheme == generatedUrl?.scheme &&
//         generatedCurrentUrl?.host == generatedUrl?.host) {
//       return "Current and New Url should not have same base url";
//     }
//     // return null if the text is valid
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Base Url Change"),
//         actions: [
//           IconButton(
//             onPressed: () {
//               savedPluginData = savedPluginData.copyWith(savedBaseUrl: "");
//               onSave();
//             },
//             icon: const Icon(Icons.refresh),
//           )
//         ],
//       ),
//       body: Column(
//         // crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Card(
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
//                 child: Column(
//                   children: [
//                     TextField(
//                       enableInteractiveSelection:
//                           false, // will disable paste operation
//                       controller: currentBaseUrlTextCtr,
//
//                       focusNode: AlwaysDisabledFocusNode(),
//                       decoration: InputDecoration(
//                         prefixIcon: const Icon(Icons.call_made),
//                         label: const Text("Current Base URL"),
//                         hintText: 'https://www.google.com',
//                         suffixIcon: IconButton(
//                           onPressed: () {
//                             print(currentBaseUrlTextCtr.text);
//                             Clipboard.setData(
//                               ClipboardData(text: currentBaseUrlTextCtr.text),
//                             );
//                           },
//                           icon: const Icon(Icons.copy_rounded),
//                         ),
//                       ),
//                     ),
//                     TextField(
//                       controller: newBaseUrlTextCtr,
//                       decoration: InputDecoration(
//                         prefixIcon: const Icon(Icons.call_merge),
//                         label: const Text("New Base URL"),
//                         hintText: 'https://www.google.com',
//                         suffixIcon: IconButton(
//                           onPressed: newBaseUrlTextCtr.clear,
//                           icon: const Icon(Icons.clear),
//                         ),
//                         errorText: _errorText,
//                       ),
//                       onChanged: (value) {
//                         if (_debounce?.isActive ?? false) _debounce?.cancel();
//                         _debounce =
//                             Timer(const Duration(milliseconds: 500), () {
//                           setState(() {
//                             savedPluginData =
//                                 savedPluginData.copyWith(savedBaseUrl: value);
//                           });
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const Spacer(),
//         ],
//       ),
//       bottomNavigationBar: ElevatedButton(
//         onPressed: _errorText == null ? onSave : null,
//         child: const Text("Save"),
//       ),
//     );
//   }
//
//   Future<void> onSave() async {
//     try {
//       await widget.plugin.pluginRegister?.savePluginData
//           .call(savedPluginData.toJson());
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("save")));
//       Navigator.of(context).pop();
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Error")));
//     }
//   }
// }
//
// class AlwaysDisabledFocusNode extends FocusNode {
//   @override
//   bool get hasFocus => false;
// }
//
// class FlutoBaseUrlChangePluginModel {
//   final String savedBaseUrl;
//
//   FlutoBaseUrlChangePluginModel(
//     this.savedBaseUrl,
//   );
//
//   FlutoBaseUrlChangePluginModel copyWith({
//     String? savedBaseUrl,
//   }) {
//     return FlutoBaseUrlChangePluginModel(
//       savedBaseUrl ?? this.savedBaseUrl,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'savedBaseUrl': savedBaseUrl,
//     };
//   }
//
//   factory FlutoBaseUrlChangePluginModel.fromMap(Map<String, dynamic> map) {
//     return FlutoBaseUrlChangePluginModel(
//       map['savedBaseUrl'] ?? '',
//     );
//   }
//
//   String toJson() => json.encode(toMap());
//
//   factory FlutoBaseUrlChangePluginModel.fromJson(String source) =>
//       FlutoBaseUrlChangePluginModel.fromMap(json.decode(source));
//
//   @override
//   String toString() =>
//       'FlutoBaseUrlChangePluginModel(savedBaseUrl: $savedBaseUrl)';
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//
//     return other is FlutoBaseUrlChangePluginModel &&
//         other.savedBaseUrl == savedBaseUrl;
//   }
//
//   @override
//   int get hashCode => savedBaseUrl.hashCode;
// }
