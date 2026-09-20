import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/providers/core_providers.dart';
import 'package:storemate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:storemate/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:dio/dio.dart';
import 'package:storemate/features/auth/data/repositories/auth_repository.dart';
import 'package:storemate/features/auth/domain/auth_state.dart';

/// Provider for [FirebaseAuthDatasource].
final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  return FirebaseAuthDatasource();
});

/// Provider for [AuthRemoteDatasource].
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDatasource(dioClient);
});

/// Provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    firebaseDatasource: ref.watch(firebaseAuthDatasourceProvider),
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

/// Main auth state provider.
///
/// Controls the entire authentication lifecycle:
/// - Session restoration on app start
/// - OTP send/verify flow
/// - Backend login
/// - Logout
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// StateNotifier managing authentication state transitions.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState.initial());

  /// Check for an existing session on app startup.
  /// Called from the splash screen.
  Future<void> checkAuthStatus() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      isLoading: true,
    );

    try {
      debugPrint('Auth Start: ${DateTime.now().toIso8601String()}');
      final session = await _repository.restoreSession().timeout(const Duration(seconds: 15));
      debugPrint('Auth Complete: ${DateTime.now().toIso8601String()}');

      if (session == null) {
        state = AuthState.unauthenticated();
        return;
      }

      if (session.onboardingRequired) {
        state = state.copyWith(
          status: AuthStatus.onboardingRequired,
          user: session.user,
          shop: session.shop,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: session.user,
          shop: session.shop,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('AuthNotifier: checkAuthStatus failed/timed out — $e');
      state = AuthState.unauthenticated(); // Clean fallback to Login
    }
  }

  /// Send OTP to the phone number.
  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    debugPrint('AuthNotifier: OTP Request Started for $phoneNumber');
    try {
      await _repository.sendOtp(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) {
          debugPrint('AuthNotifier: Code Sent Callback Triggered - ID: $verificationId');
          state = state.copyWith(
            verificationId: verificationId,
            isOtpSent: true,
            isLoading: false,
          );
        },
        onAutoVerified: (PhoneAuthCredential credential) {
          debugPrint('AuthNotifier: Auto Verification Triggered');
          _handleAutoVerification(credential);
        },
        onError: (errorMessage) {
          debugPrint('AuthNotifier: Verification Failed Callback Triggered - Error: $errorMessage');
          state = state.copyWith(
            isLoading: false,
            errorMessage: errorMessage,
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthNotifier: FirebaseAuthException during sendOtp - Code: ${e.code}, Message: ${e.message}');
      String message;
      switch (e.code) {
        case 'invalid-phone-number':
          message = 'The provided phone number is not valid.';
          break;
        case 'too-many-requests':
          message = 'Too many requests. Please try again later.';
          break;
        case 'app-not-authorized':
          message = 'App verification failed. Please ensure the app is genuine and try again.';
          break;
        case 'operation-not-allowed':
          message = 'Phone authentication is not enabled for this project.';
          break;
        default:
          message = e.message ?? 'An unknown Firebase error occurred.';
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: message,
      );
    } catch (e) {
      debugPrint('AuthNotifier: Unexpected error during sendOtp - $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send OTP. Please check your connection and try again.',
      );
    }
  }

  /// Handle auto-verification (Android only).
  Future<void> _handleAutoVerification(PhoneAuthCredential credential) async {
    state = state.copyWith(isLoading: true);

    try {
      final authResponse = await _repository.loginWithCredential(credential);

      if (authResponse.onboardingRequired) {
        state = state.copyWith(
          status: AuthStatus.onboardingRequired,
          user: authResponse.user,
          accessToken: authResponse.accessToken,
          isLoading: false,
          isOtpSent: false,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: authResponse.user,
          shop: authResponse.shop,
          accessToken: authResponse.accessToken,
          isLoading: false,
          isOtpSent: false,
        );
      }
    } on DioException catch (e) {
      String message;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Server is taking too long to respond. Please try again.';
          break;
        case DioExceptionType.connectionError:
          message = 'No internet connection. Please check your network and try again.';
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 401 || statusCode == 403) {
            message = 'Authentication failed. You do not have permission to access this.';
          } else if (statusCode != null && statusCode >= 500) {
            message = 'Temporary server error. Please try again later.';
          } else {
            message = 'An unexpected error occurred. Please try again.';
          }
          break;
        default:
          if (e.error is SocketException) {
            message = 'No internet connection. Please check your network and try again.';
          } else {
            message = 'An unexpected error occurred. Please try again.';
          }
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Auto-verification failed. Please enter OTP manually.',
      );
    }
  }

  /// Verify OTP code and login.
  Future<void> verifyOtp(String smsCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final authResponse = await _repository.verifyOtpAndLogin(smsCode);

      if (authResponse.onboardingRequired) {
        state = state.copyWith(
          status: AuthStatus.onboardingRequired,
          user: authResponse.user,
          accessToken: authResponse.accessToken,
          isLoading: false,
          isOtpSent: false,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: authResponse.user,
          shop: authResponse.shop,
          accessToken: authResponse.accessToken,
          isLoading: false,
          isOtpSent: false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-verification-code':
          message = 'Invalid OTP. Please check and try again.';
          break;
        case 'session-expired':
          message = 'OTP expired. Please request a new one.';
          break;
        default:
          message = e.message ?? 'Verification failed. Please try again.';
      }
      state = state.copyWith(isLoading: false, errorMessage: message);
    } on DioException catch (e) {
      String message;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Server is taking too long to respond. Please try again.';
          break;
        case DioExceptionType.connectionError:
          message = 'No internet connection. Please check your network and try again.';
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 401 || statusCode == 403) {
            message = 'Authentication failed. You do not have permission to access this.';
          } else if (statusCode != null && statusCode >= 500) {
            message = 'Temporary server error. Please try again later.';
          } else {
            message = 'An unexpected error occurred. Please try again.';
          }
          break;
        default:
          if (e.error is SocketException) {
            message = 'No internet connection. Please check your network and try again.';
          } else {
            message = 'An unexpected error occurred. Please try again.';
          }
          debugPrint('AuthNotifier: Unknown parsing error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: message,
      );
    } catch (e) {
      debugPrint('AuthNotifier: Unknown error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Update state after successful shop registration.
  void onShopRegistered({
    required dynamic shop,
  }) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      shop: shop,
    );
  }

  /// Logout: clear all state, storage, and Firebase session.
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    await _repository.logout();

    state = AuthState.unauthenticated();
  }

  /// Clear any error message.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset OTP state (e.g., user goes back from OTP screen).
  void resetOtpState() {
    state = state.copyWith(
      isOtpSent: false,
      verificationId: null,
      errorMessage: null,
    );
  }
}
