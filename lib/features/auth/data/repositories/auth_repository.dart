import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:storemate/core/constants/app_constants.dart';
import 'package:storemate/core/storage/secure_storage_service.dart';
import 'package:storemate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:storemate/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:storemate/features/auth/data/models/auth_response.dart';
import 'package:storemate/features/auth/data/models/user_model.dart';
import 'package:storemate/features/shop/data/models/shop_model.dart';
import 'dart:convert';

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

  Future<void> _cacheProfile(UserModel user, ShopModel? shop) async {
    await _storage.write('cached_user', jsonEncode(user.toJson()));
    if (shop != null) {
      await _storage.write('cached_shop', jsonEncode(shop.toJson()));
    } else {
      await _storage.delete('cached_shop');
    }
  }

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

    // Step 3: Store JWT and cache profile
    await _storage.write(
      AppConstants.storageKeyAccessToken,
      authResponse.accessToken,
    );
    await _cacheProfile(authResponse.user, authResponse.shop);

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
    await _cacheProfile(authResponse.user, authResponse.shop);

    return authResponse;
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);
      
      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        // Expired if current time is past expiration, or within 5 minutes of it
        return now >= (exp - 300);
      }
      return false;
    } catch (e) {
      return true; // If we can't parse it, consider it expired
    }
  }

  /// Check if there is a stored session and validate it.
  ///
  /// Used on app startup (splash screen) to determine initial navigation.
  /// Returns a tuple of (user, shop, onboardingRequired) if session is valid.
  Future<({UserModel user, ShopModel? shop, bool onboardingRequired})?> restoreSession() async {
    debugPrint('Storage Start: ${DateTime.now().toIso8601String()}');
    String? token;
    try {
      token = await _storage.read(AppConstants.storageKeyAccessToken).timeout(const Duration(seconds: 10));
      debugPrint('Storage Complete: ${DateTime.now().toIso8601String()}');
    } catch (e) {
      debugPrint('Secure storage read exception/timeout: $e');
      return null;
    }

    if (token == null || token.isEmpty) {
      debugPrint('AuthRepository: No stored token');
      return null;
    }

    try {
      debugPrint('JWT validation start');
      if (_isTokenExpired(token)) {
        debugPrint('Token is expired, minting new token via auth-bridge');
        var currentUser = FirebaseAuth.instance.currentUser;
        currentUser ??= await FirebaseAuth.instance.authStateChanges().first;
        if (currentUser != null) {
          final firebaseToken = await currentUser.getIdToken(true);
          if (firebaseToken != null) {
            token = await _remoteDatasource.mintCustomToken(firebaseToken);
            await _storage.write(AppConstants.storageKeyAccessToken, token);
          } else {
             throw Exception('Failed to get fresh Firebase token');
          }
        } else {
           throw Exception('Firebase user is null');
        }
      }

      debugPrint('Profile request start');
      final profile = await _remoteDatasource.getProfile(token);
      debugPrint('Profile request success');
      debugPrint('JWT validation success');
      debugPrint('AuthRepository: Session restored for user ${profile.user.id}');
      
      await _cacheProfile(profile.user, profile.shop);
      
      return (
        user: profile.user,
        shop: profile.shop,
        onboardingRequired: profile.onboardingRequired,
      );
    } catch (e) {
      debugPrint('Profile request exception: $e');
      debugPrint('JWT validation exception: $e');
      debugPrint('AuthRepository: Session restore failed — $e');
      
      // Only delete token if it's explicitly an auth error (e.g. expired or invalid)
      if (e.toString().contains('JWT') || e.toString().contains('AuthException') || e.toString().contains('401')) {
        await _storage.delete(AppConstants.storageKeyAccessToken);
        await _storage.delete('cached_user');
        await _storage.delete('cached_shop');
        return null;
      }
      
      // Fallback to cached profile
      try {
        final cachedUserStr = await _storage.read('cached_user');
        final cachedShopStr = await _storage.read('cached_shop');
        
        if (cachedUserStr != null) {
          final user = UserModel.fromJson(jsonDecode(cachedUserStr));
          ShopModel? shop;
          if (cachedShopStr != null) {
            shop = ShopModel.fromJson(jsonDecode(cachedShopStr));
          }
          debugPrint('AuthRepository: Restored from offline cache');
          return (
            user: user,
            shop: shop,
            onboardingRequired: shop == null,
          );
        }
      } catch (cacheErr) {
        debugPrint('AuthRepository: Cache read failed: $cacheErr');
      }
      
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
