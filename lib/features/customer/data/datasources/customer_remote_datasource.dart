import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/features/customer/data/models/customer_model.dart';

class CustomerRemoteDataSource {
  final DioClient _dio;
  SupabaseClient get _supabase => Supabase.instance.client;

  CustomerRemoteDataSource(this._dio);

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

  Future<List<CustomerModel>> getCustomers([String? query]) async {
    final shopId = await _getShopId();
    dynamic req = _supabase.from('customers').select().eq('shop_id', shopId);

    if (query != null && query.trim().isNotEmpty) {
      req = req.or('name.ilike.%${query.trim()}%,mobile_number.ilike.%${query.trim()}%');
    }

    final rows = await req.order('created_at', ascending: false);
    return (rows as List).map((row) => CustomerModel.fromJson(_camelizeKeys(row))).toList();
  }

  Future<CustomerModel> getCustomer(String id) async {
    final row = await _supabase.from('customers').select().eq('id', id).single();
    return CustomerModel.fromJson(_camelizeKeys(row));
  }

  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    final shopId = await _getShopId();
    final payload = _snakeizeKeys(data);
    payload['shop_id'] = shopId;

    final row = await _supabase
        .from('customers')
        .insert(payload)
        .select()
        .single();

    return CustomerModel.fromJson(_camelizeKeys(row));
  }

  Future<CustomerModel> updateCustomer(String id, Map<String, dynamic> data) async {
    final payload = _snakeizeKeys(data);
    payload['updated_at'] = DateTime.now().toIso8601String();

    final row = await _supabase
        .from('customers')
        .update(payload)
        .eq('id', id)
        .select()
        .single();

    return CustomerModel.fromJson(_camelizeKeys(row));
  }

  Future<void> deleteCustomer(String id) async {
    await _supabase.from('customers').delete().eq('id', id);
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
