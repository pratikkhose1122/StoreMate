import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/customer/presentation/providers/customers_provider.dart';
import 'package:storemate/core/widgets/app_card.dart';
import 'package:storemate/core/widgets/app_empty_state.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: customersAsync.when(
        data: (customers) {
          if (customers.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: AppEmptyState(
                icon: Icons.people_outline,
                title: 'No customers found',
                explanation: 'Add your first customer to track their balance and sales.',
                actionLabel: 'Add Customer',
                onAction: () => context.push('/customers/new'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(customersProvider.notifier).fetchCustomers(),
            color: context.colors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: customers.length,
              separatorBuilder: (a, b) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final customer = customers[index];
                return AppCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(customer.name, style: AppTextStyles.productMd.copyWith(color: context.colors.textPrimary)),
                    subtitle: Text(customer.mobileNumber ?? 'No phone', style: AppTextStyles.bodySm.copyWith(color: context.colors.textSecondary)),
                    trailing: Text(
                      '₹${customer.currentBalance.toStringAsFixed(2)}',
                      style: AppTextStyles.labelMd.copyWith(
                        color: customer.currentBalance > 0 ? context.colors.danger : context.colors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      context.push('/customers/details', extra: customer);
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load customers',
            explanation: e.toString(),
            actionLabel: 'Retry',
            onAction: () => ref.read(customersProvider.notifier).fetchCustomers(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => context.push('/customers/new'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.primaryForeground,
        child: const Icon(Icons.add),
      ),
    );
  }
}
