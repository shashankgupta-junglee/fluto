import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluto_core/core/pluggable.dart';

sealed class FlutoEvent {}

class ShowFlutoDialogEvent extends FlutoEvent {
  final List<Pluggable> pluginList;
  final BuildContext context;

  ShowFlutoDialogEvent({
    required this.pluginList,
    required this.context,
  });
}

class FlutoController with UiEffectsCallbackMixin<FlutoEvent> {
  final List<Pluggable> _pluginList;
  final GlobalKey<NavigatorState> _globalNavigatorKey;

  FlutoController({
    List<Pluggable> pluginList = const [],
    required GlobalKey<NavigatorState> globalNavigatorKey,
  })  : _pluginList = pluginList,
        _globalNavigatorKey = globalNavigatorKey;

  final DragController dragController = DragController();

  void onClickDraggingButton() {
    dragController.hideWidget();
    uiEffectsCallback.call(
      ShowFlutoDialogEvent(
        pluginList: _pluginList,
        context: _globalNavigatorKey.currentContext!,
      ),
    );
  }

  void onPopupClose() {
    dragController.showWidget();
  }
}

enum PluginSheetState { clicked, clickedAndOpened, closed }

typedef ValueSetter<T> = void Function(T value);

mixin UiEffectsCallbackMixin<E> {
  late final ValueSetter<E> uiEffectsCallback;

  void registerUiEffectsCallback(ValueSetter<E> callback) {
    uiEffectsCallback = callback;
  }

  void triggerUiEffect(E effect) {
    uiEffectsCallback(effect);
  }
}
