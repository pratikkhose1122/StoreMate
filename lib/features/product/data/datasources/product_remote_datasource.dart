import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/core/providers/core_providers.dart';
import 'package:storemate/features/product/data/models/product_model.dart';

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource(ref.read(dioClientProvider));
});

class ProductRemoteDataSource {
  final DioClient _dio;
  SupabaseClient get _supabase => Supabase.instance.client;

  ProductRemoteDataSource(this._dio);

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

  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
  }) async {
    final shopId = await _getShopId();
    final fromIndex = (page - 1) * limit;
    final toIndex = page * limit - 1;

    dynamic query = _supabase
        .from('products')
        .select('*, categories(*)')
        .eq('shop_id', shopId);

    if (search != null && search.trim().isNotEmpty) {
      final searchTerm = search.trim();
      query = query.or('name.ilike.%$searchTerm%,barcode.ilike.%$searchTerm%,brand.ilike.%$searchTerm%,sku.ilike.%$searchTerm%');
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.eq('category_id', categoryId);
    }

    final rows = await query
        .order('created_at', ascending: false)
        .range(fromIndex, toIndex);

    final items = (rows as List).map((r) => _mapProduct(r)).toList();

    return {
      'items': items,
      'meta': {
        'totalItems': items.length,
        'itemCount': items.length,
        'itemsPerPage': limit,
        'totalPages': 1,
        'currentPage': page,
      },
    };
  }

  Future<ProductModel> getProduct(String id) async {
    final row = await _supabase
        .from('products')
        .select('*, categories(*)')
        .eq('id', id)
        .single();

    return _mapProduct(row);
  }

  Future<Map<String, dynamic>> lookupBarcode(String barcode) async {
    final shopId = await _getShopId();
    final row = await _supabase
        .from('products')
        .select('*, categories(*)')
        .eq('shop_id', shopId)
        .eq('barcode', barcode)
        .maybeSingle();

    if (row == null) {
      return {'found': false};
    }

    final product = _mapProduct(row);
    return {
      'found': true,
      'product': product.toJson(),
    };
  }

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final shopId = await _getShopId();
    final payload = _snakeizeMap(data);
    payload['shop_id'] = shopId;
    if (payload.containsKey('quantity')) {
      payload['current_stock'] = payload.remove('quantity');
    }
    payload.remove('brand');
    payload.remove('package_size');
    payload.remove('category');

    final row = await _supabase
        .from('products')
        .insert(payload)
        .select('*, categories(*)')
        .single();

    return _mapProduct(row);
  }

  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    final payload = _snakeizeMap(data);
    if (payload.containsKey('quantity')) {
      payload['current_stock'] = payload.remove('quantity');
    }
    payload.remove('brand');
    payload.remove('package_size');
    payload.remove('category');
    payload['updated_at'] = DateTime.now().toIso8601String();

    final row = await _supabase
        .from('products')
        .update(payload)
        .eq('id', id)
        .select('*, categories(*)')
        .single();

    return _mapProduct(row);
  }

  Future<void> deleteProduct(String id) async {
    await _supabase.from('products').delete().eq('id', id);
  }

  Future<ProductModel> uploadImage(String id, String filePath) async {
    return getProduct(id);
  }

  Future<Map<String, dynamic>> previewBulkImport(String filePath) async {
    throw UnimplementedError('Bulk Import is currently unavailable. This feature requires backend support.');
  }

  Future<Map<String, dynamic>> confirmBulkImport(String filePath) async {
    throw UnimplementedError('Bulk Import is currently unavailable. This feature requires backend support.');
  }

  ProductModel _mapProduct(Map<String, dynamic> row) {
    final map = _camelizeKeys(row);
    if (row.containsKey('current_stock')) {
      map['quantity'] = row['current_stock'];
    }
    if (row['categories'] != null) {
      map['category'] = _camelizeKeys(row['categories'] as Map<String, dynamic>);
    }
    map['purchasePrice'] = (map['purchasePrice'] as num?)?.toDouble() ?? 0.0;
    map['sellingPrice'] = (map['sellingPrice'] as num?)?.toDouble() ?? 0.0;
    map['taxPercentage'] = (map['taxPercentage'] as num?)?.toDouble() ?? 0.0;
    map['quantity'] = (map['quantity'] as num?)?.toInt() ?? 0;
    map['lowStockThreshold'] = (map['lowStockThreshold'] as num?)?.toInt() ?? 5;
    map['unitType'] = map['unitType'] ?? 'piece';
    map['status'] = map['status'] ?? 'active';
    map['createdAt'] = map['createdAt'] ?? DateTime.now().toIso8601String();
    map['updatedAt'] = map['updatedAt'] ?? DateTime.now().toIso8601String();

    return ProductModel.fromJson(map);
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

  Map<String, dynamic> _snakeizeMap(Map<String, dynamic> map) {
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
