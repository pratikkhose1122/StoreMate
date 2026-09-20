import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
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
        backgroundColor: context.colors.background,
        appBar: AppBar(
          title: Text(product.name),
          bottom: TabBar(
            labelColor: context.colors.primary,
            unselectedLabelColor: context.colors.textSecondary,
            indicatorColor: context.colors.primary,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'History'),
              Tab(text: 'Analytics'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit, color: context.colors.textSecondary),
              onPressed: () => context.push('/products/edit', extra: product),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildDetailsTab(context),
            InventoryHistoryTab(productId: product.id),
            Center(child: Text('Analytics Coming Soon in Phase 4', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textSecondary))),
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
          if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.border),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.network(
                  product.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: 100, color: context.colors.textSecondary),
                ),
              ),
            )
          else
            Center(
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.colors.elevatedCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.border),
                ),
                child: Icon(Icons.image, size: 100, color: context.colors.textSecondary),
              ),
            ),
            
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: [
                _buildInfoRow(context, 'SKU', product.sku ?? 'N/A'),
                Divider(color: context.colors.border, height: 16),
                _buildInfoRow(context, 'Barcode', product.barcode ?? 'N/A'),
                Divider(color: context.colors.border, height: 16),
                _buildInfoRow(context, 'Type', product.productType),
                Divider(color: context.colors.border, height: 16),
                _buildInfoRow(context, 'Category', product.category?.name ?? 'Uncategorized'),
                Divider(color: context.colors.border, height: 32),
                _buildInfoRow(context, 'Purchase Price', '₹${product.purchasePrice.toStringAsFixed(2)}'),
                Divider(color: context.colors.border, height: 16),
                _buildInfoRow(context, 'Selling Price', '₹${product.sellingPrice.toStringAsFixed(2)}'),
                Divider(color: context.colors.border, height: 16),
                _buildInfoRow(context, 'Tax', '${product.taxPercentage}%'),
                Divider(color: context.colors.border, height: 32),
                _buildInfoRow(context, 'Quantity', '${product.quantity} ${product.unitType}'),
                Divider(color: context.colors.border, height: 16),
                _buildInfoRow(context, 'Status', product.status.toUpperCase()),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: context.colors.background,
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.labelMd.copyWith(color: context.colors.textSecondary)),
          Text(value, style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary)),
        ],
      ),
    );
  }
}
