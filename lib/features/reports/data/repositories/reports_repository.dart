import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:decimal/decimal.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/core/providers/core_providers.dart';
import 'package:storemate/features/reports/presentation/providers/reports_provider.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository(ref.read(dioClientProvider));
});

class ReportsRepository {
  final DioClient _dio;
  SupabaseClient get _supabase => Supabase.instance.client;

  ReportsRepository(this._dio);

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

  Future<List<DailySaleMetric>> getDailySalesMetrics(String startDate, String endDate) async {
    final shopId = await _getShopId();
    final rpcResult = await _supabase.rpc('get_daily_sales_metrics', params: {
      'p_shop_id': shopId,
      'p_start_date': startDate,
      'p_end_date': endDate,
    });
    
    return (rpcResult as List).map((r) {
      return DailySaleMetric(
        date: DateTime.parse(r['report_date']),
        revenue: Decimal.parse((r['daily_revenue'] as num?)?.toString() ?? '0.0'),
        profit: Decimal.parse((r['daily_profit'] as num?)?.toString() ?? '0.0'),
      );
    }).toList();
  }

  Future<Map<String, dynamic>> getProfitData(String startDate, String endDate) async {
    final shopId = await _getShopId();
    final rpcResult = await _supabase.rpc('get_sales_metrics', params: {
      'p_shop_id': shopId,
      'p_start_date': startDate,
      'p_end_date': endDate,
    });
    
    final metrics = (rpcResult as List).first as Map<String, dynamic>;
    final revenue = Decimal.parse((metrics['total_revenue'] as num?)?.toString() ?? '0.0');
    final cost = Decimal.parse((metrics['total_cost'] as num?)?.toString() ?? '0.0');
    final netProfit = Decimal.parse((metrics['total_profit'] as num?)?.toString() ?? '0.0');
    final totalSales = (metrics['total_sales'] as num?)?.toInt() ?? 0;
    final averageBill = Decimal.parse((metrics['average_bill'] as num?)?.toString() ?? '0.0');

    return {
      'revenue': revenue,
      'cost': cost,
      'netProfit': netProfit,
      'totalSales': totalSales,
      'averageBill': averageBill,
      'profitMargin': revenue > Decimal.zero ? (netProfit / revenue).toDecimal(scaleOnInfinitePrecision: 4) * Decimal.fromInt(100) : Decimal.zero,
    };
  }

  Future<List<TopProduct>> getTopProducts({String? startDate, String? endDate}) async {
    final shopId = await _getShopId();
    final rpcResult = await _supabase.rpc('get_top_products', params: {
      'p_shop_id': shopId,
      'p_start_date': startDate,
      'p_end_date': endDate,
      'p_limit': 10,
    });

    return (rpcResult as List).map((r) => TopProduct(
      id: r['id'] as String,
      name: r['name'] as String,
      salesCount: (r['sales_count'] as num?)?.toInt() ?? 0,
      revenue: Decimal.parse((r['revenue'] as num?)?.toString() ?? '0.0'),
      profit: Decimal.parse((r['profit'] as num?)?.toString() ?? '0.0'),
    )).toList();
  }

  Future<List<SlowProduct>> getSlowProducts({String? startDate, String? endDate}) async {
    final shopId = await _getShopId();
    final rpcResult = await _supabase.rpc('get_slow_products', params: {
      'p_shop_id': shopId,
      'p_start_date': startDate,
      'p_end_date': endDate,
      'p_limit': 10,
    });

    return (rpcResult as List).map((r) => SlowProduct(
      id: r['id'] as String,
      name: r['name'] as String,
      currentStock: Decimal.parse((r['current_stock'] as num?)?.toString() ?? '0.0'),
      salesCount: (r['sales_count'] as num?)?.toInt() ?? 0,
      revenue: Decimal.parse((r['revenue'] as num?)?.toString() ?? '0.0'),
    )).toList();
  }
}
