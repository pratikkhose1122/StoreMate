import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/features/sales/presentation/providers/sales_provider.dart';

class SalesHistoryScreen extends ConsumerWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesHistoryAsync = ref.watch(salesHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sales History')),
      body: salesHistoryAsync.when(
        data: (sales) {
          if (sales.isEmpty) {
            return const Center(child: Text('No sales found.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(salesHistoryProvider.notifier).fetchSales(refresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sales.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final sale = sales[index];
                return ListTile(
                  title: Text(sale.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${sale.customer?.name ?? 'Walk-in'} • ${DateFormat.yMd().add_jm().format(sale.createdAt ?? DateTime.now())}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${sale.netAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (sale.amountDue > 0)
                        Text(
                          'Due: ₹${sale.amountDue.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                    ],
                  ),
                  onTap: () => context.push('/sales/${sale.id}'),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
