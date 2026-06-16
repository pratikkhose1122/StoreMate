import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_constants.dart';
import 'package:storemate/features/category/data/models/category_model.dart';
import 'package:storemate/features/category/presentation/providers/categories_provider.dart';
import 'package:storemate/features/product/data/models/product_model.dart';
import 'package:storemate/features/product/presentation/providers/products_provider.dart';
import 'package:storemate/features/product/data/repositories/product_repository.dart';
import 'package:storemate/shared/widgets/custom_button.dart';
import 'package:storemate/core/constants/api_constants.dart';
import 'package:image_picker/image_picker.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final ProductModel? product;
  final String? initialBarcode;

  const ProductFormScreen({super.key, this.product, this.initialBarcode});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _purchaseController = TextEditingController();
  final _sellingController = TextEditingController();
  final _lowStockController = TextEditingController(text: '5');

  String? _selectedCategory;
  String _selectedUnit = 'piece';
  String _selectedStatus = 'active';

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameController.text = p.name;
      _descController.text = p.description ?? '';
      _skuController.text = p.sku ?? '';
      _barcodeController.text = p.barcode ?? '';
      _purchaseController.text = p.purchasePrice.toString();
      _sellingController.text = p.sellingPrice.toString();
      _lowStockController.text = p.lowStockThreshold.toString();
      _selectedCategory = p.categoryId;
      _selectedUnit = p.unitType;
      _selectedStatus = p.status;
    } else if (widget.initialBarcode != null) {
      _barcodeController.text = widget.initialBarcode!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _purchaseController.dispose();
    _sellingController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        'sku': _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
        'barcode': _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
        'purchasePrice': double.parse(_purchaseController.text.trim()),
        'sellingPrice': double.parse(_sellingController.text.trim()),
        'lowStockThreshold': int.parse(_lowStockController.text.trim()),
        'categoryId': _selectedCategory,
        'unitType': _selectedUnit,
        'status': _selectedStatus,
      };

        ProductModel savedProduct;
        if (widget.product == null) {
          savedProduct = await ref.read(productsProvider.notifier).addProduct(data);
        } else {
          savedProduct = await ref.read(productsProvider.notifier).updateProduct(widget.product!.id, data);
        }

        if (_selectedImage != null) {
          await ref.read(productRepositoryProvider).uploadImage(savedProduct.id, _selectedImage!.path);
          ref.read(productsProvider.notifier).fetchProducts(refresh: true);
        }
      if (mounted) context.pop();
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
    final categoriesState = ref.watch(categoriesProvider);
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Image Picker
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImage != null
                        ? Image.network(_selectedImage!.path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
                        : (widget.product?.imageUrl != null
                            ? Image.network('${ApiConstants.baseUrl}${widget.product!.imageUrl}', fit: BoxFit.cover)
                            : const Icon(Icons.image, size: 50, color: Colors.grey)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Select Image'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              categoriesState.when(
                data: (categories) => DropdownButtonFormField<String?>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('No Category')),
                    ...categories.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ))
                  ],
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Failed to load categories'),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skuController,
                      decoration: const InputDecoration(labelText: 'SKU (Optional)'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(labelText: 'Barcode (Optional)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _purchaseController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      decoration: const InputDecoration(labelText: 'Purchase Price *', prefixText: '₹ '),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _sellingController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      decoration: const InputDecoration(labelText: 'Selling Price *', prefixText: '₹ '),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Unit Type'),
                      items: AppConstants.unitTypes
                          .map((u) => DropdownMenuItem(value: u, child: Text(u.toUpperCase())))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedUnit = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lowStockController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Low Stock Alert'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: AppConstants.productStatuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ').toUpperCase())))
                    .toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 3,
              ),

              const SizedBox(height: 32),
              CustomButton(
                text: isEditing ? 'Update Product' : 'Add Product',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
