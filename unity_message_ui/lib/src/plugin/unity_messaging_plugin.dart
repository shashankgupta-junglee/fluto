import 'package:fluto_core/core/navigation.dart';
import 'package:fluto_core/core/pluggable.dart';
import 'package:fluto_core/model/plugin_configuration.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:unity_message_ui/unity_message_ui.dart';

class UnityMessageViewerPlugin extends Pluggable {
  UnityMessageViewerPlugin({
    required this.controller,
  }) : super(devIdentifier: "unity_message");

  final UnityMessagingPluginController controller;

  @override
  Navigation get navigation => Navigation.byScreen(
        // globalContext: context!,
        screen: UnityMessageListScreen(
          storage: controller.unityMessageStorage!,
        ),
      );

  @override
  PluginConfiguration get pluginConfiguration => PluginConfiguration(
        name: "Unity Message Inspector",
        icon: Icons.bug_report,
        description: "Unity Message Inspector",
      );
}

class UnityMessagingPluginController {
  UnityMessageStorage? unityMessageStorage;
  UnityMessageInterceptor? interceptor;

  Future<void> init() async {
    final LazyBox box = await Hive.openLazyBox('UnityProvider');
    unityMessageStorage = FlutoUnityMessageStorage(box: box);
    await unityMessageStorage?.init();
    interceptor = UnityMessageInterceptor.init(unityMessageStorage!);
  }
}

class FlutoUnityMessageStorage extends UnityMessageStorage {
  FlutoUnityMessageStorage({
    required LazyBox box,
  }) : super(FlutoUnityStorageLazyBox(box));
}

class FlutoUnityStorageLazyBox extends LazyUnityBox {
  final LazyBox _box;

  FlutoUnityStorageLazyBox(this._box);

  @override
  Future<void> clear() {
    return _box.clear();
  }

  @override
  Future get(key) {
    return _box.get(key);
  }

  @override
  Iterable get keys => _box.keys;

  @override
  Future<void> put(key, value) {
    return _box.put(key, value);
  }
}
