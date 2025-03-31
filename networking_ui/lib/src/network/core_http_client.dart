// ignore_for_file: unnecessary_getters_setters

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';

typedef RequestInterceptor = Future<dynamic> Function(BaseRequest, {bool skipContentType});
typedef ResponseInterceptor = Future<dynamic> Function(BaseResponse);

class CoreHttpManager extends BaseClient {
  CoreHttpManager({
    this.requestInterceptor,
    this.responseInterceptor,
  }) {
    // Configure platform-specific client settings
    _configurePlatformSpecificSettings();
  }

  Map<String, String> _headers = <String, String>{};

  RequestInterceptor? requestInterceptor;
  ResponseInterceptor? responseInterceptor;
  Function(Map<String, dynamic>)? onMaintenance;
  late Client client;

  void _configurePlatformSpecificSettings() {
    // Create a client with appropriate settings
    if (Platform.isMacOS || Platform.isIOS) {
      // On macOS/iOS, use the HttpClient with more permissive security settings
      final httpClient = HttpClient()
        ..connectionTimeout = const Duration(seconds: 15)
        ..badCertificateCallback = (cert, host, port) => true; // Accept all certificates
      
      client = IOClient(httpClient);
    } else {
      // For other platforms, use the standard Client
      client = Client();
    }
  }

  void setMaintenanceHandler(Function(Map<String, dynamic>) onMaintenance) {
    onMaintenance = onMaintenance;
  }

  Map<String, String> get headers => _headers;
  set headers(Map<String, String> values) {
    _headers = values;
  }

  void addHeader(String name, String value) {
    _headers[name] = value;
  }

  void removeHeader(String name) {
    _headers.remove(name);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    // Add the default headers to the request
    _headers.forEach((String name, dynamic value) {
      if (!request.headers.containsKey(name)) {
        request.headers[name] = _headers[name] ?? "";
      }
    });
    
    return client.send(request);
  }

  Future<Response> sendRequest(BaseRequest request, {bool skipContentType = false, Duration? timeout}) async {
    _headers.forEach((String name, dynamic value) {
      request.headers[name] = _headers[name] ?? "";
    });

    await requestInterceptor?.call(request, skipContentType: skipContentType);

    return send(request).then((StreamedResponse onValue) async {
      final Response response = await Response.fromStream(onValue);

      await responseInterceptor?.call(response);

      try {
        checkForMaintenance(response);
      } catch (_) {}

      return response;
    }).timeout(
      timeout ?? const Duration(seconds: 15), // Extended timeout
      onTimeout: () {
        return Response(
          json.encode(
            <String, dynamic>{
              "type": "fail",
              "message": "Oops! It looks like this took longer than expected. Please try again!",
              "data": <String, dynamic>{},
            },
          ),
          HttpStatus.clientClosedRequest,
          request: request,
        );
      },
    );
  }

  checkForMaintenance(dynamic response) {
    if (onMaintenance != null && response.body?.toString() != "" && (response.statusCode >= 200 && response.statusCode <= 299)) {
      Map<String, dynamic> body = json.decode(response.body);
      dynamic data = body["data"];
      if (data is Map && data["underMaintenance"] == true) {
        onMaintenance?.call(data.cast());
      }
    }
  }
}

// class HttpClientMobile extends IHttpClient {
//   @override
//   Future<StreamedResponse> send(BaseRequest request) {
//     return Client().send(request);
//   }
// }

// IHttpClient getHttpClient() {
//   return HttpClientMobile();
// }



// abstract class IHttpClient {
//   Future<StreamedResponse> send(BaseRequest request);
// }

