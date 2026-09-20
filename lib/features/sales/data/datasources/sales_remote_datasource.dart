import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/features/sales/data/models/sale_model.dart';
import 'package:storemate/features/customer/data/models/customer_model.dart';
import 'package:decimal/decimal.dart';

class SalesRemoteDataSource {
  final DioClient _dio;
  SupabaseClient get _supabase => Supabase.instance.client;

  SalesRemoteDataSource(this._dio);

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

  /// Atomic Checkout using Supabase RPC Stored Procedure `rpc_process_sale`
  Future<SaleModel> checkout(Map<String, dynamic> data) async {
    final shopId = await _getShopId();

    // The data map already contains the standardized p_ fields from POSScreen
    final params = {
      ...data,
      'p_shop_id': shopId,
    };

    // Execute atomic RPC call on Supabase Postgres
    final rpcResult = await _supabase.rpc('rpc_process_sale', params: params);

    final saleId = rpcResult['entity_id'] as String;
    return getSale(saleId);
  }

  Future<Map<String, dynamic>> getSales({
    int limit = 20,
    int offset = 0,
    String? customerId,
    String? startDate,
    String? endDate,
    String? searchText,
  }) async {
    final shopId = await _getShopId();
    dynamic req;
    
    if (searchText != null && searchText.isNotEmpty) {
      req = _supabase
          .rpc('search_sales', params: {
            'search_text': searchText,
            'p_shop_id': shopId,
          })
          .select('*, customers(*), sale_items(*)');
    } else {
      req = _supabase
          .from('sales')
          .select('*, customers(*), sale_items(*)')
          .eq('shop_id', shopId);
    }

    if (customerId != null) req = req.eq('customer_id', customerId);
    
    if (startDate != null) {
      req = req.gte('created_at', startDate);
    }
    if (endDate != null) {
      req = req.lte('created_at', endDate);
    }

    final rows = await req
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final sales = (rows as List).map((r) {
      final items = ((r['sale_items'] as List?) ?? [])
          .map((i) => SaleItemModel(
                id: i['id'] as String,
                saleId: r['id'] as String,
                productId: i['product_id'] as String?,
                productName: (i['product_name'] as String?) ?? 'Product',
                quantity: Decimal.parse((i['quantity'] as num).toString()),
                unitPrice: Decimal.parse((i['unit_price'] as num).toString()),
                taxPercentage: Decimal.parse(((i['tax_percentage'] as num?) ?? 0.0).toString()),
                subtotal: Decimal.parse((i['total_price'] as num).toString()),
              ))
          .toList();

      return _mapSale(r, items);
    }).toList();

    return {
      'data': sales,
      'total': sales.length,
    };
  }

  Future<SaleModel> getSale(String id) async {
    final row = await _supabase
        .from('sales')
        .select('*, customers(*), sale_items(*)')
        .eq('id', id)
        .single();

    final items = ((row['sale_items'] as List?) ?? [])
        .map((i) => SaleItemModel(
              id: i['id'] as String,
              saleId: row['id'] as String,
              productId: i['product_id'] as String?,
              productName: (i['product_name'] as String?) ?? 'Product',
              quantity: Decimal.parse((i['quantity'] as num).toString()),
              unitPrice: Decimal.parse((i['unit_price'] as num).toString()),
              taxPercentage: Decimal.parse(((i['tax_percentage'] as num?) ?? 0.0).toString()),
              subtotal: Decimal.parse((i['total_price'] as num).toString()),
            ))
        .toList();

    return _mapSale(row, items);
  }

  SaleModel _mapSale(Map<String, dynamic> row, List<SaleItemModel> items) {
    CustomerModel? customer;
    if (row['customers'] != null) {
      customer = CustomerModel.fromJson(_camelizeKeys(row['customers'] as Map<String, dynamic>));
    }

    final total = Decimal.parse((row['total_amount'] as num).toString());
    final paid = Decimal.parse((row['paid_amount'] as num).toString());
    final due = Decimal.parse((row['due_amount'] as num).toString());
    final sub = Decimal.parse((row['subtotal'] as num).toString());
    final discount = Decimal.parse(((row['discount_amount'] as num?) ?? 0.0).toString());
    final tax = Decimal.parse(((row['tax_amount'] as num?) ?? 0.0).toString());
    final refundAmount = Decimal.parse(((row['refund_amount'] as num?) ?? 0.0).toString());

    final paymentMethod = (row['payment_method'] as String?) ?? 'cash';
    final paymentsList = [
      PaymentModel(
        id: row['id'] as String,
        saleId: row['id'] as String,
        amount: paid,
        paymentMethod: paymentMethod,
        status: 'completed',
      )
    ];

    return SaleModel(
      id: row['id'] as String,
      shopId: row['shop_id'] as String,
      customerId: row['customer_id'] as String?,
      customer: customer,
      invoiceNumber: row['invoice_number'] as String,
      status: (row['status'] as String?) ?? 'completed',
      totalAmount: total,
      discountAmount: discount,
      taxAmount: tax,
      netAmount: sub,
      amountPaid: paid,
      amountDue: due,
      refundAmount: refundAmount,
      lastRefundAt: row['last_refund_at'] != null ? DateTime.parse(row['last_refund_at'] as String) : null,
      items: items,
      payments: paymentsList,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at'] as String) : DateTime.now(),
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
