import 'package:fluto_core/src/provider/fluto_provider.dart';
import 'package:fluto_core/src/ui/components/dragging_button.dart';
import 'package:fluto_core/src/ui/components/fluto_plugin_sheet.dart';
import 'package:flutter/material.dart';

class Fluto extends StatefulWidget {
  final FlutoController controller;
  const Fluto({
    super.key,
    required this.child,
    required this.controller,
  });

  final Widget child;

  @override
  State<Fluto> createState() => _FlutoState();
}

class _FlutoState extends State<Fluto> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerEvent();
    });
  }

  void _registerEvent() {
    widget.controller.registerUiEffectsCallback(
      (effect) {
        switch (effect) {
          case ShowFlutoDialogEvent():
            showFlutoBottomSheet(
              effect.context,
              effect.pluginList,
            ).then(
              (value) {
                widget.controller.onPopupClose();
              },
            );
            break;

          default:
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    return Scaffold(
      body: Stack(
        children: [
          child,
          DraggingButton(
            onPressed: () {
              widget.controller.onClickDraggingButton();
            },
            controller: widget.controller.dragController,
          ),
        ],
      ),
    );
  }
}
