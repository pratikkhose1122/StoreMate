import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:storemate/features/sales/data/models/return_model.dart';

class RefundRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

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

  Future<String> _getUserId() async {
    final currentUser = fb.FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');
    final userRow = await _supabase
        .from('users')
        .select('id')
        .eq('firebase_uid', currentUser.uid)
        .single();
    return userRow['id'] as String;
  }

  /// Process a refund atomically using the process_refund RPC
  Future<String> processRefund({
    required String saleId,
    required String originalPaymentMethod,
    required String refundPaymentMethod,
    required String reason,
    required String notes,
    required List<Map<String, dynamic>> items,
  }) async {
    final shopId = await _getShopId();
    final userId = await _getUserId();

    final result = await _supabase.rpc('process_refund', params: {
      'p_shop_id': shopId,
      'p_sale_id': saleId,
      'p_user_id': userId,
      'p_original_payment_method': originalPaymentMethod,
      'p_refund_payment_method': refundPaymentMethod,
      'p_reason': reason,
      'p_notes': notes,
      'p_items': items,
    });

    return result as String; // Returns the new return_id
  }

  /// Get refunds for a specific sale
  Future<List<ReturnModel>> getReturnsForSale(String saleId) async {
    final shopId = await _getShopId();
    final rows = await _supabase
        .from('returns')
        .select('*, return_items(*)')
        .eq('sale_id', saleId)
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);

    return (rows as List).map((row) {
      final items = ((row['return_items'] as List?) ?? [])
          .map((i) => ReturnItemModel.fromJson(_camelizeKeys(i as Map<String, dynamic>)))
          .toList();
      
      final mappedRow = _camelizeKeys(row as Map<String, dynamic>);
      mappedRow['items'] = items.map((e) => e.toJson()).toList();
      
      return ReturnModel.fromJson(mappedRow);
    }).toList();
  }

  /// Get refunds for a specific customer
  Future<List<ReturnModel>> getReturnsForCustomer(String customerId) async {
    final shopId = await _getShopId();
    final rows = await _supabase
        .from('returns')
        .select('*, return_items(*)')
        .eq('customer_id', customerId)
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);

    return (rows as List).map((row) {
      final items = ((row['return_items'] as List?) ?? [])
          .map((i) => ReturnItemModel.fromJson(_camelizeKeys(i as Map<String, dynamic>)))
          .toList();
      
      final mappedRow = _camelizeKeys(row as Map<String, dynamic>);
      mappedRow['items'] = items.map((e) => e.toJson()).toList();
      
      return ReturnModel.fromJson(mappedRow);
    }).toList();
  }

  Map<String, dynamic> _camelizeKeys(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      final parts = key.split('_');
      final camelKey = parts.first + parts.skip(1).map((p) => p.substring(0, 1).toUpperCase() + p.substring(1)).join('');
      result[camelKey] = value;
    });
    return result;
  }
}
