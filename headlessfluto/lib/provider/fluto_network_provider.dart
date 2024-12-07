import 'package:flutter/material.dart';
import 'package:networking_ui/networking_ui.dart';

class FlutoNetworkProvider extends ChangeNotifier {
  List<InfospectNetworkCall> _networkCalls = [];
  Set<InfospectNetworkCall> get networkCalls => _networkCalls.toSet();
  void addNetworkCall(InfospectNetworkCall networkCall) {
    _networkCalls = [networkCall, ..._networkCalls];
    notifyListeners();
  }
}
