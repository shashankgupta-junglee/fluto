import 'package:draggable_widget/draggable_widget.dart';
import 'package:fluto_core/src/provider/fluto_provider.dart';
import 'package:fluto_core/src/provider/screen_record_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScreenRecordingButton extends StatelessWidget {
  final GlobalKey<NavigatorState> childNavigatorKey;
  const ScreenRecordingButton({
    super.key,
    required this.childNavigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    final flutoProvider = context.read<FlutoProvider>();
    final showDraggingButton = context
        .select<FlutoProvider, bool>((value) => value.showDraggingButton);
    return Consumer<ScreenRecordProvider>(
        builder: (context, screenRecProvider, _) {
      return DraggableWidget(
        bottomMargin: 120,
        topMargin: 120,
        intialVisibility: screenRecProvider.isRecording,
        horizontalSpace: 5,
        shadowBorderRadius: 1,
        initialPosition: AnchoringPosition.bottomLeft,
        dragController: flutoProvider.screenRecordingDrager,
        normalShadow: const BoxShadow(
            color: Colors.transparent, offset: Offset(0, 4), blurRadius: 2),
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          child: screenRecProvider.isRecording
              ? const Text("Stop", style: TextStyle(color: Colors.white))
              : const Text("Record", style: TextStyle(color: Colors.white)),
          onPressed: () async {
            if (screenRecProvider.isRecording) {
              await screenRecProvider.stopRecording();
              print("Stop Recording");
              return;
            }
            screenRecProvider.startRecording();
            print("Start Recording");
          },
        ),
      );
    });
  }
}
