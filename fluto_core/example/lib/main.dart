import 'package:example/core/fluto/storage_driver.dart';
import 'package:example/pages/home_page.dart';
import 'package:fluto_core/fluto.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluto_core/src/provider/fluto_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:fluto_core/src/change_flavour/change_flavour_screen.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

void main(
  List<String> args,
) async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPref = await SharedPreferences.getInstance();
  runApp(
    MyApp(
      sharedPreferences: sharedPref,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.sharedPreferences,
  });

  final SharedPreferences sharedPreferences;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ChangeFlavourRouterImpl changeFlavourRouterImpl =
      ChangeFlavourRouterImpl(
    widget.sharedPreferences,
  );

  late final FlutoController controller = FlutoController(
    globalNavigatorKey: globalNavigatorKey,
    pluginList: [
      InternalStoragePlugin(
        storageDriver: SharedPreferencesDriver(
          widget.sharedPreferences,
        ),
      ),
      ChangeFlavourPlugin(
        router: changeFlavourRouterImpl,
        config: ChangeFlavourConfig(
          enableFlavourKey: "enable_fluto_flavours",
          flavours: {
            "env": ["dev", "staging", " prod"],
            "channel": ["alpha", "beta", "stable"],
          },
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: globalNavigatorKey,
      theme: ThemeData.dark(),
      builder: (ctx, child) {
        return Fluto(
          controller: controller,
          child: child!,
        );
      },
      home: const HomePage(),
    );
  }
}

class ChangeFlavourRouterImpl implements ChangeFlavourRouter {
  final SharedPreferences sharedPreferences;

  ChangeFlavourRouterImpl(this.sharedPreferences);

  @override
  Future<String?> getValue(String key) async {
    return sharedPreferences.getString(key);
  }

  @override
  Future<void> setValue(String key, String? value) async {
    if (value == null) return;
    if (await getValue(key) == value) return;
    await sharedPreferences.setString(key, value);
  }

  @override
  Future<void> restart() {
    exit(0);
  }
}
