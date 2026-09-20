import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:decimal/decimal.dart';
import 'package:storemate/features/reports/presentation/providers/reports_provider.dart';
// Just in case, wait no I need the provider
import 'package:storemate/features/dashboard/data/repositories/dashboard_repository.dart'; // where dashboardSummaryProvider is
import 'package:storemate/core/widgets/app_card.dart';
import 'package:storemate/core/widgets/app_list_tile.dart';
import 'package:storemate/core/widgets/app_empty_state.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  Future<void> _selectDateRange(BuildContext context, WidgetRef ref) async {
    final currentRange = ref.read(reportsDateRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: currentRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: context.colors.primary,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(reportsDateRangeProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(reportsSummaryProvider);
    final dateRange = ref.watch(reportsDateRangeProvider);
    final dashboardAsync = ref.watch(dashboardSummaryProvider); // Get stock metrics

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range_outlined, color: context.colors.textSecondary),
            tooltip: 'Select Date Range',
            onPressed: () => _selectDateRange(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: summaryAsync.when(
          data: (summary) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${DateFormat.MMMEd().format(dateRange.start)} - ${DateFormat.MMMEd().format(dateRange.end)}',
                          style: AppTextStyles.labelMd.copyWith(color: context.colors.textSecondary),
                        ),
                        InkWell(
                          onTap: () => _selectDateRange(context, ref),
                          child: Text('Change', style: AppTextStyles.labelMd.copyWith(color: context.colors.primary)),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── KPI Grid ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _DenseReportKPI(title: 'Revenue', value: summary.totalSales, isCurrency: true)),
                            const SizedBox(width: 12),
                            Expanded(child: _DenseReportKPI(title: 'Bills', value: Decimal.fromInt(summary.totalBills), isCurrency: false)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _DenseReportKPI(title: 'Total Profit', value: summary.totalProfit, isCurrency: true)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: dashboardAsync.when(
                                data: (db) => _DenseReportKPI(title: 'Stock Value', value: db.inventoryValue, isCurrency: true),
                                loading: () => _DenseReportKPI(title: 'Stock Value', value: Decimal.zero, isCurrency: true),
                                error: (_, __) => _DenseReportKPI(title: 'Stock Value', value: Decimal.zero, isCurrency: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _DenseReportKPI(title: 'Avg Bill', value: summary.averageBill, isCurrency: true)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: dashboardAsync.when(
                                data: (db) => _DenseReportKPI(title: 'Low Stock', value: Decimal.fromInt(db.lowStockProducts), isCurrency: false),
                                loading: () => _DenseReportKPI(title: 'Low Stock', value: Decimal.zero, isCurrency: false),
                                error: (_, __) => _DenseReportKPI(title: 'Low Stock', value: Decimal.zero, isCurrency: false),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // ── Weekly Sales Chart ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Sales Chart', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AppCard(
                      padding: const EdgeInsets.all(24),
                      child: summary.dailyMetrics.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Column(
                                  children: [
                                    Icon(Icons.bar_chart, size: 48, color: context.colors.border),
                                    const SizedBox(height: 16),
                                    Text('No sales data for this period', style: AppTextStyles.labelMd.copyWith(color: context.colors.textSecondary)),
                                  ],
                                ),
                              ),
                            )
                          : _buildDynamicChart(context, summary.dailyMetrics, dateRange),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Recent Sales List ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Recent Transactions', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                
                if (summary.dailyMetrics.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AppEmptyState(
                        icon: Icons.receipt_long,
                        title: 'No transactions found',
                        explanation: 'There are no transactions in the selected date range.',
                        actionLabel: 'Go to POS',
                        onAction: () => context.push('/pos'),
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Note: Recent transactions view moved to Dashboard', style: AppTextStyles.labelSm.copyWith(color: context.colors.textSecondary)),
                    ),
                  ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                
                // ── Top Products ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Top Products', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                if (summary.topProducts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AppEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'No products sold',
                        explanation: 'Once you sell items, your top selling products will appear here.',
                        actionLabel: 'View Inventory',
                        onAction: () => context.go('/products'),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = summary.topProducts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: AppListTile(
                            leading: Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: context.colors.elevatedCard,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.inventory_2, color: context.colors.textSecondary),
                            ),
                            title: product.name,
                            subtitle: '${product.salesCount} sold',
                            trailing: Icon(Icons.chevron_right, color: context.colors.border),
                          ),
                        );
                      },
                      childCount: summary.topProducts.length > 10 ? 10 : summary.topProducts.length,
                    ),
                  ),
                  
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                
                // ── Slow Products ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Low Performing Products', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                if (summary.slowProducts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AppEmptyState(
                        icon: Icons.trending_down,
                        title: 'No slow products',
                        explanation: 'All your products are selling well!',
                        actionLabel: 'View Inventory',
                        onAction: () => context.go('/products'),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = summary.slowProducts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: AppListTile(
                            leading: Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: context.colors.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.trending_down, color: context.colors.danger),
                            ),
                            title: product.name,
                            subtitle: '${product.salesCount} sold',
                            trailing: Icon(Icons.chevron_right, color: context.colors.border),
                          ),
                        );
                      },
                      childCount: summary.slowProducts.length > 5 ? 5 : summary.slowProducts.length,
                    ),
                  ),
                  
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
          loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AppEmptyState(
                icon: Icons.error_outline,
                title: 'Failed to load reports',
                explanation: 'We could not fetch your reports data right now. $e',
                actionLabel: 'Retry',
                onAction: () => ref.refresh(reportsSummaryProvider),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicChart(BuildContext context, List<DailySaleMetric> dailyMetrics, DateTimeRange range) {
    // Determine the days to show
    final int days = range.end.difference(range.start).inDays + 1;
    final List<MapEntry<String, double>> chartData = [];
    
    // Server has already aggregated by day. Just build a map for quick lookup.
    final Map<String, Decimal> metricsMap = {
      for (var m in dailyMetrics) DateFormat('yyyy-MM-dd').format(m.date): m.revenue
    };

    if (days <= 7) {
      for (int i = 0; i < days; i++) {
        final d = range.start.add(Duration(days: i));
        final key = DateFormat('yyyy-MM-dd').format(d);
        // Only convert to double at the final boundary for chart layout arithmetic
        final val = (metricsMap[key] ?? Decimal.zero).toDouble();
        chartData.add(MapEntry(DateFormat('E').format(d), val));
      }
    } else {
      // Show exactly 7 bars representing the last 7 days of the range
      for (int i = 6; i >= 0; i--) {
        final d = range.end.subtract(Duration(days: i));
        final key = DateFormat('yyyy-MM-dd').format(d);
        final val = (metricsMap[key] ?? Decimal.zero).toDouble();
        chartData.add(MapEntry(DateFormat('E').format(d), val));
      }
    }

    final maxSale = chartData.map((e) => e.value).fold(0.0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 160,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: chartData.map((e) {
          final isToday = e.key == DateFormat('E').format(DateTime.now());
          final percentage = maxSale > 0 ? (e.value / maxSale) : 0.05; // minimum height
          return _buildChartBar(context, e.key, percentage == 0 ? 0.05 : percentage, isHighlight: isToday);
        }).toList(),
      ),
    );
  }

  Widget _buildChartBar(BuildContext context, String label, double fillPercentage, {bool isHighlight = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: FractionallySizedBox(
            heightFactor: fillPercentage,
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 24,
              decoration: BoxDecoration(
                color: isHighlight ? context.colors.primary : context.colors.elevatedCard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.labelSm.copyWith(color: context.colors.textSecondary)),
      ],
    );
  }
}

class _DenseReportKPI extends StatelessWidget {
  final String title;
  final Decimal value;
  final bool isCurrency;

  const _DenseReportKPI({
    required this.title,
    required this.value,
    required this.isCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelMd.copyWith(color: context.colors.textSecondary)),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              final formatted = isCurrency ? '₹${val.toStringAsFixed(0)}' : val.toInt().toString();
              return Text(formatted, style: AppTextStyles.displayMd.copyWith(color: context.colors.textPrimary));
            },
          ),
        ],
      ),
    );
  }
}
