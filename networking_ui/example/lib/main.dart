import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:networking_ui/networking_ui.dart';
import 'package:http/http.dart' as http;
import 'package:networking_ui/src/network/new_core_http_client.dart';
import 'package:networking_ui/src/network/network_call_interceptor.dart';
import 'package:networking_ui/src/network/core_http_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Networking UI Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Network Inspector Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final NetworkInspectorPluginController _networkController = NetworkInspectorPluginController();
  final List<String> _logs = [];
  late FlutoCoreHttpManager _httpClient;

  @override
  void initState() {
    super.initState();
    _initNetworkMonitoring();
  }

  Future<void> _initNetworkMonitoring() async {
    try {
      // Initialize the network inspector controller
      await _networkController.init();
      _addLog("Network controller initialized");
      
      // Initialize the FlutoCoreHttpManager with NetworkCallInterceptor
      _httpClient = FlutoCoreHttpManager();
      _addLog("HTTP client created");
      
      // Add the interceptor to capture network calls
      if (_networkController.interceptor != null) {
        _httpClient.addInterceptor(_networkController.interceptor!);
        _addLog("Network call interceptor added");
      }
      
      // Add some default headers
      _httpClient.addHeader('User-Agent', 'FlutoNetworkExample/1.0');
      
      _addLog("Network monitoring initialized successfully");
    } catch (e) {
      _addLog("Error initializing network monitoring: $e");
    }
  }

  Future<void> _makeGetRequest() async {
    try {
      _addLog("Making GET request to jsonplaceholder.typicode.com...");
      final request = http.Request('GET', Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
      final response = await _httpClient.sendRequest(request);
      _addLog("GET request complete: ${response.statusCode}");
    } catch (e) {
      _addLog("Error in GET request: ${_getDetailedErrorMessage(e)}");
    }
  }

  Future<void> _makePostRequest() async {
    try {
      _addLog("Making POST request to jsonplaceholder.typicode.com...");
      final request = http.Request('POST', Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      request.headers['Content-Type'] = 'application/json; charset=UTF-8';
      request.body = jsonEncode(<String, String>{
        'title': 'Test Post',
        'body': 'This is a test post',
        'userId': '1',
      });
      final response = await _httpClient.sendRequest(request);
      _addLog("POST request complete: ${response.statusCode}");
    } catch (e) {
      _addLog("Error in POST request: ${_getDetailedErrorMessage(e)}");
    }
  }

  Future<void> _makePutRequest() async {
    try {
      _addLog("Making PUT request to jsonplaceholder.typicode.com...");
      final request = http.Request('PUT', Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
      request.headers['Content-Type'] = 'application/json; charset=UTF-8';
      request.body = jsonEncode(<String, String>{
        'id': '1',
        'title': 'Updated Title',
        'body': 'This post has been updated',
        'userId': '1',
      });
      final response = await _httpClient.sendRequest(request);
      _addLog("PUT request complete: ${response.statusCode}");
    } catch (e) {
      _addLog("Error in PUT request: ${_getDetailedErrorMessage(e)}");
    }
  }

  Future<void> _makeDeleteRequest() async {
    try {
      _addLog("Making DELETE request to jsonplaceholder.typicode.com...");
      final request = http.Request('DELETE', Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
      final response = await _httpClient.sendRequest(request);
      _addLog("DELETE request complete: ${response.statusCode}");
    } catch (e) {
      _addLog("Error in DELETE request: ${_getDetailedErrorMessage(e)}");
    }
  }
  
  // Helper method to provide more meaningful error messages
  String _getDetailedErrorMessage(dynamic error) {
    if (error is ClientException) {
      if (error.message.contains('SocketException')) {
        return 'Network connection error. Please check your internet connection and app permissions.';
      }
      return 'HTTP client error: ${error.message}';
    } else if (error is SocketException) {
      return 'Network connection failed. Please check your internet connection and app permissions.';
    } else if (error is TimeoutException) {
      return 'Request timed out. Server might be slow or unreachable.';
    }
    return error.toString();
  }

  void _addLog(String log) {
    setState(() {
      _logs.add("${DateTime.now().toString().substring(11, 19)}: $log");
      if (_logs.length > 100) {
        _logs.removeAt(0);
      }
    });
  }

  void _openNetworkInspector() {
    if (_networkController.networkStorage == null) {
      _addLog("Network storage not initialized");
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NetworksListScreen(
          storage: _networkController.networkStorage!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _openNetworkInspector,
            tooltip: 'Open Network Inspector',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Make network requests to see them in the inspector',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _makeGetRequest,
                child: const Text('GET Request'),
              ),
              ElevatedButton(
                onPressed: _makePostRequest,
                child: const Text('POST Request'),
              ),
              ElevatedButton(
                onPressed: _makePutRequest,
                child: const Text('PUT Request'),
              ),
              ElevatedButton(
                onPressed: _makeDeleteRequest,
                child: const Text('DELETE Request'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Activity Log',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: _openNetworkInspector,
                  child: const Text('Open Network Inspector'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final reversedIndex = _logs.length - 1 - index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Text(_logs[reversedIndex]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}