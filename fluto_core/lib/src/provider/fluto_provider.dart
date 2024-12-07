import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';

class FlutoProvider extends ChangeNotifier {
  final GlobalKey<NavigatorState> chilcNavigatorKey;
  PluginSheetState _sheetState = PluginSheetState.closed;

  FlutoProvider(this.chilcNavigatorKey);
  PluginSheetState get sheetState => _sheetState;

  bool get showDraggingButton => _sheetState == PluginSheetState.closed;
  bool get showButtonSheet => _sheetState == PluginSheetState.clicked;

  setSheetState(PluginSheetState value) {
    _sheetState = value;
    if (_sheetState != PluginSheetState.clickedAndOpened) {
      notifyListeners();
    }
  }

  final DragController dragController = DragController();
  final DragController screenRecordingDrager = DragController();
}

enum PluginSheetState { clicked, clickedAndOpened, closed }
