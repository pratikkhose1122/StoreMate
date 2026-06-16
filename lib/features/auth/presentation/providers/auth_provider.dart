import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/providers/core_providers.dart';
import 'package:storemate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:storemate/features/auth/data/datasources/firebase_auth_datasource.dart';
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
      final session = await _repository.restoreSession();

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
      debugPrint('AuthNotifier: checkAuthStatus failed — $e');
      state = AuthState.unauthenticated();
    }
  }

  /// Send OTP to the phone number.
  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    await _repository.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        state = state.copyWith(
          verificationId: verificationId,
          isOtpSent: true,
          isLoading: false,
        );
      },
      onAutoVerified: (PhoneAuthCredential credential) {
        _handleAutoVerification(credential);
      },
      onError: (errorMessage) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        );
      },
    );
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Login failed. Please try again.',
      );
    }
  }

  /// Update state after successful shop registration.
  void onShopRegistered({
    required String accessToken,
    required dynamic shop,
  }) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      accessToken: accessToken,
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
