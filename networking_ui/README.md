# Networking UI

A Flutter package that provides a UI for inspecting network calls in your application. This package is part of the Fluto framework and helps developers debug and monitor network activity in their Flutter apps.

## Features

- **Network Call Interception**: Automatically intercept and record HTTP requests and responses
- **Interactive UI**: Browse, filter, and inspect network calls in a user-friendly interface
- **Request/Response Details**: View headers, body content, and timing information
- **Filtering**: Filter network calls by HTTP method (GET, POST, PUT, DELETE, etc.)
- **Search**: Search through network calls by URL or content
- **Plugin Architecture**: Can be integrated with Fluto framework as a plugin

## Getting Started

To use this package, add `networking_ui` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  networking_ui:
    path: path/to/networking_ui
  # If using from pub.dev once published
  # networking_ui: ^1.0.0
```

## Usage

### Basic Setup

1. Initialize the NetworkInspectorPluginController:

```dart
final NetworkInspectorPluginController controller = NetworkInspectorPluginController();
await controller.init();
```

2. Access the network inspector UI:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => NetworksListScreen(
      storage: controller.networkStorage!,
    ),
  ),
);
```

### As a Fluto Plugin

If you're using the Fluto framework, you can register this as a plugin:

```dart
final networkController = NetworkInspectorPluginController();
await networkController.init();

final plugin = NetworkInspectorPlugin(controller: networkController);
// Register plugin with Fluto
```

## Example

Check out the [example](./example) folder for a complete example application demonstrating how to use this package.

The example shows:
- How to initialize the network inspector
- Making different types of HTTP requests
- Displaying and filtering network calls in the inspector UI

## Implementation Details

The package consists of:

1. **Network Call Interceptor**: Intercepts HTTP requests and responses
2. **Network Storage**: Stores network call data
3. **UI Components**: 
   - NetworksListScreen: Main screen showing the list of network calls
   - InterceptorDetailsScreen: Detailed view of a single network call
   - Filtering and search functionality

## Additional Information

### Compatibility

Works with Flutter stable channel and requires Dart SDK ^3.5.1.

### Dependencies

- flutter_bloc: For state management
- equatable: For value equality comparisons
- http: For HTTP requests support

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
