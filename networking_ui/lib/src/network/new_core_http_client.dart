import 'package:http/src/base_request.dart';
import 'package:http/src/response.dart';
import 'package:networking_ui/src/network/core_http_client.dart';

/// Abstract base class for HTTP interceptors
abstract class HttpInterceptor {
  /// Called before a request is sent
  Future<BaseRequest> onRequest(BaseRequest request) async => request;

  /// Called after a response is received
  Future<Response> onResponse(Response response, BaseRequest request) async =>
      response;

  /// Called when an error occurs during the request
  Future<dynamic> onError(
          dynamic error, StackTrace stackTrace, BaseRequest request) async =>
      error;

  /// Called when the request is complete (after response or error)
  Future<void> onComplete(
    BaseRequest request,
    Response? response,
    dynamic error,
    StackTrace? stackTrace,
    DateTime requestTime,
    DateTime? responseTime,
  ) async {}
}

class FlutoCoreHttpManager extends CoreHttpManager {
  FlutoCoreHttpManager({
    super.requestInterceptor,
    super.responseInterceptor,
    List<HttpInterceptor>? interceptors,
  }) : _interceptors = interceptors ?? [];

  final List<HttpInterceptor> _interceptors;

  /// Adds an interceptor to the chain
  void addInterceptor(HttpInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  /// Removes an interceptor from the chain
  void removeInterceptor(HttpInterceptor interceptor) {
    _interceptors.remove(interceptor);
  }

  @override
  Future<Response> sendRequest(
    BaseRequest request, {
    bool skipContentType = false,
    Duration? timeout,
  }) async {
    final DateTime requestTime = DateTime.now();
    DateTime? responseTime;
    Response? apiResponse;
    dynamic error;
    StackTrace? stackTrace;

    // Process request interceptors
    BaseRequest processedRequest = request;
    try {
      for (final interceptor in _interceptors) {
        processedRequest = await interceptor.onRequest(processedRequest);
      }

      final Response response = await super.sendRequest(processedRequest,
          timeout: timeout, skipContentType: skipContentType);
      responseTime = DateTime.now();

      // Process response interceptors
      apiResponse = response;
      for (final interceptor in _interceptors) {
        // We know apiResponse is non-null here since we just assigned it
        apiResponse = await interceptor.onResponse(
          apiResponse!,
          processedRequest,
        );
      }

      return apiResponse!; // Safe to use non-null assertion as it's initialized above
    } catch (e, s) {
      error = e;
      stackTrace = s;

      // Process error interceptors
      for (final interceptor in _interceptors) {
        try {
          error = await interceptor.onError(
            error,
            stackTrace,
            processedRequest,
          );
        } catch (interceptorError) {
          // Ignore errors from interceptors to ensure all are processed
        }
      }

      rethrow;
    } finally {
      // Call onComplete for all interceptors
      for (final interceptor in _interceptors) {
        try {
          await interceptor.onComplete(
            processedRequest,
            apiResponse,
            error,
            stackTrace,
            requestTime,
            responseTime,
          );
        } catch (e) {
          // Ignore errors in onComplete to ensure all interceptors are called
        }
      }
    }
  }
}
