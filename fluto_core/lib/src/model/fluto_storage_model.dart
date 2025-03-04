// import 'dart:convert';
//
// import 'package:flutter/foundation.dart';
//
// class FlutoStorageModel {
//   final Map<String, dynamic>? setting;
//   final Map<String, dynamic>? pluginInternalData;
//   FlutoStorageModel({
//     required this.setting,
//     required this.pluginInternalData,
//   });
//
//   FlutoStorageModel copyWith({
//     Map<String, dynamic>? setting,
//     Map<String, dynamic>? pluginInternalData,
//   }) {
//     return FlutoStorageModel(
//       setting: setting ?? this.setting,
//       pluginInternalData: pluginInternalData ?? this.pluginInternalData,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'setting': setting,
//       'pluginInternalData': pluginInternalData,
//     };
//   }
//
//   factory FlutoStorageModel.fromMap(Map<String, dynamic>? map) {
//     return FlutoStorageModel(
//       setting: map?['setting'] ?? Map<String, dynamic>.from(map?['setting']),
//       pluginInternalData: map?['pluginInternalData'] ??
//           Map<String, dynamic>.from(map?['pluginInternalData'] ?? ""),
//     );
//   }
//
//   String toJson() => json.encode(toMap());
//
//   factory FlutoStorageModel.fromJson(String source) {
//     return FlutoStorageModel.fromMap(json.decode(source));
//   }
//
//   @override
//   String toString() =>
//       'FlutoStorageModel(setting: $setting, pluginInternalData: $pluginInternalData)';
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//
//     return other is FlutoStorageModel &&
//         mapEquals(other.setting, setting) &&
//         mapEquals(other.pluginInternalData, pluginInternalData);
//   }
//
//   @override
//   int get hashCode => setting.hashCode ^ pluginInternalData.hashCode;
// }
