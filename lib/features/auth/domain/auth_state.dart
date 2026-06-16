import 'package:storemate/features/auth/data/models/user_model.dart';
import 'package:storemate/features/shop/data/models/shop_model.dart';

/// Possible states during the authentication lifecycle.
enum AuthStatus {
  /// App just started, auth state unknown
  initial,

  /// Checking stored token on splash
  loading,

  /// No valid session — show login screen
  unauthenticated,

  /// Valid session, user has a shop — show dashboard
  authenticated,

  /// Valid session, but no shop — show registration
  onboardingRequired,

  /// An error occurred during authentication
  error,
}

/// Immutable state class for authentication.
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final ShopModel? shop;
  final String? accessToken;
  final String? errorMessage;

  /// Verification ID from Firebase (used during OTP flow)
  final String? verificationId;

  /// Whether OTP has been sent and we're waiting for user input
  final bool isOtpSent;

  /// Whether a network operation is in progress
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.shop,
    this.accessToken,
    this.errorMessage,
    this.verificationId,
    this.isOtpSent = false,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    ShopModel? shop,
    String? accessToken,
    String? errorMessage,
    String? verificationId,
    bool? isOtpSent,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      shop: shop ?? this.shop,
      accessToken: accessToken ?? this.accessToken,
      errorMessage: errorMessage ?? this.errorMessage,
      verificationId: verificationId ?? this.verificationId,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Factory for the initial state.
  factory AuthState.initial() => const AuthState();

  /// Factory for unauthenticated state.
  factory AuthState.unauthenticated() => const AuthState(
        status: AuthStatus.unauthenticated,
      );

  /// Factory for error state.
  factory AuthState.error(String message) => AuthState(
        status: AuthStatus.error,
        errorMessage: message,
      );
}
