import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/inventory/data/repositories/inventory_repository.dart';
import 'package:storemate/features/inventory/data/models/inventory_log_model.dart';
import 'package:intl/intl.dart';

final inventoryHistoryProvider = FutureProvider.family.autoDispose<List<InventoryLogModel>, String>((ref, productId) async {
  final repo = ref.read(inventoryRepositoryProvider);
  final response = await repo.getHistory(productId, page: 1, limit: 50);
  final data = response['data'] as List;
  return data.map((json) => InventoryLogModel.fromJson(json)).toList();
});

class InventoryHistoryTab extends ConsumerWidget {
  final String productId;

  const InventoryHistoryTab({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsyncValue = ref.watch(inventoryHistoryProvider(productId));

    return historyAsyncValue.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const Center(child: Text('No inventory history found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final log = logs[index];
            final isAddition = log.quantityChange > 0;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isAddition ? Colors.green.shade100 : Colors.red.shade100,
                child: Icon(
                  isAddition ? Icons.add : Icons.remove,
                  color: isAddition ? Colors.green : Colors.red,
                ),
              ),
              title: Text(log.actionType.replaceAll('_', ' ').toUpperCase()),
              subtitle: Text(
                '${DateFormat('MMM d, y h:mm a').format(log.createdAt)}\nBy: ${log.createdByName ?? log.createdBy}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isAddition ? '+' : ''}${log.quantityChange}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isAddition ? Colors.green : Colors.red,
                    ),
                  ),
                  Text('Balance: ${log.quantityAfter}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              isThreeLine: true,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
