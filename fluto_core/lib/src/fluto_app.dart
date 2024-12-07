import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:fluto_core/core/fluto_storage.dart';
import 'package:fluto_core/core/pluggable.dart';
import 'package:fluto_core/core/plugin_callback_register.dart';
import 'package:fluto_core/fluto.dart';
import 'package:fluto_core/src/model/fluto_storage_model.dart';
import 'package:fluto_core/src/provider/fluto_provider.dart';
import 'package:fluto_core/src/provider/screen_record_provider.dart';
import 'package:fluto_core/src/ui/components/dragging_button.dart';
import 'package:fluto_core/src/ui/components/screen_recording_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_recorder/screen_recorder.dart';

class Fluto extends StatefulWidget {
  const Fluto({
    super.key,
    required this.child,
    this.wrappedWidgetList = const [],
    this.storage = const NoFlutoStorage(),
    this.pluginList = const [],
    required this.globalNavigatorKey,
  });

  final Widget? child;
  final List<TransitionBuilder> wrappedWidgetList;
  final FlutoStorage storage;
  final List<Pluggable> pluginList;
  final GlobalKey<NavigatorState> globalNavigatorKey;

  @override
  State<Fluto> createState() => _FlutoState();
}

class _FlutoState extends State<Fluto> {
  FlutoStorageModel? _savedData;
  final GlobalKey<NavigatorState> _childNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedData();
      _runZoned();
    });
  }

  Future<void> _loadSavedData() async {
    widget.storage.load().then((savedData) {
      if (savedData != null) {
        _savedData = FlutoStorageModel.fromJson(savedData);
      }
    });

    List<Pluggable> pluginList = [
      ...FlutoPluginRegistrar.defaultPlugins.values,
      ...widget.pluginList
    ];

    final GlobalKey<NavigatorState> pluginNagivationKey =
        Platform.isMacOS ? _childNavigatorKey : widget.globalNavigatorKey;

    FlutoPluginRegistrar.registerAllPlugins(pluginList);
    for (final plugin in pluginList) {
      analysePlugin(plugin);
      final pluginRegister = PluginRegister(
        pluginNavigatorKey: pluginNagivationKey,
        savePluginData: (final value) async {
          if (_savedData == null) {
            _savedData = FlutoStorageModel(
              setting: {..._savedData?.setting ?? {}},
              pluginInternalData: {
                ..._savedData?.pluginInternalData ?? {},
                ...{plugin.devIdentifier: value}
              },
            );
          } else {
            _savedData?.pluginInternalData?[plugin.devIdentifier] = value;
          }
          if (_savedData != null) {
            widget.storage.save((_savedData!.toJson()));
          }
        },
        loadPluginData: () async {
          return _savedData?.pluginInternalData?[plugin.devIdentifier];
        },
      );
      plugin.setup(pluginRegister: pluginRegister);
    }
  }

  void _runZoned() {
    runZoned(
      () {},
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          parent.print(zone, "Intercepted: $line");
        },
        handleUncaughtError: (self, parent, zone, error, stackTrace) {
          parent.print(zone, "Intercepted error: $error");
        },
      ),
      zoneValues: {
        #log: (String message, {Object? error, StackTrace? stackTrace}) {
          developer.log("Intercepted: $message",
              error: error, stackTrace: stackTrace);
        }
      },
    );
  }

  void log(String message, {Object? error, StackTrace? stackTrace}) {
    final logFunction = Zone.current[#log] as void Function(
      String, {
      Object? error,
      StackTrace? stackTrace,
    })?;
    if (logFunction != null) {
      logFunction(message, error: error, stackTrace: stackTrace);
    } else {
      developer.log(message, error: error, stackTrace: stackTrace);
    }
  }

  void analysePlugin(Pluggable plugin) {
    try {
      plugin.pluginConfiguration.description;
    } catch (e) {
      log(plugin.devIdentifier, error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? child = widget.child;

    for (final widgetBuilder in widget.wrappedWidgetList.reversed) {
      child = widgetBuilder.call(context, widget.child);
    }

    return ChangeNotifierProvider<FlutoProvider>(
      create: (context) => FlutoProvider(
        _childNavigatorKey,
      ),
      builder: (context, child) {
        return child ?? Container();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Consumer<ScreenRecordProvider>(
                builder: (context, screenRecProvider, _) {
              if (screenRecProvider.screenRecorderController == null) {
                return child ?? const SizedBox();
              }
              return ScreenRecorder(
                child: child ?? const SizedBox(),
                controller: screenRecProvider.screenRecorderController!,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              );
            }),
            DraggingButton(
              childNavigatorKey: widget.globalNavigatorKey,
            ),
            ScreenRecordingButton(
              childNavigatorKey: widget.globalNavigatorKey,
            ),
          ],
        ),
      ),
    );
  }
}
