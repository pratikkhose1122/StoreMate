import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/constants/api_constants.dart';
import 'package:storemate/features/product/data/models/product_model.dart';
import 'package:storemate/features/inventory/presentation/widgets/inventory_adjustment_modal.dart';
import 'inventory_history_tab.dart';
import 'package:go_router/go_router.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'History'),
              Tab(text: 'Analytics'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/products/edit', extra: product),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildDetailsTab(context),
            InventoryHistoryTab(productId: product.id),
            const Center(child: Text('Analytics Coming Soon in Phase 4')),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.imageUrl != null)
            Center(
              child: Image.network(
                '${ApiConstants.baseUrl}${product.imageUrl}',
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 100),
              ),
            )
          else
            const Center(child: Icon(Icons.image, size: 100, color: Colors.grey)),
            
          const SizedBox(height: 24),
          _buildInfoRow('SKU', product.sku ?? 'N/A'),
          _buildInfoRow('Barcode', product.barcode ?? 'N/A'),
          _buildInfoRow('Category', product.category?.name ?? 'N/A'),
          const Divider(height: 32),
          _buildInfoRow('Purchase Price', '₹${product.purchasePrice.toStringAsFixed(2)}'),
          _buildInfoRow('Selling Price', '₹${product.sellingPrice.toStringAsFixed(2)}'),
          _buildInfoRow('Tax', '${product.taxPercentage}%'),
          const Divider(height: 32),
          _buildInfoRow('Quantity', '${product.quantity} ${product.unitType}'),
          _buildInfoRow('Status', product.status.toUpperCase()),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => InventoryAdjustmentModal(product: product),
                );
              },
              icon: const Icon(Icons.inventory),
              label: const Text('Adjust Inventory'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        ],
      ),
    );
  }
}
