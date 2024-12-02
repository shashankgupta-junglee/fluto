import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider with ChangeNotifier {
  Map<String, dynamic> _sharedPrefsData = {};
  Map<String, dynamic> get sharedPrefsData => _sharedPrefsData;

  Future<void> loadSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final data = <String, dynamic>{};
    for (var key in keys) {
      data[key] = prefs.get(key);
    }

    _sharedPrefsData = data;
    notifyListeners();
  }

  Future<void> clearSharedPreferences({String? key}) async {
    final prefs = await SharedPreferences.getInstance();

    if (key != null) {
      await prefs.remove(key);
    } else {
      await prefs.clear();
    }

    await loadSharedPreferences();
  }

  Future<void> updateSharedPreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      await prefs.setString(key, value.toString());
    }

    await loadSharedPreferences();
  }
}
