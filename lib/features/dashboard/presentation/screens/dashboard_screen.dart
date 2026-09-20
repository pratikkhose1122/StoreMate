import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/auth/domain/auth_state.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';
import 'package:storemate/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:storemate/features/activity_logs/presentation/providers/activity_log_provider.dart';
import 'package:storemate/core/permissions/permission_provider.dart';
import 'package:storemate/core/widgets/app_empty_state.dart';
import 'package:decimal/decimal.dart';
import 'package:storemate/core/widgets/app_shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final colors = context.colors;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        context.go('/login');
      }
    });

    final shop = authState.shop;
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final activityAsync = ref.watch(recentActivityProvider);
    final permissions = ref.watch(permissionServiceProvider);

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push('/pos'),
        backgroundColor: colors.primary,
        foregroundColor: colors.primaryForeground,
        elevation: 0,
        icon: const Icon(Icons.add, size: 20),
        label: Text('New Sale', style: AppTextStyles.btnMd.copyWith(color: colors.primaryForeground)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardSummaryProvider);
            ref.invalidate(recentActivityProvider);
            await ref.read(dashboardSummaryProvider.future);
          },
          color: colors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop?.name ?? 'My Shop',
                              style: AppTextStyles.titleSm.copyWith(color: colors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (shop?.businessType != null)
                              Text(
                                shop!.businessType.toUpperCase(),
                                style: AppTextStyles.labelSm.copyWith(
                                  color: colors.textTertiary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (permissions.canAccessSettings)
                        GestureDetector(
                          onTap: () => context.push('/settings'),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: colors.border),
                            ),
                            child: Icon(Icons.settings_outlined, size: 20, color: colors.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Today's Overview ──
              summaryAsync.when(
                data: (summary) {
                  final numBills = summary.todaysTransactionCount;
                  final avgBill = numBills > 0 ? (summary.todaysSales / Decimal.fromInt(numBills)).toDecimal(scaleOnInfinitePrecision: 2) : Decimal.zero;

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Metric Grid 2x2
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _MetricTile(
                                    label: 'Revenue',
                                    value: '₹${summary.todaysSales.toDouble().toStringAsFixed(0)}',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _MetricTile(
                                    label: 'Bills',
                                    value: '$numBills',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _MetricTile(
                                    label: 'Profit',
                                    value: '₹${summary.todaysProfit.toDouble().toStringAsFixed(0)}',
                                    valueColor: summary.todaysProfit > Decimal.zero ? colors.success : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _MetricTile(
                                    label: 'Avg Bill',
                                    value: '₹${avgBill.toDouble().toStringAsFixed(0)}',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Low Stock Alert ──
                      if (summary.lowStockProductsList.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _LowStockBanner(
                            count: summary.lowStockProductsList.length,
                            products: summary.lowStockProductsList,
                            onViewAll: () => context.go('/products'),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // ── Top Selling ──
                      if (summary.recentProducts.isNotEmpty) ...[
                        _SectionHeader(title: 'Top Selling'),
                        ...summary.recentProducts.take(5).toList().asMap().entries.map(
                          (entry) => _TopProductRow(
                            rank: entry.key + 1,
                            product: entry.value,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // ── Business Health ──
                      _SectionHeader(title: 'Stock Health'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _HealthStat(
                                label: 'In Stock',
                                value: '${summary.totalProducts}',
                                color: colors.textPrimary,
                              ),
                            ),
                            Container(width: 1, height: 32, color: colors.border),
                            Expanded(
                              child: _HealthStat(
                                label: 'Low Stock',
                                value: '${summary.lowStockProducts}',
                                color: colors.warning,
                              ),
                            ),
                            Container(width: 1, height: 32, color: colors.border),
                            Expanded(
                              child: _HealthStat(
                                label: 'Out',
                                value: '${summary.outOfStockProducts}',
                                color: colors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ]),
                  );
                },
                loading: () => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(children: [
                          Expanded(child: ShimmerMetricCard()),
                          const SizedBox(width: 10),
                          Expanded(child: ShimmerMetricCard()),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: ShimmerMetricCard()),
                          const SizedBox(width: 10),
                          Expanded(child: ShimmerMetricCard()),
                        ]),
                      ],
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: AppEmptyState(
                      icon: Icons.cloud_off,
                      title: 'Unable to load data',
                      explanation: 'Check your connection and try again.',
                      actionLabel: 'Retry',
                      onAction: () => ref.invalidate(dashboardSummaryProvider),
                    ),
                  ),
                ),
              ),

              // ── Recent Sales ──
              SliverToBoxAdapter(child: _SectionHeader(title: 'Recent Sales')),
              activityAsync.when(
                data: (logs) {
                  final salesLogs = logs.where((l) => l.action == 'SALE_CREATED').toList();
                  if (salesLogs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AppEmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'No sales yet',
                          explanation: 'Start selling to see transactions here.',
                          actionLabel: 'Make a Sale',
                          onAction: () => context.push('/pos'),
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final log = salesLogs[index];
                        return _SaleRow(
                          customer: log.details?['customerName'] ?? 'Walk-in',
                          amount: log.details?['total'] ?? 0,
                          time: log.createdAt,
                        );
                      },
                      childCount: salesLogs.length > 5 ? 5 : salesLogs.length,
                    ),
                  );
                },
                loading: () => SliverToBoxAdapter(
                  child: Column(
                    children: List.generate(3, (_) => const ShimmerProductRow()),
                  ),
                ),
                error: (e, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Header ──
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        title,
        style: AppTextStyles.labelMd.copyWith(
          color: context.colors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Metric Tile ──
class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MetricTile({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, val, child) {
              return Opacity(
                opacity: val,
                child: Text(
                  value,
                  style: AppTextStyles.monoLg.copyWith(
                    color: valueColor ?? colors.textPrimary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Low Stock Banner ──
class _LowStockBanner extends StatelessWidget {
  final int count;
  final List<Map<String, dynamic>> products;
  final VoidCallback onViewAll;

  const _LowStockBanner({
    required this.count,
    required this.products,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onViewAll,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_amber_rounded, size: 18, color: colors.warning),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count products low on stock',
                    style: AppTextStyles.labelMd.copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    products.take(2).map((p) => p['name'] ?? '').join(', '),
                    style: AppTextStyles.bodySm.copyWith(color: colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ── Top Product Row ──
class _TopProductRow extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> product;

  const _TopProductRow({required this.rank, required this.product});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = product['name'] ?? 'Unknown';
    final price = product['sellingPrice'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: AppTextStyles.labelMd.copyWith(color: colors.textTertiary),
            ),
          ),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.bodyMd.copyWith(color: colors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (price != null)
            Text(
              '₹$price',
              style: AppTextStyles.monoSm.copyWith(color: colors.textSecondary),
            ),
        ],
      ),
    );
  }
}

// ── Health Stat ──
class _HealthStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HealthStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.monoMd.copyWith(color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(color: context.colors.textSecondary),
        ),
      ],
    );
  }
}

// ── Sale Row ──
class _SaleRow extends StatelessWidget {
  final String customer;
  final num amount;
  final DateTime time;

  const _SaleRow({required this.customer, required this.amount, required this.time});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.elevatedCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt_long_outlined, size: 16, color: colors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer,
                  style: AppTextStyles.bodyMd.copyWith(color: colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  timeago.format(time),
                  style: AppTextStyles.bodySm.copyWith(color: colors.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: AppTextStyles.monoSm.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
