import 'package:fluto_core/fluto.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Testing Fluto Logs and Errors"),
            const Padding(padding: EdgeInsets.all(10)),
            ElevatedButton(
              onPressed: () {
                FlutoLogModel.log(
                  "This is an informational log",
                  logType: FlutoLogType.info,
                );
              },
              child: const Text("Generate Info Log"),
            ),
            ElevatedButton(
              onPressed: () {
                FlutoLogModel.log(
                  "This is a warning log",
                  logType: FlutoLogType.warning,
                );
              },
              child: const Text("Generate Warning Log"),
            ),
            ElevatedButton(
              onPressed: () {
                FlutoLogModel.log(
                  "This is an error log",
                  logType: FlutoLogType.error,
                );
              },
              child: const Text("Generate Error Log"),
            ),
            ElevatedButton(
              onPressed: () {
                FlutoLogModel.log(
                  "This is a debug log",
                  logType: FlutoLogType.debug,
                );
              },
              child: const Text("Generate Debug Log"),
            ),
            ElevatedButton(
              onPressed: () {
                FlutoLogModel.log(
                  "This is a success log",
                  logType: FlutoLogType.info,
                );
              },
              child: const Text("Generate Success Log"),
            ),
            const Divider(),
            ElevatedButton(
              onPressed: () {
                throw Exception("Manual exception triggered for*+ testing");
              },
              child: const Text("Trigger Exception"),
            ),
            ElevatedButton(
              onPressed: () {
                Future.delayed(Duration.zero, () {
                  throw StateError("Asynchronous error for testing");
                });
              },
              child: const Text("Trigger Async Error"),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  print("Hello i am here");
                  List<int> numbers = [1, 2, 3];
                  print(numbers[5]); // Index out of range
                } catch (e, stackTrace) {
                  FlutoLogModel.log(
                    "Caught an index error: $e",
                    logType: FlutoLogType.error,
                    error: e,
                    stackTrace: stackTrace,
                  );
                }
              },
              child: const Text("Trigger Index Error"),
            ),
          ],
        ),
      ),
    );
  }
}
