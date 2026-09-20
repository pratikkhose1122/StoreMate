import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/core/providers/core_providers.dart';

final inventoryRemoteDataSourceProvider = Provider<InventoryRemoteDataSource>((ref) {
  return InventoryRemoteDataSource(ref.read(dioClientProvider));
});

class InventoryRemoteDataSource {
  final DioClient _dio;
  SupabaseClient get _supabase => Supabase.instance.client;

  InventoryRemoteDataSource(this._dio);

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

  Future<void> adjustInventory(String productId, int quantityChange, String actionType, [String? notes]) async {
    final shopId = await _getShopId();
    final pRow = await _supabase
        .from('products')
        .select('current_stock')
        .eq('id', productId)
        .single();

    final prevStock = (pRow['current_stock'] as num?)?.toInt() ?? 0;
    final newStock = (prevStock + quantityChange).clamp(0, 999999);

    await _supabase
        .from('products')
        .update({'current_stock': newStock})
        .eq('id', productId);

    await _supabase.from('inventory_logs').insert({
      'product_id': productId,
      'shop_id': shopId,
      'change_type': actionType,
      'quantity': quantityChange,
      'previous_stock': prevStock,
      'new_stock': newStock,
      'notes': notes,
    });
  }

  Future<List<dynamic>> getLogs(String? productId, int limit) async {
    final shopId = await _getShopId();
    dynamic req = _supabase
        .from('inventory_logs')
        .select('*, products(name)')
        .eq('shop_id', shopId);

    if (productId != null && productId.isNotEmpty) {
      req = req.eq('product_id', productId);
    }

    final rows = await req.order('created_at', ascending: false).limit(limit);

    return (rows as List).map((r) {
      final map = Map<String, dynamic>.from(r as Map);
      if (r['products'] != null) {
        map['productName'] = r['products']['name'];
      }
      return _camelizeKeys(map);
    }).toList();
  }

  Future<Map<String, dynamic>> getHistory(String productId, int page, int limit) async {
    final fromIndex = (page - 1) * limit;
    final toIndex = page * limit - 1;

    final rows = await _supabase
        .from('inventory_logs')
        .select('*, products(name)')
        .eq('product_id', productId)
        .order('created_at', ascending: false)
        .range(fromIndex, toIndex);

    final items = (rows as List).map((r) {
      final map = Map<String, dynamic>.from(r as Map);
      if (r['products'] != null) {
        map['productName'] = r['products']['name'];
      }
      return _camelizeKeys(map);
    }).toList();

    return {
      'items': items,
      'total': items.length,
    };
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
