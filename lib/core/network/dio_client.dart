import 'package:dio/dio.dart';
import 'package:storemate/core/constants/api_constants.dart';
import 'package:storemate/core/network/api_interceptor.dart';
import 'package:storemate/core/storage/secure_storage_service.dart';

/// Configured Dio HTTP client for StoreMate API communication.
///
/// Features:
/// - Base URL pointing to NestJS backend
/// - Automatic JWT injection via [ApiInterceptor]
/// - Timeout configuration
/// - JSON content type headers
class DioClient {
  late final Dio dio;

  DioClient(SecureStorageService storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(ApiInterceptor(storage));
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) {
    return dio.post<T>(path, data: data, options: options);
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) {
    return dio.put<T>(path, data: data, options: options);
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) {
    return dio.patch<T>(path, data: data, options: options);
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) {
    return dio.delete<T>(path, data: data, options: options);
  }
}
