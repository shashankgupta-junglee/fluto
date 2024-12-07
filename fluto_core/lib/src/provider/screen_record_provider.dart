import 'dart:typed_data';

import 'package:gif_view/gif_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:screen_recorder/screen_recorder.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScreenRecordProvider extends ChangeNotifier {
  Supabase? supabase;
  bool _isRecording = false;
  bool get isRecording => _isRecording;
  ScreenRecorderController? screenRecorderController;
  List<FileSystemEntity> recordedFiles = [];
  Map<String, List<int>> recordedByteData = {};
  Directory? downloadDirectory;

  Future<void> init({
    required Supabase? supabase,
  }) async {
    screenRecorderController = ScreenRecorderController(pixelRatio: 1);
    downloadDirectory = await getDownloadsDirectory();
    downloadDirectory = Directory('${downloadDirectory?.path}/fluto');
    this.supabase = supabase;
    notifyListeners();
  }

  void startRecording() {
    _isRecording = true;
    screenRecorderController?.start();
    notifyListeners();
  }

  Future<void> stopRecording() async {
    screenRecorderController?.stop();
    _isRecording = false;
    notifyListeners();
    var data = await screenRecorderController?.exporter.exportGif();
    if ((data ?? []).isEmpty) {
      return;
    }
    recordedByteData[
        "screen_record -${DateTime.now().millisecondsSinceEpoch}"] = data ?? [];
    if (supabase != null) {
     final supabaseResponse = await supabase!.client.storage
          .from("fluto_useractivity")
          .uploadBinary(
            "userActivity/screen_record -${DateTime.now().millisecondsSinceEpoch}.gif",
            Uint8List.fromList(
              data ?? [],
            ),
          );
      print("supabaseResponse: ${supabaseResponse.data}");
    }
    notifyListeners();
    // if (data == null) {
    //   return;
    // }
    // if (downloadDirectory == null) {
    //   print("Direcorry is null");
    //   return;
    // }
    // if (downloadDirectory!.existsSync()) {
    //   print("Directory exists");
    // } else {
    //   downloadDirectory = await downloadDirectory?.create();
    // }
    // File file = File(
    //     '${downloadDirectory?.path}/screen_record_${DateTime.now().millisecondsSinceEpoch}.gif');
    // // await file.create(recursive: true);
    // File? downloadedFile = await file.writeAsBytes(data);
    // print(
    //     "File Path: ${downloadedFile.path} with size ${downloadedFile.lengthSync()} is exists ${downloadedFile.existsSync()}");
    // recordedFiles = downloadDirectory?.listSync().toList() ?? [];
    // notifyListeners();
  }
}

class UserActivityListView extends StatefulWidget {
  const UserActivityListView({super.key});
  @override
  State<UserActivityListView> createState() => _UserActivityListViewState();
}

class _UserActivityListViewState extends State<UserActivityListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenRecordProvider>(builder: (context, provider, _) {
      if (provider.recordedByteData.isEmpty) {
        return const Center(
          child: Text('No recorded files'),
        );
      }
      return ListView.builder(
        itemCount: provider.recordedByteData.keys.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
                provider.recordedByteData.keys.toList()[index].split('/').last),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _GifPlayerScreen(
                  gifBytes: provider.recordedByteData.values.toList()[index],
                ),
              ),
            ),
          );
        },
      );
    });
    // return Consumer<ScreenRecordProvider>(
    //   builder: (context, state, child) {
    //     if (state.recordedFiles.isEmpty) {
    //       return const Center(
    //         child: Text('No recorded files'),
    //       );
    //     }
    //     return ListView.builder(
    //       itemCount: state.recordedFiles.length,
    //       itemBuilder: (context, index) {
    //         final activity = state.recordedFiles[index];
    //         return ListTile(
    //           title: Text(activity.split('/').last),
    //           onTap: () => Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => _VideoPlayerScreen(videoPath: activity),
    //             ),
    //           ),
    //         );
    //       },
    //     );
    //   },
    // );
  }
}

class _GifPlayerScreen extends StatefulWidget {
  final List<int> gifBytes;
  const _GifPlayerScreen({required this.gifBytes});
  @override
  State<_GifPlayerScreen> createState() => _GifPlayerScreenState();
}

class _GifPlayerScreenState extends State<_GifPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: GifView.memory(
          Uint8List.fromList(widget.gifBytes),
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.8,
        ),
      ),
    );
  }
}


// class _VideoPlayerScreen extends StatefulWidget {
//   final String videoPath;
//   const _VideoPlayerScreen({required this.videoPath});
//   @override
//   State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
//   late VideoPlayerController _controller;
//   late Future<void> _initializeVideoPlayerFuture;
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.file(File(widget.videoPath));
//     _initializeVideoPlayerFuture = _controller.initialize();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Video Player'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: FutureBuilder(
//         future: _initializeVideoPlayerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return AspectRatio(
//               aspectRatio: _controller.value.aspectRatio,
//               child: VideoPlayer(_controller),
//             );
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           setState(() {
//             if (_controller.value.isPlaying) {
//               _controller.pause();
//             } else {
//               _controller.play();
//             }
//           });
//         },
//         child: Icon(
//           _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//         ),
//       ),
//     );
//   }
// }
