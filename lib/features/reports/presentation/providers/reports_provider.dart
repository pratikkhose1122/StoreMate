import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decimal/decimal.dart';
import 'package:storemate/features/reports/data/repositories/reports_repository.dart';

final reportsDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: now.subtract(const Duration(days: 6)),
    end: now,
  );
});

class DailySaleMetric {
  final DateTime date;
  final Decimal revenue;
  final Decimal profit;

  DailySaleMetric({
    required this.date,
    required this.revenue,
    required this.profit,
  });
}

class TopProduct {
  final String id;
  final String name;
  final int salesCount;
  final Decimal revenue;
  final Decimal profit;

  TopProduct({
    required this.id,
    required this.name,
    required this.salesCount,
    required this.revenue,
    required this.profit,
  });
}

class SlowProduct {
  final String id;
  final String name;
  final Decimal currentStock;
  final int salesCount;
  final Decimal revenue;

  SlowProduct({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.salesCount,
    required this.revenue,
  });
}

class ReportsSummaryData {
  final Decimal totalSales;
  final int totalBills;
  final Decimal totalProfit;
  final Decimal averageBill;
  final List<DailySaleMetric> dailyMetrics;
  final List<TopProduct> topProducts;
  final List<SlowProduct> slowProducts;

  ReportsSummaryData({
    required this.totalSales,
    required this.totalBills,
    required this.totalProfit,
    required this.averageBill,
    required this.dailyMetrics,
    required this.topProducts,
    required this.slowProducts,
  });
}

final reportsSummaryProvider = FutureProvider.autoDispose<ReportsSummaryData>((ref) async {
  final repo = ref.read(reportsRepositoryProvider);
  final dateRange = ref.watch(reportsDateRangeProvider);

  final startDateStr = dateRange.start.toUtc().toIso8601String();
  final endDateStr = dateRange.end.toUtc().toIso8601String();

  final salesFuture = repo.getDailySalesMetrics(startDateStr, endDateStr);
  final profitFuture = repo.getProfitData(startDateStr, endDateStr);
  final topProductsFuture = repo.getTopProducts(startDate: startDateStr, endDate: endDateStr);
  final slowProductsFuture = repo.getSlowProducts(startDate: startDateStr, endDate: endDateStr);

  final results = await Future.wait([salesFuture, profitFuture, topProductsFuture, slowProductsFuture]);

  final dailyMetrics = results[0] as List<DailySaleMetric>;
  final profitData = results[1] as Map<String, dynamic>;
  final topProducts = results[2] as List<TopProduct>;
  final slowProducts = results[3] as List<SlowProduct>;

  final totalSales = Decimal.parse((profitData['revenue'] as Decimal?)?.toString() ?? '0.0');
  final totalBills = profitData['totalSales'] as int? ?? 0;
  
  final totalProfit = Decimal.parse((profitData['netProfit'] as Decimal?)?.toString() ?? '0.0');
  
  final averageBill = profitData['averageBill'] as Decimal? ?? Decimal.zero;

  return ReportsSummaryData(
    totalSales: totalSales,
    totalBills: totalBills,
    totalProfit: totalProfit,
    averageBill: averageBill,
    dailyMetrics: dailyMetrics,
    topProducts: topProducts,
    slowProducts: slowProducts,
  );
});
