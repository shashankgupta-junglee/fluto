# Networking UI Example

A sample Flutter application that demonstrates how to use the networking_ui package for inspecting network calls in your application.

## Getting Started

This example shows how to integrate and use the network inspector functionality provided by the networking_ui package.

### Features

- Initialization of the network inspection controller
- Making different types of HTTP requests (GET, POST, PUT, DELETE)
- Displaying network calls in a dedicated inspector UI
- Filtering network calls by request method

### Running the Example

1. Make sure you have Flutter installed and configured
2. Clone the repository 
3. Navigate to the example directory
4. Run the following commands:

```bash
flutter pub get
flutter run
```

### How to Use

1. Launch the app
2. Use the buttons to make different types of network requests
3. Click on the "Open Network Inspector" button or the bug icon in the app bar to open the network inspector
4. View the details of each network call including request/response headers, body, and timing information
5. Use the filter functionality to filter calls by HTTP method

## Implementation Details

The example demonstrates how to:

1. Initialize the NetworkInspectorPluginController
2. Make HTTP requests using the http package
3. Navigate to the NetworksListScreen to view intercepted network calls
4. Filter and search through network requests

## Related Projects

- fluto_core: Core library for Fluto framework
- networking_ui: UI components for network inspection