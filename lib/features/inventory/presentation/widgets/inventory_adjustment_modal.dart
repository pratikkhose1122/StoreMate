import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/constants/app_constants.dart';
import 'package:storemate/features/inventory/data/repositories/inventory_repository.dart';
import 'package:storemate/features/product/data/models/product_model.dart';
import 'package:storemate/features/product/presentation/providers/products_provider.dart';
import 'package:storemate/shared/widgets/custom_button.dart';

class InventoryAdjustmentModal extends ConsumerStatefulWidget {
  final ProductModel product;

  const InventoryAdjustmentModal({super.key, required this.product});

  @override
  ConsumerState<InventoryAdjustmentModal> createState() => _InventoryAdjustmentModalState();
}

class _InventoryAdjustmentModalState extends ConsumerState<InventoryAdjustmentModal> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedAction = 'stock_in';
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      int change = int.parse(_quantityController.text.trim());
      
      // stock_out and sale are negative adjustments
      if (['stock_out', 'sale'].contains(_selectedAction)) {
        change = -change;
      }

      await ref.read(inventoryRepositoryProvider).adjustInventory(
        widget.product.id,
        change,
        _selectedAction,
        _notesController.text.trim(),
      );

      // Refresh product list to reflect new stock
      ref.read(productsProvider.notifier).fetchProducts(refresh: true);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adjust Inventory', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Product: ${widget.product.name} (Current: ${widget.product.quantity})'),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedAction,
              decoration: const InputDecoration(labelText: 'Action Type'),
              items: AppConstants.inventoryActions
                  .map((a) => DropdownMenuItem(value: a, child: Text(a.replaceAll('_', ' ').toUpperCase())))
                  .toList(),
              onChanged: (val) => setState(() => _selectedAction = val!),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Quantity Change *'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final val = int.tryParse(v);
                if (val == null || val <= 0) return 'Must be > 0';
                if (['stock_out', 'sale'].contains(_selectedAction) && val > widget.product.quantity) {
                  return 'Cannot reduce below 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (Optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'Confirm Adjustment',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
