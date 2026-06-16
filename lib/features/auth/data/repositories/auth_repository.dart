import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:storemate/core/constants/app_constants.dart';
import 'package:storemate/core/storage/secure_storage_service.dart';
import 'package:storemate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:storemate/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:storemate/features/auth/data/models/auth_response.dart';
import 'package:storemate/features/auth/data/models/user_model.dart';
import 'package:storemate/features/shop/data/models/shop_model.dart';

/// Repository coordinating Firebase Auth and backend API for authentication.
///
/// This is the single source of truth for auth operations, orchestrating:
/// - Firebase Phone Auth (OTP send/verify)
/// - Backend login (Firebase token → JWT)
/// - Token persistence (secure storage)
/// - Session restoration (auto-login)
/// - Logout (clear everything)
class AuthRepository {
  final FirebaseAuthDatasource _firebaseDatasource;
  final AuthRemoteDatasource _remoteDatasource;
  final SecureStorageService _storage;

  AuthRepository({
    required FirebaseAuthDatasource firebaseDatasource,
    required AuthRemoteDatasource remoteDatasource,
    required SecureStorageService storage,
  })  : _firebaseDatasource = firebaseDatasource,
        _remoteDatasource = remoteDatasource,
        _storage = storage;

  /// Send OTP to the phone number via Firebase.
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    required void Function(String errorMessage) onError,
  }) async {
    final fullNumber = '${AppConstants.countryCode}$phoneNumber';
    await _firebaseDatasource.sendOtp(
      phoneNumber: fullNumber,
      onCodeSent: onCodeSent,
      onAutoVerified: onAutoVerified,
      onError: onError,
    );
  }

  /// Verify OTP and authenticate with the backend.
  ///
  /// Returns [AuthResponse] with JWT, user, shop, and onboarding status.
  /// Stores the JWT in secure storage.
  Future<AuthResponse> verifyOtpAndLogin(String smsCode) async {
    // Step 1: Verify OTP with Firebase
    final firebaseToken = await _firebaseDatasource.verifyOtp(smsCode);

    // Step 2: Send Firebase token to backend
    final authResponse = await _remoteDatasource.login(firebaseToken);

    // Step 3: Store JWT
    await _storage.write(
      AppConstants.storageKeyAccessToken,
      authResponse.accessToken,
    );

    debugPrint('AuthRepository: Login successful, token stored');
    return authResponse;
  }

  /// Authenticate with the backend using a Firebase credential (auto-verified).
  Future<AuthResponse> loginWithCredential(
      PhoneAuthCredential credential) async {
    final firebaseToken =
        await _firebaseDatasource.signInWithCredential(credential);
    final authResponse = await _remoteDatasource.login(firebaseToken);

    await _storage.write(
      AppConstants.storageKeyAccessToken,
      authResponse.accessToken,
    );

    return authResponse;
  }

  /// Check if there is a stored session and validate it.
  ///
  /// Used on app startup (splash screen) to determine initial navigation.
  /// Returns a tuple of (user, shop, onboardingRequired) if session is valid.
  Future<({UserModel user, ShopModel? shop, bool onboardingRequired})?> restoreSession() async {
    debugPrint('Secure storage read start');
    String? token;
    try {
      token = await _storage.read(AppConstants.storageKeyAccessToken);
      debugPrint('Secure storage read success');
    } catch (e) {
      debugPrint('Secure storage read exception: $e');
      return null;
    }

    if (token == null || token.isEmpty) {
      debugPrint('AuthRepository: No stored token');
      return null;
    }

    try {
      debugPrint('JWT validation start');
      debugPrint('Profile request start');
      final profile = await _remoteDatasource.getProfile();
      debugPrint('Profile request success');
      debugPrint('JWT validation success');
      debugPrint('AuthRepository: Session restored for user ${profile.user.id}');
      return (
        user: profile.user,
        shop: profile.shop,
        onboardingRequired: profile.onboardingRequired,
      );
    } catch (e) {
      debugPrint('Profile request exception: $e');
      debugPrint('JWT validation exception: $e');
      debugPrint('AuthRepository: Session restore failed — $e');
      // Token is invalid or expired, clear it
      await _storage.delete(AppConstants.storageKeyAccessToken);
      return null;
    }
  }

  /// Logout: clear stored token, notify backend, sign out Firebase.
  Future<void> logout() async {
    try {
      await _remoteDatasource.logout();
    } catch (e) {
      debugPrint('AuthRepository: Backend logout failed — $e');
      // Continue with local cleanup even if backend call fails
    }

    await _storage.deleteAll();
    await _firebaseDatasource.signOut();
    debugPrint('AuthRepository: Logout complete');
  }

  /// Update the stored JWT (e.g., after shop registration returns a new token).
  Future<void> updateToken(String newToken) async {
    await _storage.write(AppConstants.storageKeyAccessToken, newToken);
  }
}
