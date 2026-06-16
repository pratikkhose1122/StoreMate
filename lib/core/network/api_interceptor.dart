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
    // On 401, the auth provider will handle logout/redirect
    // We just pass the error through
    handler.next(err);
  }
}
