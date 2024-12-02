import 'package:fluto_core/core/navigation.dart';
import 'package:fluto_core/core/plugin_callback_register.dart';
import 'package:fluto_core/model/developer_details.dart';
import 'package:fluto_core/model/plugin_configuration.dart';
import 'package:flutter/material.dart';

abstract class Pluggable {
  final String devIdentifier;
  final DeveloperDetails? developerDetails;

  Pluggable({
    required this.devIdentifier,
    this.developerDetails = const GenericDeveloperDetails(),
  });
  PluginConfiguration get pluginConfiguration;

  GlobalKey<NavigatorState> get pluginNavigatorKey =>
      _pluginRegister!.pluginNavigatorKey;

  BuildContext? get context =>
      _pluginRegister?.pluginNavigatorKey.currentContext;

  PluginRegister? get pluginRegister => _pluginRegister;
  PluginRegister? _pluginRegister;

  @mustCallSuper
  void setup({required PluginRegister pluginRegister}) {
    try {
      _pluginRegister = pluginRegister;
      getPluginManager.call().setup(pluginRegister);
      onSetupDone?.call();
    } catch (e) {}
  }

  Navigation get navigation;

  VoidCallback? onSetupDone;

  FlutoPluginManager getPluginManager() {
    return NoFlutoPluginManager();
  }
}

abstract class FlutoPluginManager<T> {
  late PluginRegister register;

  FlutoPluginManager();

  Future<T?> getData() async {
    final data = await register.loadPluginData.call();
    return modelFromString(data);
  }

  T? modelFromString(String? value);

  String? stringToModel(T? model);

  Future<void> setData(T? model) async {
    final stringifyData = stringToModel(model);
    await register.savePluginData.call(stringifyData);
  }

  void setup(PluginRegister register) {
    this.register = register;
  }
}

class NoFlutoPluginManager extends FlutoPluginManager<dynamic> {
  @override
  modelFromString(String? value) {
    throw UnimplementedError();
  }

  @override
  String? stringToModel(model) {
    throw UnimplementedError();
  }
}
