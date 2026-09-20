import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/customer/data/models/customer_model.dart';
import 'package:storemate/features/sales/data/models/sale_model.dart';
import 'package:storemate/features/sales/data/models/return_model.dart';
import 'package:storemate/features/sales/presentation/providers/sales_provider.dart';
import 'package:storemate/features/sales/presentation/providers/refund_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CustomerDetailsScreen extends ConsumerWidget {
  final CustomerModel customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesHistoryProvider);
    final returnsAsync = ref.watch(customerReturnsProvider(customer.id));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: context.colors.primary),
            onPressed: () => context.push('/customers/edit', extra: customer),
          ),
        ],
      ),
      body: salesAsync.when(
        data: (sales) {
          return returnsAsync.when(
            data: (returns) {
              // Filter sales for this customer
              final customerSales = sales.where((s) => s.customer?.id == customer.id).toList();
              
              // Merge into a timeline
              final timeline = <dynamic>[...customerSales, ...returns];
              timeline.sort((a, b) {
                final aDate = (a is SaleModel) ? (a.createdAt ?? DateTime.now()) : (a as ReturnModel).createdAt ?? DateTime.now();
                final bDate = (b is SaleModel) ? (b.createdAt ?? DateTime.now()) : (b as ReturnModel).createdAt ?? DateTime.now();
                return bDate.compareTo(aDate);
              });
              
              final totalBills = customerSales.length;
          final lifetimeSpend = customerSales.fold<Decimal>(Decimal.zero, (sum, sale) => sum + sale.netAmount);
          final avgBill = totalBills > 0 ? lifetimeSpend / totalBills : 0.0;
          
          final lastVisit = customerSales.isNotEmpty ? customerSales.first.createdAt : null;
          final firstPurchase = customerSales.isNotEmpty ? customerSales.last.createdAt : null;
          final customerSince = customer.createdAt ?? firstPurchase ?? DateTime.now();

          // Calculate Favorite Product
          final productCounts = <String, Decimal>{};
          for (var sale in customerSales) {
            for (var item in sale.items) {
              productCounts[item.productName] = (productCounts[item.productName] ?? Decimal.zero) + item.quantity;
            }
          }
          String favoriteProduct = 'None';
          if (productCounts.isNotEmpty) {
            final favorite = productCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
            favoriteProduct = '${favorite.key} (${favorite.value})';
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                        child: Text(
                          customer.name.substring(0, 1).toUpperCase(),
                          style: AppTextStyles.displayMd.copyWith(color: context.colors.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(customer.name, style: AppTextStyles.titleLg.copyWith(color: context.colors.textPrimary)),
                      if (customer.mobileNumber != null)
                        Text(customer.mobileNumber!, style: AppTextStyles.bodyMd.copyWith(color: context.colors.textSecondary)),
                      const SizedBox(height: 24),
                      
                      // Metrics Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _MetricCard(title: 'Lifetime Spend', value: '₹${lifetimeSpend.toStringAsFixed(2)}'),
                          _MetricCard(title: 'Total Bills', value: totalBills.toString()),
                          _MetricCard(title: 'Average Bill', value: '₹${avgBill.toStringAsFixed(2)}'),
                          _MetricCard(title: 'Customer Since', value: DateFormat.yMMM().format(customerSince)),
                          _MetricCard(title: 'Last Visit', value: lastVisit != null ? timeago.format(lastVisit) : 'Never'),
                          _MetricCard(title: 'Favorite Product', value: favoriteProduct, isSmall: true),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Purchase History', style: AppTextStyles.titleMd.copyWith(color: context.colors.textPrimary)),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              
              if (timeline.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('No purchase history found.', style: TextStyle(color: context.colors.textSecondary)),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = timeline[index];
                      
                      if (item is SaleModel) {
                        return ListTile(
                          title: Row(
                            children: [
                              Text('Invoice #${item.invoiceNumber}', style: TextStyle(color: context.colors.textPrimary)),
                              if (item.status != 'completed') ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.status == 'fully_refunded' ? context.colors.danger.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: item.status == 'fully_refunded' ? context.colors.danger : Colors.orange),
                                  ),
                                  child: Text(
                                    item.status == 'fully_refunded' ? 'Refunded' : 'Partial Refund',
                                    style: AppTextStyles.labelSm.copyWith(color: item.status == 'fully_refunded' ? context.colors.danger : Colors.orange, fontSize: 10),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(DateFormat.yMMMd().format(item.createdAt ?? DateTime.now()), style: TextStyle(color: context.colors.textSecondary)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('₹${item.netAmount.toStringAsFixed(2)}', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () => context.push('/sales/${item.id}'),
                        );
                      } else if (item is ReturnModel) {
                        final totalItemsRefunded = item.items.fold<Decimal>(Decimal.zero, (sum, i) => sum + i.quantity);
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.colors.danger.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.colors.danger.withValues(alpha: 0.3)),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.colors.danger.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.settings_backup_restore, color: context.colors.danger, size: 20),
                            ),
                            title: Text('Refund', style: TextStyle(color: context.colors.danger, fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(DateFormat.yMMMd().format(item.createdAt ?? DateTime.now()), style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
                                const SizedBox(height: 4),
                                // We don't have the exact invoice number easily available on ReturnModel without a join, but in the checklist the user just said Invoice INV-1045
                                // The ReturnModel has sale_id, but the join in refund_repository didn't include the sales table for invoice_number.
                                // I will show the Refund Number and Reason. 
                                Text('Refund ${item.refundNumber}', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 2),
                                Text('₹${item.refundAmount.toStringAsFixed(2)} • $totalItemsRefunded Items', style: TextStyle(color: context.colors.textPrimary)),
                                if (item.reason != null) ...[
                                  const SizedBox(height: 2),
                                  Text('Reason: ${item.reason}', style: TextStyle(color: context.colors.textSecondary, fontStyle: FontStyle.italic)),
                                ],
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    childCount: timeline.length,
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: context.colors.danger))),
      );
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: context.colors.danger))),
  ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isSmall;

  const _MetricCard({required this.title, required this.value, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: AppTextStyles.labelSm.copyWith(color: Theme.of(context).hintColor)),
          const SizedBox(height: 4),
          Text(
            value, 
            style: isSmall 
                ? AppTextStyles.bodyMd.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold) 
                : AppTextStyles.titleLg.copyWith(color: Theme.of(context).primaryColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
