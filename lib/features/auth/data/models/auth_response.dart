import 'package:storemate/features/auth/data/models/user_model.dart';
import 'package:storemate/features/shop/data/models/shop_model.dart';

/// Response from POST /auth/login.
class AuthResponse {
  final String accessToken;
  final UserModel user;
  final ShopModel? shop;
  final bool onboardingRequired;

  const AuthResponse({
    required this.accessToken,
    required this.user,
    this.shop,
    required this.onboardingRequired,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      shop: json['shop'] != null
          ? ShopModel.fromJson(json['shop'] as Map<String, dynamic>)
          : null,
      onboardingRequired: json['onboardingRequired'] as bool,
    );
  }
}

/// Response from GET /auth/profile.
class ProfileResponse {
  final UserModel user;
  final ShopModel? shop;
  final bool onboardingRequired;

  const ProfileResponse({
    required this.user,
    this.shop,
    required this.onboardingRequired,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      shop: json['shop'] != null
          ? ShopModel.fromJson(json['shop'] as Map<String, dynamic>)
          : null,
      onboardingRequired: json['onboardingRequired'] as bool,
    );
  }
}
