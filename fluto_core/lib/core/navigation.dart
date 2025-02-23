import 'package:flutter/material.dart';

class Navigation {
  final ValueSetter<BuildContext> onLaunch;
  Navigation(this.onLaunch);

  factory Navigation.byScreen({
    required Widget screen,
  }) {
    return _ScreenNavigation(
      screen: screen,
    );
  }
}

class _ScreenNavigation extends Navigation {
  _ScreenNavigation({
    required Widget screen,
  }) : super(
          (context) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => screen,
              ),
            );
          },
        );
}
