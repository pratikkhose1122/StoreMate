import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_constants.dart';
import 'package:storemate/features/category/presentation/providers/categories_provider.dart';
import 'package:storemate/features/product/data/models/product_model.dart';
import 'package:storemate/features/product/presentation/providers/products_provider.dart';
import 'package:storemate/features/product/data/repositories/product_repository.dart';
import 'package:storemate/features/product/data/repositories/global_catalog_repository.dart';
import 'package:storemate/shared/widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storemate/features/product/data/utils/user_correction_cache.dart';
import 'package:storemate/features/product/data/utils/scan_session_cache.dart';
import 'package:decimal/decimal.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final ProductModel? product;
  final String? initialBarcode;
  final Map<String, dynamic>? prefillData;

  const ProductFormScreen({super.key, this.product, this.initialBarcode, this.prefillData});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _brandController = TextEditingController();
  final _packageSizeController = TextEditingController();
  final _purchaseController = TextEditingController();
  final _sellingController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _lowStockController = TextEditingController(text: '5');

  String? _selectedCategory;
  String _selectedUnit = 'piece';
  String _selectedStatus = 'active';

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isFormValid = false;
  bool _isMoreDetailsExpanded = false;
  bool _hasPackageImage = false;

  @override
  void initState() {
    super.initState();
    
    _nameController.addListener(_validateForm);
    _sellingController.addListener(_validateForm);
    _stockController.addListener(_validateForm);

    if (widget.product != null) {
      final p = widget.product!;
      _nameController.text = p.name;
      _descController.text = p.description ?? '';
      _skuController.text = p.sku ?? '';
      _barcodeController.text = p.barcode ?? '';
      _brandController.text = p.brand ?? '';
      _packageSizeController.text = p.packageSize ?? '';
      _purchaseController.text = p.purchasePrice.toString();
      _sellingController.text = p.sellingPrice.toString();
      _stockController.text = p.quantity.toString();
      _lowStockController.text = p.lowStockThreshold.toString();
      _selectedCategory = p.categoryId;
      _selectedUnit = p.unitType;
      _selectedStatus = p.status;
      
      if ((p.brand?.isNotEmpty ?? false) || 
          (p.packageSize?.isNotEmpty ?? false) || 
          (p.sku?.isNotEmpty ?? false) || 
          (p.barcode?.isNotEmpty ?? false) ||
          (p.description?.isNotEmpty ?? false) ||
          p.purchasePrice > Decimal.zero) {
        _isMoreDetailsExpanded = true;
      }
    } else {
      if (widget.initialBarcode != null) {
        _barcodeController.text = widget.initialBarcode!;
      }
      if (widget.prefillData != null) {
        _populateFromScannedProduct(widget.prefillData!);
      }
      
      final cachedBytes = ScanSessionCache.instance.lastImageBytes;
      if (cachedBytes != null) {
        _hasPackageImage = true;
        _initTempImage(cachedBytes);
      }
    }
  }
  
  Future<void> _initTempImage(Uint8List bytes) async {
     final tempDir = await getTemporaryDirectory();
     final file = File('${tempDir.path}/${const Uuid().v4()}.jpg');
     await file.writeAsBytes(bytes);
     if (mounted) {
       setState(() {
         _selectedImage = XFile(file.path);
       });
     }
  }

  void _populateFromScannedProduct(Map<String, dynamic> data) {
    if (_barcodeController.text.isEmpty && data['barcode'] != null) {
      _barcodeController.text = data['barcode'].toString();
    }
    if (_nameController.text.isEmpty && data['name'] != null) {
      _nameController.text = data['name'].toString();
    }
    if (_brandController.text.isEmpty && data['brand'] != null) {
      _brandController.text = data['brand'].toString();
    }
    if (_descController.text.isEmpty && data['description'] != null) {
      _descController.text = data['description'].toString();
    }

    final pkgSize = data['packageSize']?.toString() ?? data['quantity']?.toString() ?? '';
    if (_packageSizeController.text.isEmpty && pkgSize.isNotEmpty) {
      _packageSizeController.text = pkgSize;
    }

    if (pkgSize.isNotEmpty && _selectedUnit == 'piece') {
      final lower = pkgSize.toLowerCase();
      if (lower.contains('ml') || lower.contains('milliliter')) {
        _selectedUnit = 'ml';
      } else if (lower.contains('l') || lower.contains('liter') || lower.contains('litre')) {
        _selectedUnit = 'litre';
      } else if (lower.contains('kg') || lower.contains('kilo')) {
        _selectedUnit = 'kg';
      } else if (lower.contains('g') || lower.contains('gram')) {
        _selectedUnit = 'gram';
      } else if (lower.contains('pack')) {
        _selectedUnit = 'pack';
      } else if (lower.contains('box')) {
        _selectedUnit = 'box';
      } else if (lower.contains('pc') || lower.contains('piece')) {
        _selectedUnit = 'piece';
      }
    }

    if (data['sellingPrice'] != null) {
       _sellingController.text = data['sellingPrice'].toString();
    }

    Future.microtask(() {
      final categories = ref.read(categoriesProvider).valueOrNull ?? [];
      if (_selectedCategory == null && data['categories'] != null && categories.isNotEmpty) {
        final offCategories = data['categories'].toString().toLowerCase().split(',');
        for (final offCat in offCategories) {
          final searchName = offCat.trim();
          if (searchName.isEmpty) continue;
          
          String? matchId;
          for (final c in categories) {
            if (c.name.toLowerCase() == searchName) {
              matchId = c.id;
              break;
            }
          }
          
          if (matchId != null) {
            if (mounted) setState(() => _selectedCategory = matchId);
            break;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _brandController.dispose();
    _packageSizeController.dispose();
    _purchaseController.dispose();
    _sellingController.dispose();
    _stockController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _hasPackageImage = false; // User manually changed it
      });
    }
  }

  void _validateForm() {
    final selling = double.tryParse(_sellingController.text.trim());
    final stock = int.tryParse(_stockController.text.trim());
    
    final isValid = _nameController.text.trim().isNotEmpty &&
        selling != null && selling > 0 && selling < 1000000 &&
        stock != null && stock >= 0;
        
    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (widget.product == null) {
        final currentProducts = ref.read(productsProvider).products.valueOrNull ?? [];
        final newName = _nameController.text.trim().toLowerCase();
        final isDuplicate = currentProducts.any((p) => p.name.toLowerCase() == newName);
        if (isDuplicate) {
          final shouldContinue = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: context.colors.card,
              title: Text('Similar Product Exists', style: TextStyle(color: context.colors.textPrimary)),
              content: Text('A product with this name already exists. Do you want to continue?', style: TextStyle(color: context.colors.textSecondary)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continue')),
              ],
            ),
          );
          if (shouldContinue != true) {
            setState(() => _isLoading = false);
            return;
          }
        }
      }

      final data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        'sku': _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
        'barcode': _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
        'brand': _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        'packageSize': _packageSizeController.text.trim().isEmpty ? null : _packageSizeController.text.trim(),
        'purchasePrice': _purchaseController.text.trim().isEmpty ? Decimal.parse(_sellingController.text.trim()).toString() : Decimal.parse(_purchaseController.text.trim()).toString(),
        'sellingPrice': Decimal.parse(_sellingController.text.trim()).toString(),
        'quantity': int.parse(_stockController.text.trim()),
        'lowStockThreshold': _lowStockController.text.trim().isEmpty ? 5 : int.parse(_lowStockController.text.trim()),
        'categoryId': _selectedCategory,
        'unitType': _selectedUnit,
        'status': _selectedStatus,
      };

      if (widget.prefillData != null && widget.prefillData!['imageUrl'] != null) {
        if (_selectedImage == null && (widget.product == null || widget.product!.imageUrl == null)) {
          data['imageUrl'] = widget.prefillData!['imageUrl'];
        }
      }

      ProductModel savedProduct;
      if (widget.product == null) {
        savedProduct = await ref.read(productsProvider.notifier).addProduct(data);
      } else {
        savedProduct = await ref.read(productsProvider.notifier).updateProduct(widget.product!.id, data);
      }

      if (_selectedImage != null) {
        await ref.read(productRepositoryProvider).uploadImage(savedProduct.id, _selectedImage!.path);
      }
      
      if (widget.prefillData != null && widget.prefillData!['source'] == 'ocr') {
        final submittedName = data['name'].toString().trim();
        final originalOcrName = widget.prefillData!['originalOcrName'] as String?;
        if (originalOcrName != null && submittedName.isNotEmpty) {
          await UserCorrectionCache.save(
            barcode: data['barcode']?.toString(),
            ocrText: originalOcrName,
            correctedName: submittedName,
          );
        }
      }
      
      ref.invalidate(productsProvider);
      
      ref.read(globalCatalogRepositoryProvider).queueUpload(
        barcode: data['barcode']?.toString(),
        data: data,
        confidence: widget.prefillData?['confidence'] ?? 1.0,
        verified: true,
      );
        
      ScanSessionCache.instance.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.product == null ? '✓ Product Added Successfully' : '✓ Product Updated Successfully', style: const TextStyle(color: Colors.white)),
          backgroundColor: context.colors.success,
          behavior: SnackBarBehavior.floating,
        ));
        context.pop(savedProduct);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(BuildContext context, String label, {String? hint, String? prefix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      labelStyle: TextStyle(color: context.colors.textSecondary),
      hintStyle: TextStyle(color: context.colors.textSecondary.withValues(alpha: 0.5)),
      prefixStyle: TextStyle(color: context.colors.textPrimary),
      fillColor: context.colors.card,
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
    );
  }

  Widget _buildAlternativesChips() {
    final confidences = widget.prefillData!['wordConfidences'] as List<dynamic>?;
    if (confidences == null || confidences.isEmpty) return const SizedBox.shrink();

    final chips = <Widget>[];
    for (final wordData in confidences) {
      final alternatives = wordData['alternatives'] as List<dynamic>?;
      if (alternatives != null && alternatives.isNotEmpty) {
        for (final alt in alternatives) {
          chips.add(
            ActionChip(
              label: Text(alt.toString(), style: const TextStyle(fontSize: 12)),
              backgroundColor: context.colors.primary.withValues(alpha: 0.1),
              onPressed: () {
                final currentText = _nameController.text;
                final originalWord = wordData['corrected'].toString();
                _nameController.text = currentText.replaceAll(originalWord, alt.toString());
              },
            ),
          );
        }
      }
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Suggested corrections:', style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: chips,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);
    final isEditing = widget.product != null;

    String? sourceIndicator;
    if (widget.prefillData != null) {
      final source = widget.prefillData!['source'] as String?;
      if (source == 'ocr') {
        sourceIndicator = '📝 Detected from package';
      } else if (source == 'openProductsFacts' || source == 'global') {
        sourceIndicator = '🌍 Found from barcode';
      } else if (source == 'manual') {
        sourceIndicator = '⚠️ Product Not Found';
      }
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body: Column(
        children: [
          if (sourceIndicator != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: context.colors.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: context.colors.primary),
                  const SizedBox(width: 8),
                  Text(sourceIndicator, style: TextStyle(color: context.colors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. PRODUCT NAME
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
                      decoration: _inputDecoration(context, 'Product Name *'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    if (widget.prefillData != null && widget.prefillData!['wordConfidences'] != null)
                      _buildAlternativesChips(),
                    const SizedBox(height: 16),
      
                    // 2. PRODUCT IMAGE
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: context.colors.card,
                            border: Border.all(color: context.colors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: _selectedImage != null
                              ? Image.file(File(_selectedImage!.path), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Icon(Icons.image, color: context.colors.textSecondary))
                              : (widget.product?.imageUrl != null
                                  ? Image.network(widget.product!.imageUrl!, fit: BoxFit.cover)
                                  : (widget.prefillData?.containsKey('imageUrl') == true && widget.prefillData!['imageUrl'].isNotEmpty
                                      ? Image.network(widget.prefillData!['imageUrl'], fit: BoxFit.cover)
                                      : Icon(Icons.image, size: 30, color: context.colors.textSecondary))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_hasPackageImage) ...[
                                Text('✓ Package photo added automatically', style: TextStyle(color: context.colors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                              ],
                              TextButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.photo_camera, size: 18),
                                label: Text(_selectedImage != null || widget.product?.imageUrl != null ? 'Change Photo' : 'Add Photo'),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.centerLeft,
                                  foregroundColor: context.colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 3. CATEGORY
                    categoriesState.when(
                      data: (categories) => DropdownButtonFormField<String?>(
                        initialValue: _selectedCategory,
                        isExpanded: true,
                        decoration: _inputDecoration(context, 'Category'),
                        dropdownColor: context.colors.elevatedCard,
                        style: TextStyle(color: context.colors.textPrimary),
                        items: [
                          DropdownMenuItem(value: null, child: Text('Uncategorized', style: TextStyle(color: context.colors.textPrimary))),
                          ...categories.map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name, style: TextStyle(color: context.colors.textPrimary)),
                              ))
                        ],
                        onChanged: (val) => setState(() => _selectedCategory = val),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Failed to load categories', style: TextStyle(color: context.colors.danger)),
                    ),
                    const SizedBox(height: 16),
      
                    // 4. SELLING PRICE
                    TextFormField(
                      controller: _sellingController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: context.colors.success, fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: _inputDecoration(context, 'Selling Price *', prefix: '₹ '),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
      
                    // 5. STOCK & UNIT
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                            textInputAction: TextInputAction.done,
                            decoration: _inputDecoration(context, 'Stock Quantity *'),
                            style: TextStyle(color: context.colors.textPrimary),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            isExpanded: true,
                            decoration: _inputDecoration(context, 'Unit'),
                            dropdownColor: context.colors.elevatedCard,
                            style: TextStyle(color: context.colors.textPrimary),
                            items: AppConstants.unitTypes
                                .map((u) => DropdownMenuItem(value: u, child: Text(u.toUpperCase(), style: TextStyle(color: context.colors.textPrimary))))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedUnit = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
      
                    // 6. MORE DETAILS (COLLAPSIBLE)
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text('More Details', style: TextStyle(color: context.colors.textSecondary, fontWeight: FontWeight.bold)),
                        initiallyExpanded: _isMoreDetailsExpanded,
                        onExpansionChanged: (v) => setState(() => _isMoreDetailsExpanded = v),
                        tilePadding: EdgeInsets.zero,
                        children: [
                          if (widget.prefillData != null && widget.prefillData!['barcode'] != null && _barcodeController.text.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: context.colors.elevatedCard,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.qr_code, size: 16, color: context.colors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text('Barcode  ${_barcodeController.text}', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  Icon(Icons.check_circle, size: 16, color: context.colors.success),
                                ],
                              ),
                            ),
                          
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _brandController,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(context, 'Brand'),
                                  style: TextStyle(color: context.colors.textPrimary),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _packageSizeController,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(context, 'Package Size'),
                                  style: TextStyle(color: context.colors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
            
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _skuController,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(context, 'SKU'),
                                  style: TextStyle(color: context.colors.textPrimary),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _barcodeController,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(context, 'Barcode'),
                                  style: TextStyle(color: context.colors.textPrimary),
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
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(context, 'Purchase Price', prefix: '₹ '),
                                  style: TextStyle(color: context.colors.textPrimary),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _lowStockController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(context, 'Low Stock Alert'),
                                  style: TextStyle(color: context.colors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
            
                          DropdownButtonFormField<String>(
                            initialValue: _selectedStatus,
                            isExpanded: true,
                            decoration: _inputDecoration(context, 'Status'),
                            dropdownColor: context.colors.elevatedCard,
                            style: TextStyle(color: context.colors.textPrimary),
                            items: AppConstants.productStatuses
                                .map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ').toUpperCase(), style: TextStyle(color: context.colors.textPrimary))))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedStatus = val!),
                          ),
                          const SizedBox(height: 16),
            
                          TextFormField(
                            controller: _descController,
                            textInputAction: TextInputAction.done,
                            decoration: _inputDecoration(context, 'Description'),
                            style: TextStyle(color: context.colors.textPrimary),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // padding for floating button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: isEditing ? 'Update Product' : 'Save Product',
            isLoading: _isLoading,
            onPressed: _isFormValid ? _submit : null,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
