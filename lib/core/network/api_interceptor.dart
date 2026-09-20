import 'package:dio/dio.dart';
import 'package:storemate/core/storage/secure_storage_service.dart';
import 'package:storemate/core/constants/app_constants.dart';

/// Dio interceptor that:
/// 1. Injects the JWT Bearer token into every request
/// 2. Logs request/response in debug mode
/// 3. Handles 401 responses (token expired)
class ApiInterceptor extends Interceptor {
  final SecureStorageService _storage;

  ApiInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Inject Authorization header if token exists
    final token = await _storage.read(AppConstants.storageKeyAccessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Graceful error handling for UI providers
    String? userMessage;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      userMessage = 'Network timeout. Please check your connection.';
    } else if (err.type == DioExceptionType.connectionError) {
      userMessage = 'Unable to connect to server. Please check your internet connection.';
    } else if (err.response != null) {
      final statusCode = err.response!.statusCode;
      if (statusCode == 401) {
        // userMessage = 'Your session has expired. Please log in again.';
        userMessage = err.response?.data['message'] ?? err.response?.data['error'] ?? 'Authentication failed (401).';
      } else if (statusCode == 500 || statusCode == 502 || statusCode == 503) {
        userMessage = 'The server is currently unavailable. Please try again later.';
      }
    }

    if (userMessage != null) {
      // Inject the user-friendly message into the response data
      // so downstream repositories can easily extract it.
      if (err.response != null) {
        err.response!.data = {'message': userMessage};
      } else {
        final mockResponse = Response(
          requestOptions: err.requestOptions,
          data: {'message': userMessage},
        );
        final newErr = err.copyWith(response: mockResponse);
        return handler.next(newErr);
      }
    }

    handler.next(err);
  }
}
