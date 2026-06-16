import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_constants.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/auth/domain/auth_state.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';
import 'package:storemate/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:storemate/core/utils/permission_utils.dart';
import 'package:storemate/features/activity_logs/presentation/providers/activity_log_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Listen for logout
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        context.go('/login');
      }
    });

    final shop = authState.shop;
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final activityAsync = ref.watch(recentActivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(shop?.name ?? AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardSummaryProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              shop?.shopCode ?? '',
                              style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome back, ${shop?.ownerName ?? "Owner"}',
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shop?.name ?? '',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Quick Actions Grid
                Text('Quick Actions', style: AppTextStyles.h4),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                  children: [
                    if (PermissionUtils.hasPermission(authState.user?.role, AppPermission.POS_CHECKOUT))
                      _buildModuleCard(
                        context,
                        Icons.point_of_sale,
                        'POS',
                        'New Sale',
                        Colors.green,
                        onTap: () => context.push('/pos'),
                      ),
                    if (PermissionUtils.hasPermission(authState.user?.role, AppPermission.MANAGE_PRODUCTS))
                      _buildModuleCard(
                        context,
                        Icons.inventory_2_outlined,
                        'Products',
                        'Manage catalog',
                        AppColors.primary,
                        onTap: () => context.push('/products'),
                      ),
                    if (PermissionUtils.hasPermission(authState.user?.role, AppPermission.MANAGE_CUSTOMERS))
                      _buildModuleCard(
                        context,
                        Icons.people_outline,
                        'Customers',
                        'Manage users',
                        Colors.orange,
                        onTap: () => context.push('/customers'),
                      ),
                    if (PermissionUtils.hasPermission(authState.user?.role, AppPermission.MANAGE_PRODUCTS))
                      _buildModuleCard(
                        context,
                        Icons.category_outlined,
                        'Categories',
                        'Organize items',
                        Colors.purple,
                        onTap: () => context.push('/categories'),
                      ),
                    if (PermissionUtils.hasPermission(authState.user?.role, AppPermission.VIEW_REPORTS))
                      _buildModuleCard(
                        context,
                        Icons.receipt_long_outlined,
                        'Sales History',
                        'View invoices',
                        Colors.blue,
                        onTap: () => context.push('/sales'),
                      ),
                    if (PermissionUtils.hasPermission(authState.user?.role, AppPermission.MANAGE_STAFF))
                      _buildModuleCard(
                        context,
                        Icons.manage_accounts,
                        'Staff',
                        'Manage team',
                        Colors.teal,
                        onTap: () => context.push('/staff'),
                      ),
                    if (PermissionUtils.hasPermission(authState.user?.role, AppPermission.VIEW_REPORTS))
                      _buildModuleCard(
                        context,
                        Icons.bar_chart,
                        'Reports',
                        'View analytics',
                        Colors.red,
                        onTap: () => context.push('/reports'),
                      ),
                  ],
                ),

                const SizedBox(height: 28),

                // Inventory Summary
                Text('Inventory Summary', style: AppTextStyles.h4),
                const SizedBox(height: 12),
                
                summaryAsync.when(
                  data: (summary) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        children: [
                          _buildMetricCard('Today\'s Sales', '₹${summary.todaysSales.toStringAsFixed(0)}', Icons.monetization_on, Colors.green),
                          _buildMetricCard('Today\'s Profit', '₹${summary.todaysProfit.toStringAsFixed(0)}', Icons.trending_up, Colors.blue),
                          _buildMetricCard('Total Products', summary.totalProducts.toString(), Icons.shopping_bag_outlined, Colors.purple),
                          _buildMetricCard('Low Stock', summary.lowStockProducts.toString(), Icons.warning_amber_rounded, Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 28),
                      
                      if (summary.lowStockProductsList.isNotEmpty) ...[
                        Text('Low Stock Alerts', style: AppTextStyles.h4.copyWith(color: AppColors.error)),
                        const SizedBox(height: 12),
                        _buildListCard(
                          summary.lowStockProductsList,
                          (item) => ListTile(
                            leading: const Icon(Icons.warning, color: Colors.orange),
                            title: Text(item['name']),
                            subtitle: Text('Stock: ${item['quantity']} (Threshold: ${item['lowStockThreshold']})'),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                      
                      if (summary.recentMovements.isNotEmpty) ...[
                        Text('Recent Stock Movements', style: AppTextStyles.h4),
                        const SizedBox(height: 12),
                        _buildListCard(
                          summary.recentMovements,
                          (item) {
                            final isAddition = item['quantityChange'] > 0;
                            return ListTile(
                              leading: Icon(
                                isAddition ? Icons.add_circle : Icons.remove_circle,
                                color: isAddition ? Colors.green : Colors.red,
                              ),
                              title: Text(item['product']?['name'] ?? 'Unknown Product'),
                              subtitle: Text(item['actionType']?.toString().toUpperCase() ?? ''),
                              trailing: Text(
                                '${isAddition ? '+' : ''}${item['quantityChange']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isAddition ? Colors.green : Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),
                      ],
                      
                      if (PermissionUtils.hasPermission(authState.user?.role, AppPermission.VIEW_REPORTS)) ...[
                        Text('Recent Staff Activity', style: AppTextStyles.h4),
                        const SizedBox(height: 12),
                        activityAsync.when(
                          data: (logs) {
                            if (logs.isEmpty) {
                              return const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('No recent activity.'),
                                ),
                              );
                            }
                            return _buildListCard(
                              logs,
                              (log) {
                                String title = '';
                                IconData icon = Icons.info_outline;
                                Color color = Colors.grey;

                                switch (log.action) {
                                  case 'SALE_CREATED':
                                    title = '${log.user.name ?? 'Staff'} sold ₹${log.details?['total'] ?? 0}';
                                    icon = Icons.receipt;
                                    color = Colors.green;
                                    break;
                                  case 'INVENTORY_ADJUSTED':
                                    title = '${log.user.name ?? 'Staff'} adjusted stock';
                                    icon = Icons.inventory;
                                    color = Colors.orange;
                                    break;
                                  case 'CUSTOMER_CREATED':
                                    title = '${log.user.name ?? 'Staff'} added customer';
                                    icon = Icons.person_add;
                                    color = Colors.blue;
                                    break;
                                  default:
                                    title = '${log.user.name ?? 'Staff'} performed ${log.action}';
                                }

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: color.withValues(alpha: 0.2),
                                    child: Icon(icon, color: color, size: 20),
                                  ),
                                  title: Text(title, style: AppTextStyles.bodyMedium),
                                  subtitle: Text(timeago.format(log.createdAt), style: AppTextStyles.caption),
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text('Error loading activity: $e'),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ],
                  ),
                  loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                  error: (e, _) => Center(child: Text('Failed to load: $e')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    {required VoidCallback onTap}
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 12),
              Text(title, style: AppTextStyles.labelLarge),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(value, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildListCard(List items, Widget Function(dynamic) itemBuilder) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) => itemBuilder(items[index]),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: AppTextStyles.h3),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(100, 42),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
