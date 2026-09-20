import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:decimal/decimal.dart';
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/core/providers/core_providers.dart';
import 'package:storemate/features/dashboard/data/models/dashboard_summary_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(dioClientProvider));
});

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummaryModel>((ref) async {
  return ref.read(dashboardRepositoryProvider).getSummary();
});

class DashboardRepository {
  final DioClient _dio;
  SupabaseClient get _supabase => Supabase.instance.client;

  DashboardRepository(this._dio);

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

  Future<DashboardSummaryModel> getSummary() async {
    final shopId = await _getShopId();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toUtc().toIso8601String();

    // Call RPC to get all aggregated metrics atomically and efficiently
    final rpcResult = await _supabase.rpc('get_dashboard_summary', params: {
      'p_shop_id': shopId,
      'p_start_date': startOfDay,
    });
    
    final summaryData = rpcResult as Map<String, dynamic>;

    // Get Top Selling Products via RPC
    final topProductsRows = await _supabase.rpc('get_top_products', params: {
      'p_shop_id': shopId,
      'p_start_date': startOfDay,
    });

    final topProducts = (topProductsRows as List).map((r) {
      final revenue = (r['revenue'] as num?)?.toDouble() ?? 0.0;
      final salesCount = (r['sales_count'] as num?)?.toDouble() ?? 0.0;
      return {
        'id': r['id'],
        'name': r['name'],
        'salesCount': r['sales_count'],
        'revenue': r['revenue'],
        'sellingPrice': revenue / (salesCount > 0 ? salesCount : 1.0),
      };
    }).toList();
    
    // Get Low Stock List separately via new canonical RPC
    final lowStockRows = await _supabase.rpc('get_low_stock_list', params: {
      'p_shop_id': shopId,
      'p_limit': 10,
    });
        
    final lowStockList = (lowStockRows as List).map((row) => {
      'id': row['id'],
      'name': row['name'],
      'currentStock': row['current_stock'],
      'lowStockThreshold': row['low_stock_threshold'],
      'sellingPrice': row['selling_price'],
    }).toList();

    // Get Recent Sales Movements
    final recentSalesRows = await _supabase
        .from('sales')
        .select('invoice_number, total_amount, payment_method, created_at')
        .eq('shop_id', shopId)
        .eq('status', 'completed')
        .order('created_at', ascending: false)
        .limit(5);

    final recentMovements = (recentSalesRows as List).map((r) => {
      'id': r['invoice_number'] as String,
      'invoiceNumber': r['invoice_number'] as String,
      'amount': (r['total_amount'] as num).toDouble(),
      'paymentMethod': (r['payment_method'] as String?) ?? 'cash',
      'createdAt': r['created_at'] as String,
    }).toList();

    return DashboardSummaryModel(
      totalProducts: (summaryData['total_products'] as num?)?.toInt() ?? 0,
      totalCategories: (summaryData['total_categories'] as num?)?.toInt() ?? 0,
      lowStockProducts: (summaryData['low_stock_products'] as num?)?.toInt() ?? 0,
      outOfStockProducts: (summaryData['out_of_stock_products'] as num?)?.toInt() ?? 0,
      inventoryValue: Decimal.parse((summaryData['inventory_value'] as num?)?.toString() ?? '0.0'),
      todaysSales: Decimal.parse((summaryData['todays_sales'] as num?)?.toString() ?? '0.0'),
      todaysProfit: Decimal.parse((summaryData['todays_profit'] as num?)?.toString() ?? '0.0'),
      todaysTransactionCount: (summaryData['total_sales_count'] as num?)?.toInt() ?? 0,
      recentMovements: recentMovements,
      recentProducts: topProducts,
      lowStockProductsList: lowStockList,
    );
  }
}
