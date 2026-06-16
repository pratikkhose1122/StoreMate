import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Wrapper around Firebase Phone Authentication.
///
/// Handles the complete OTP flow:
/// 1. Send OTP to phone number
/// 2. Listen for auto-retrieval (Android)
/// 3. Verify OTP code manually
/// 4. Return Firebase ID token for backend authentication
class FirebaseAuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;

  /// Send OTP to the given phone number.
  ///
  /// [phoneNumber] should include country code, e.g., "+919876543210"
  ///
  /// Returns a Future that completes when:
  /// - OTP is sent (codeSent callback fires)
  /// - Auto-verification completes (Android)
  /// - An error occurs
  ///
  /// Throws [FirebaseAuthException] on failure.
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    required void Function(String errorMessage) onError,
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: forceResendingToken ?? _resendToken,

      // Called when OTP is successfully sent
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        debugPrint('FirebaseAuth: OTP sent to $phoneNumber');
        onCodeSent(verificationId);
      },

      // Called when Android auto-detects the OTP
      verificationCompleted: (PhoneAuthCredential credential) {
        debugPrint('FirebaseAuth: Auto-verification completed');
        onAutoVerified(credential);
      },

      // Called on error
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('FirebaseAuth: Verification failed - ${e.message}');
        String message;
        switch (e.code) {
          case 'invalid-phone-number':
            message = 'The phone number is invalid.';
            break;
          case 'too-many-requests':
            message = 'Too many attempts. Please try again later.';
            break;
          case 'quota-exceeded':
            message = 'SMS quota exceeded. Please try again later.';
            break;
          default:
            message = e.message ?? 'Verification failed. Please try again.';
        }
        onError(message);
      },

      // Called when auto-retrieval times out
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        debugPrint('FirebaseAuth: Auto-retrieval timeout');
      },
    );
  }

  /// Verify the OTP code entered by the user.
  ///
  /// Returns the Firebase ID token on success.
  /// Throws an exception on failure.
  Future<String> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      throw Exception('No verification ID. Please request OTP first.');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    return _signInWithCredential(credential);
  }

  /// Sign in with a [PhoneAuthCredential] (from manual OTP or auto-verification).
  ///
  /// Returns the Firebase ID token.
  Future<String> signInWithCredential(PhoneAuthCredential credential) async {
    return _signInWithCredential(credential);
  }

  Future<String> _signInWithCredential(PhoneAuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) {
      throw Exception('Firebase sign-in failed: no user returned');
    }

    final idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to get Firebase ID token');
    }

    debugPrint('FirebaseAuth: Sign-in successful, UID: ${user.uid}');
    return idToken;
  }

  /// Get the current Firebase ID token (for token refresh).
  Future<String?> getCurrentIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return user.getIdToken(true);
  }

  /// Sign out from Firebase.
  Future<void> signOut() async {
    await _auth.signOut();
    _verificationId = null;
    _resendToken = null;
    debugPrint('FirebaseAuth: Signed out');
  }

  /// Get the resend token for re-sending OTP.
  int? get resendToken => _resendToken;

  /// Check if a user is currently signed in to Firebase.
  bool get isSignedIn => _auth.currentUser != null;
}
