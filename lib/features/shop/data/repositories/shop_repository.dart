import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:storemate/core/storage/secure_storage_service.dart';
import 'package:storemate/core/config/app_config.dart';
import 'package:storemate/core/constants/app_constants.dart';
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/features/shop/data/models/shop_model.dart';

/// Repository for shop-related operations via Supabase DB.
class ShopRepository {
  final DioClient _client;
  final SecureStorageService _storage;
  SupabaseClient get _supabase => Supabase.instance.client;

  ShopRepository(this._client, this._storage);

  /// Register a new shop for the authenticated user in Supabase.
  Future<ShopModel> createShop({
    required String name,
    required String ownerName,
    String? mobileNumber,
    String? email,
    String? address,
    String? gstNumber,
    required String businessType,
  }) async {
    final currentUser = fb.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }

    final customToken = await _storage.read(AppConstants.storageKeyAccessToken);
    if (customToken == null) {
      throw Exception('Custom Supabase token not found');
    }

    final tempClient = SupabaseClient(
      AppConfig.supabaseUrl,
      AppConfig.supabaseAnonKey,
      headers: {'Authorization': 'Bearer $customToken'},
    );

    final shopCode = 'SM${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    // Use the atomic RPC function to create the shop and link it to the user
    // This bypasses the RLS chicken-and-egg problem where a user can't insert a shop without a shop_id
    final insertedShop = await tempClient.rpc('register_shop', params: {
      'p_shop_code': shopCode,
      'p_name': name,
      'p_owner_name': ownerName,
      'p_mobile_number': mobileNumber,
      'p_email': email,
      'p_address': address,
      'p_gstin': gstNumber,
      'p_business_type': businessType,
    });

    final shopModel = ShopModel.fromJson(_camelizeKeys(insertedShop));
    return shopModel;
  }

  /// Update shop settings in Supabase.
  Future<ShopModel> updateSettings(Map<String, dynamic> data) async {
    final currentUser = fb.FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final userRow = await _supabase
        .from('users')
        .select('shop_id')
        .eq('firebase_uid', currentUser.uid)
        .single();

    final shopId = userRow['shop_id'] as String;

    final updated = await _supabase
        .from('shops')
        .update(_snakeizeKeys(data))
        .eq('id', shopId)
        .select()
        .single();

    return ShopModel.fromJson(_camelizeKeys(updated));
  }

  /// Upload shop logo to Supabase Storage and persist the public URL.
  Future<String> uploadLogo(String filePath) async {
    final currentUser = fb.FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    // Get the shop ID for this user
    final userRow = await _supabase
        .from('users')
        .select('shop_id')
        .eq('firebase_uid', currentUser.uid)
        .single();
    final shopId = userRow['shop_id'] as String;

    // Determine file extension
    final ext = filePath.split('.').last.toLowerCase();
    final storagePath = 'logos/$shopId/logo.$ext';

    // Upload to Supabase Storage (upsert to overwrite previous logo)
    final file = File(filePath);
    await _supabase.storage.from('shop-assets').upload(
      storagePath,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    // Get the public URL
    final publicUrl = _supabase.storage.from('shop-assets').getPublicUrl(storagePath);

    // Persist logo_url to the shops table
    await _supabase
        .from('shops')
        .update({'logo_url': publicUrl})
        .eq('id', shopId);

    return publicUrl;
  }

  /// Delete shop logo from Supabase Storage and clear the URL.
  Future<void> deleteLogo() async {
    final currentUser = fb.FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final userRow = await _supabase
        .from('users')
        .select('shop_id')
        .eq('firebase_uid', currentUser.uid)
        .single();
    final shopId = userRow['shop_id'] as String;

    // Try to remove all logo files for this shop
    try {
      final files = await _supabase.storage.from('shop-assets').list(path: 'logos/$shopId');
      if (files.isNotEmpty) {
        await _supabase.storage.from('shop-assets').remove(
          files.map((f) => 'logos/$shopId/${f.name}').toList(),
        );
      }
    } catch (_) {
      // Ignore if files don't exist
    }

    // Clear logo_url in shops table
    await _supabase
        .from('shops')
        .update({'logo_url': null})
        .eq('id', shopId);
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

  Map<String, dynamic> _snakeizeKeys(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      final snakeKey = key.replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => '_${match.group(1)!.toLowerCase()}',
      );
      result[snakeKey] = value;
    });
    return result;
  }
}
