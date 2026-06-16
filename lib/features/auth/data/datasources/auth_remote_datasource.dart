import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/core/constants/api_constants.dart';
import 'package:storemate/features/auth/data/models/auth_response.dart';

/// Remote datasource for StoreMate backend auth endpoints.
class AuthRemoteDatasource {
  final DioClient _client;

  AuthRemoteDatasource(this._client);

  /// POST /auth/login
  ///
  /// Sends the Firebase ID token to the backend for verification.
  /// Returns [AuthResponse] with JWT, user, shop, and onboarding status.
  Future<AuthResponse> login(String firebaseToken) async {
    final response = await _client.post(
      ApiConstants.login,
      data: {'firebaseToken': firebaseToken},
    );

    // Backend wraps response in { success, statusCode, data, ... }
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;

    return AuthResponse.fromJson(data);
  }

  /// GET /auth/profile
  ///
  /// Validates the stored JWT and returns the user's profile.
  /// Used on app startup to check if the session is still valid.
  Future<ProfileResponse> getProfile() async {
    final response = await _client.get(ApiConstants.profile);

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;

    return ProfileResponse.fromJson(data);
  }

  /// POST /auth/logout
  ///
  /// Notifies the backend of logout (for future token blacklisting).
  Future<void> logout() async {
    await _client.post(ApiConstants.logout);
  }
}
