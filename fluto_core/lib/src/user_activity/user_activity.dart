import 'package:flutter/foundation.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:hive_flutter/hive_flutter.dart';


class UserActivity extends ChangeNotifier {
  final Box _box;

  UserActivity({required Box box}) : _box = box;

  final List<String> _activities = [];

  Future<void> loadActivities() async {
    final Iterable<Future<dynamic>> activityFutures = _box.keys.map((key) => _box.get(key));
    final activities = await Future.wait(activityFutures);
    _activities.addAll(activities.cast<String>());
    notifyListeners();
  }

  Future<void> addActivity(String activity) async {
    _activities.add(activity);
    await _box.put(_activities.length + 1, _activities);
    notifyListeners();
  }

  String createName() {
    return 'activity_${_activities.length +1}';
  }

  Future<void> startRecording() async {
    final videoPath = await FlutterScreenRecording.startRecordScreen(createName());

    final path =  await FlutterScreenRecording.stopRecordScreen;
  }
}
