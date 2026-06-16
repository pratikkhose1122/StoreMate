import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/features/customer/presentation/providers/customers_provider.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: customersAsync.when(
        data: (customers) {
          if (customers.isEmpty) {
            return const Center(child: Text('No customers found.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(customersProvider.notifier).fetchCustomers(),
            child: ListView.separated(
              itemCount: customers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final customer = customers[index];
                return ListTile(
                  title: Text(customer.name),
                  subtitle: Text(customer.mobileNumber ?? 'No phone'),
                  trailing: Text(
                    '₹${customer.currentBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: customer.currentBalance > 0 ? AppColors.error : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // Navigate to customer details/form
                    context.push('/customers/${customer.id}', extra: customer);
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/customers/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
