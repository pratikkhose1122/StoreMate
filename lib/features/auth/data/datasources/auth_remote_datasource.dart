import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthResponse;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:storemate/core/storage/secure_storage_service.dart';
import 'package:storemate/core/config/app_config.dart';
import 'package:storemate/core/constants/app_constants.dart';
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/features/auth/data/models/auth_response.dart';
import 'package:storemate/features/auth/data/models/user_model.dart';
import 'package:storemate/features/shop/data/models/shop_model.dart';

/// Remote datasource for StoreMate authentication using Supabase.
class AuthRemoteDatasource {
  final DioClient? _client;
  SupabaseClient get _supabase => Supabase.instance.client;

  AuthRemoteDatasource([this._client]);

  /// Exchange a Firebase token for a Supabase custom JWT
  Future<String> mintCustomToken(String firebaseToken) async {
    debugPrint('AuthRemoteDatasource: Calling auth-bridge Edge Function for new token');
    final res = await _supabase.functions.invoke(
      'auth-bridge',
      headers: {'Authorization': 'Bearer $firebaseToken'},
    );
    return res.data['access_token'] as String;
  }

  /// Authenticate user profile with Supabase DB after Firebase OTP verification.
  Future<AuthResponse> login(String firebaseToken, {void Function(String message)? onRetry}) async {
    debugPrint('AuthRemoteDatasource: Processing login with Supabase DB');
    
    final currentUser = fb.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('Firebase user is null');
    }

    final firebaseUid = currentUser.uid;
    final phoneNumber = currentUser.phoneNumber ?? '';
    final normalizedPhone = phoneNumber.replaceAll('+91', '').replaceAll('+', '');

    // 1. Call Edge Function to bridge Firebase Auth to Supabase Auth
    final customToken = await mintCustomToken(firebaseToken);
    
    // 2. We skip _supabase.auth.setSession(customToken) because it fails validation in GoTrue.
    // Instead, the custom token is saved by the repository and provided to Supabase via the accessToken callback.
    // Instead, the custom token is saved by the repository and provided to Supabase via the accessToken callback.
    final storage = SecureStorageService();
    await storage.write(AppConstants.storageKeyAccessToken, customToken);
    debugPrint('AuthRemoteDatasource: Supabase token received and saved to storage');

    // Create a temporary client with explicit headers to guarantee the token is sent for these queries
    final tempClient = SupabaseClient(
      AppConfig.supabaseUrl,
      AppConfig.supabaseAnonKey,
      headers: {'Authorization': 'Bearer $customToken'},
    );

    // 3. Look up existing user in Supabase
    var userRow = await tempClient
        .from('users')
        .select('*, shops(*)')
        .eq('firebase_uid', firebaseUid)
        .maybeSingle();

    if (userRow == null && normalizedPhone.isNotEmpty) {
      userRow = await tempClient
          .from('users')
          .select('*, shops(*)')
          .eq('mobile_number', normalizedPhone)
          .maybeSingle();
    }

    Map<String, dynamic> userMap;

    if (userRow == null) {
      // 4. Create new user in Supabase
      debugPrint('AuthRemoteDatasource: Creating new user record in Supabase for $normalizedPhone');
      final inserted = await tempClient
          .from('users')
          .insert({
            'firebase_uid': firebaseUid,
            'mobile_number': normalizedPhone.isEmpty ? '0000000000' : normalizedPhone,
            'role': 'owner',
            'is_active': true,
            'last_login_at': DateTime.now().toIso8601String(),
          })
          .select('*, shops(*)')
          .single();
      userMap = inserted;
    } else {
      userMap = userRow;
      // 5. Update firebase_uid if it was null (e.g. invited user)
      if (userMap['firebase_uid'] == null || userMap['firebase_uid'] != firebaseUid) {
        debugPrint('AuthRemoteDatasource: Activating pending staff with new UID via RPC');
        await tempClient.rpc('rpc_activate_staff', params: {
          'p_mobile_number': normalizedPhone,
          'p_firebase_uid': firebaseUid,
        });
        
        // Re-fetch the user map to get updated fields
        userMap = await tempClient
            .from('users')
            .select('*, shops(*)')
            .eq('id', userMap['id'])
            .single();
      }
    }

    final user = _mapUser(userMap);
    ShopModel? shop;
    if (userMap['shops'] != null) {
      shop = ShopModel.fromJson(_camelizeKeys(userMap['shops'] as Map<String, dynamic>));
    }

    return AuthResponse(
      accessToken: customToken, // Store the Supabase custom token!
      user: user,
      shop: shop,
      onboardingRequired: shop == null,
    );
  }

  /// Get current user profile from Supabase
  Future<ProfileResponse> getProfile([String? storedToken]) async {
    var currentUser = fb.FirebaseAuth.instance.currentUser;
    
    // Firebase Auth might not have finished restoring the session yet immediately after startup
    currentUser ??= await fb.FirebaseAuth.instance.authStateChanges().first;

    if (currentUser == null) {
      throw Exception('No authenticated user');
    }
    
    // If a stored token is provided, use it explicitly instead of the anon client
    final client = storedToken != null 
        ? SupabaseClient(
            AppConfig.supabaseUrl,
            AppConfig.supabaseAnonKey,
            headers: {'Authorization': 'Bearer $storedToken'},
          )
        : _supabase;

    final userRow = await client
        .from('users')
        .select('*, shops(*)')
        .eq('firebase_uid', currentUser.uid)
        .maybeSingle();

    if (userRow == null) {
      throw Exception('User profile not found in database');
    }

    final user = _mapUser(userRow);
    ShopModel? shop;
    if (userRow['shops'] != null) {
      shop = ShopModel.fromJson(_camelizeKeys(userRow['shops'] as Map<String, dynamic>));
    }

    return ProfileResponse(
      user: user,
      shop: shop,
      onboardingRequired: shop == null,
    );
  }

  Future<void> logout() async {
    await fb.FirebaseAuth.instance.signOut();
    await _supabase.auth.signOut();
  }

  UserModel _mapUser(Map<String, dynamic> row) {
    return UserModel(
      id: row['id'] as String,
      mobileNumber: (row['mobile_number'] as String?) ?? '',
      role: (row['role'] as String?) ?? 'owner',
      shopId: row['shop_id'] as String?,
      lastLoginAt: row['last_login_at'] != null ? DateTime.parse(row['last_login_at'] as String) : null,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at'] as String) : null,
      isActive: row['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> _camelizeKeys(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      final camelKey = key.replaceAllMapped(
        RegExp(r'_([a-z])'),
        (match) => match.group(1)!.toUpperCase(),
      );
      result[camelKey] = value;
    });
    return result;
  }
}
