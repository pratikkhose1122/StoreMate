import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:storemate/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:storemate/features/reports/presentation/providers/reports_provider.dart';

void main() {
  group('Phase 2G - Dashboard & Reports Tests', () {
    test('DashboardSummaryModel safely parses NUMERIC strings to Decimal', () {
      final json = {
        'totalProducts': 120,
        'totalCategories': 15,
        'lowStockProducts': 5,
        'outOfStockProducts': 2,
        'inventoryValue': '15500.50',
        'todaysSales': '2500.00',
        'todaysProfit': '450.75',
        'todaysTransactionCount': 12,
      };

      final model = DashboardSummaryModel.fromJson(json);

      expect(model.totalProducts, 120);
      expect(model.lowStockProducts, 5);
      expect(model.inventoryValue, Decimal.parse('15500.50'));
      expect(model.todaysSales, Decimal.parse('2500.00'));
      expect(model.todaysProfit, Decimal.parse('450.75'));
      expect(model.todaysTransactionCount, 12);
    });

    test('DailySaleMetric enforces strict Decimal financial types', () {
      final metric = DailySaleMetric(
        date: DateTime(2026, 9, 16),
        revenue: Decimal.parse('1500.00'),
        profit: Decimal.parse('300.00'),
      );

      expect(metric.revenue.toDouble(), 1500.0);
      expect(metric.profit.toDouble(), 300.0);
      expect(metric.date.year, 2026);
    });

    test('ReportsSummaryData averageBill computation is Decimal-safe', () {
      final totalSales = Decimal.parse('5000.00');
      final totalBills = 10;
      final averageBill = (totalSales / Decimal.fromInt(totalBills)).toDecimal(scaleOnInfinitePrecision: 2);

      expect(averageBill, Decimal.parse('500.00'));

      final summary = ReportsSummaryData(
        totalSales: totalSales,
        totalBills: totalBills,
        totalProfit: Decimal.parse('1200.00'),
        averageBill: averageBill,
        dailyMetrics: [],
        topProducts: [],
        slowProducts: [],
      );

      expect(summary.averageBill, Decimal.parse('500.00'));
    });

    test('ReportsSummaryData safely handles empty periods', () {
      final summary = ReportsSummaryData(
        totalSales: Decimal.zero,
        totalBills: 0,
        totalProfit: Decimal.zero,
        averageBill: Decimal.zero,
        dailyMetrics: [],
        topProducts: [],
        slowProducts: [],
      );

      expect(summary.totalSales, Decimal.zero);
      expect(summary.averageBill, Decimal.zero);
      expect(summary.dailyMetrics.isEmpty, true);
    });
  });
}
