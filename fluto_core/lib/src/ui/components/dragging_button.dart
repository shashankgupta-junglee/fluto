import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';

class DraggingButton extends StatelessWidget {
  final VoidCallback onPressed;
  const DraggingButton({
    required this.onPressed,
    super.key,
    required this.controller,
  });

  final DragController controller;


  @override
  Widget build(BuildContext context) {
    return DraggableWidget(
      bottomMargin: 120,
      topMargin: 120,
      horizontalSpace: 5,
      intialVisibility: true,
      shadowBorderRadius: 1,
      initialPosition: AnchoringPosition.bottomRight,
      dragController: controller,
      normalShadow: const BoxShadow(
        color: Colors.transparent,
        offset: Offset(0, 4),
        blurRadius: 2,
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: onPressed,
        child: const Icon(Icons.bug_report),
      ),
    );
  }
}
