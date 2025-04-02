import 'package:http/http.dart';
import 'package:networking_ui/src/network/new_core_http_client.dart';

import 'infospect_network_call.dart';
import 'network_inspector_router.dart';


class NetworkCallInterceptor extends HttpInterceptor {
  final NetworkInspectorRouter router;

  NetworkCallInterceptor({required this.router});

  @override
  Future<void> onComplete(
    BaseRequest request,
    Response? response,
    dynamic error,
    StackTrace? stackTrace,
    DateTime requestTime,
    DateTime? responseTime,
  ) async {
    final InfospectNetworkRequest networkRequest = _onRequest(
      request,
      requestTime,
    );
    final InfospectNetworkResponse networkResponse = _onResponse(
      response,
      responseTime,
    );
    final InfospectNetworkError networkError = InfospectNetworkError(
      error: error,
      stackTrace: stackTrace,
    );
    final InfospectNetworkCall networkCall = InfospectNetworkCall(
      response?.hashCode ?? request.hashCode,
      request: networkRequest,
      method: request.method,
      response: networkResponse,
      error: error != null || stackTrace != null ? networkError : null,
      duration: responseTime == null
          ? 0
          : responseTime.difference(requestTime).inMilliseconds,
      loading: false,
      server: request.url.host,
    );

    router.addNetworkCall(networkCall);
  }

  InfospectNetworkRequest _onRequest(
      BaseRequest request, DateTime requestTime) {
    dynamic requestBody = '';
    int requestSize = 0;
    final List<InfospectFormDataFile> files = [];
    final List<InfospectFormDataField> fields = [];

    if (request is Request && request.body.isNotEmpty) {
      requestBody = request.body;
      requestSize = request.bodyBytes.length;
    }

    if (request is MultipartRequest) {
      request.fields.forEach((key, value) {
        fields.add(InfospectFormDataField(key, value));
      });

      for (final entry in request.files) {
        files.add(
          InfospectFormDataFile(
            entry.filename,
            entry.contentType.toString(),
            entry.length,
          ),
        );
      }
    } else if (request is Request) {
      try {
        if (request.body.isNotEmpty) {
          requestBody = request.body;
        }
      } catch (e) {
        // TODO:// ADD LOGS (@vidya)
      }
      requestSize = request.bodyBytes.length;
    }
    return InfospectNetworkRequest(
      body: requestBody,
      size: requestSize,
      formDataFields: fields,
      formDataFiles: files,
      headers: request.headers,
      contentType: request.headers['content-type'],
      queryParameters: request.url.queryParameters,
      requestTime: requestTime,
      method: request.method,
      url: request.url,
    );
  }

  InfospectNetworkResponse _onResponse(
    Response? response,
    DateTime? responseTime,
  ) {
    final networkResponse = InfospectNetworkResponse(
      size: response == null ? 0 : response.bodyBytes.length,
      headers: response?.headers,
      status: response?.statusCode,
      body: response?.body,
      responseTime: responseTime,
    );
    return networkResponse;
  }
}
