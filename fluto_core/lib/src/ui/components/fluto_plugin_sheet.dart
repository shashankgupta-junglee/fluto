import 'dart:io';

import 'package:fluto_core/core/pluggable.dart';
import 'package:fluto_core/src/core/plugin_manager.dart';
import 'package:fluto_core/src/provider/fluto_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showFlutoBottomSheet(BuildContext context) async {
  final pluginList = FlutoPluginRegistrar.pluginList;
  final childNavigatorKey = context.read<FlutoProvider>().chilcNavigatorKey;

  if (Platform.isMacOS) {
    showDialog(
      context: context,
      builder: (context) {
        return Builder(
          builder: (context) {
            return DesktopFlutoDialog(
              pluginList: pluginList,
              childNavigatorKey: childNavigatorKey,
            );
          },
        );
      },
    );
    return;
  }

  showModalBottomSheet(
    isDismissible: false,
    enableDrag: false,
    context: context,
    builder: (BuildContext _) {
      return Builder(
        builder: (BuildContext _) {
          final provider = context.read<FlutoProvider>();
          provider.setSheetState(PluginSheetState.clickedAndOpened);
          return PopScope(
            onPopInvoked: (_) async {
              provider.setSheetState(PluginSheetState.closed);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text("Fluto Project"),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      provider.setSheetState(PluginSheetState.closed);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Visibility(
                    visible: pluginList.isNotEmpty,
                    replacement:
                        const Center(child: Text("No Plugin Available")),
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: pluginList.length,
                      itemBuilder: (context, index) {
                        final plugin = pluginList[index];

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          color: Color.alphaBlend(
                            Theme.of(context).cardColor,
                            Theme.of(context).secondaryHeaderColor,
                          ),
                          child: FlutoTile(plugin: plugin),
                        );
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class DesktopFlutoDialog extends StatefulWidget {
  const DesktopFlutoDialog({
    super.key,
    required this.childNavigatorKey,
    required this.pluginList,
  });

  final List<Pluggable> pluginList;
  final GlobalKey<NavigatorState> childNavigatorKey;

  @override
  State<DesktopFlutoDialog> createState() => _DesktopFlutoDialogState();
}

class _DesktopFlutoDialogState extends State<DesktopFlutoDialog> {
  int selectedPluginIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.pluginList.firstOrNull?.navigation.onLaunch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 80.0,
        vertical: 48.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text("Fluto Project"),
            trailing: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
            ),
          ),
          const Divider(),
          Expanded(
            child: Visibility(
              visible: widget.pluginList.isNotEmpty,
              replacement: const Center(
                child: Text("No Plugin Available"),
              ),
              child: Row(
                children: [
                  Container(
                    width: 300,
                    color: Colors.grey.shade800,
                    child: ListView.builder(
                      itemCount: widget.pluginList.length,
                      itemBuilder: (context, index) {
                        final plugin = widget.pluginList[index];

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            selected: selectedPluginIndex == index,
                            onTap: () {
                              if (selectedPluginIndex == index) {
                                return;
                              }
                              plugin.navigation.onLaunch.call();
                              setState(() {
                                selectedPluginIndex = index;
                              });
                            },
                            title: Text(
                              plugin.pluginConfiguration.name,
                            ),
                            leading: Icon(
                              plugin.pluginConfiguration.icon,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Navigator(
                      key: widget.childNavigatorKey,
                      onGenerateRoute: (settings) {
                        return MaterialPageRoute(
                          builder: (context) {
                            return const Center(
                              child: Text("No Plugin Selected"),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FlutoTile extends StatelessWidget {
  const FlutoTile({
    super.key,
    required this.plugin,
  });

  final Pluggable plugin;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        plugin.navigation.onLaunch.call();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            plugin.pluginConfiguration.icon,
            size: 30,
          ),
          const Padding(padding: EdgeInsets.all(10)),
          Text(
            plugin.pluginConfiguration.name,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
