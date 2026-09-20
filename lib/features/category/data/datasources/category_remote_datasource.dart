import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/core/providers/core_providers.dart';
import 'package:storemate/features/category/data/models/category_model.dart';

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((ref) {
  return CategoryRemoteDataSource(ref.read(dioClientProvider));
});

class CategoryRemoteDataSource {
  final DioClient _dio;
  SupabaseClient get _supabase => Supabase.instance.client;

  CategoryRemoteDataSource(this._dio);

  Future<String> _getShopId() async {
    final currentUser = fb.FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');
    final userRow = await _supabase
        .from('users')
        .select('shop_id')
        .eq('firebase_uid', currentUser.uid)
        .single();
    final shopId = userRow['shop_id'] as String?;
    if (shopId == null) throw Exception('No shop registered for current user');
    return shopId;
  }

  Future<List<CategoryModel>> getCategories() async {
    final shopId = await _getShopId();
    final rows = await _supabase
        .from('categories')
        .select()
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);

    return (rows as List).map((row) => CategoryModel.fromJson(_camelizeKeys(row))).toList();
  }

  Future<CategoryModel> createCategory(String name, String? description) async {
    final shopId = await _getShopId();
    final row = await _supabase
        .from('categories')
        .insert({
          'shop_id': shopId,
          'name': name,
        })
        .select()
        .single();

    return CategoryModel.fromJson(_camelizeKeys(row));
  }

  Future<CategoryModel> updateCategory(String id, String name, String? description) async {
    final row = await _supabase
        .from('categories')
        .update({
          'name': name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();

    return CategoryModel.fromJson(_camelizeKeys(row));
  }

  Future<void> deleteCategory(String id) async {
    await _supabase.from('categories').delete().eq('id', id);
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
