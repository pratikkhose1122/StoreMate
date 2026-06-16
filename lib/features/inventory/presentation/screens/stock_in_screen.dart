import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/features/product/data/models/product_model.dart';
import 'package:storemate/features/product/presentation/providers/products_provider.dart';
import 'package:storemate/features/inventory/data/repositories/inventory_repository.dart';
import 'package:storemate/shared/widgets/custom_button.dart';

class StockInScreen extends ConsumerStatefulWidget {
  const StockInScreen({super.key});

  @override
  ConsumerState<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends ConsumerState<StockInScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final _quantityController = TextEditingController();
  
  ProductModel? _scannedProduct;
  bool _isProcessing = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _scannedProduct != null) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    final String barcode = barcodes.first.rawValue!;
    setState(() => _isProcessing = true);
    
    _scannerController.stop();

    try {
      final productsNotifier = ref.read(productsProvider.notifier);
      await productsNotifier.fetchProducts(search: barcode, refresh: true);
      final productsState = ref.read(productsProvider);
      
      if (productsState.products.value?.isNotEmpty == true) {
        setState(() {
          _scannedProduct = productsState.products.value!.first;
          _isProcessing = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product not found!')));
          setState(() => _isProcessing = false);
          _scannerController.start();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isProcessing = false);
        _scannerController.start();
      }
    }
  }

  Future<void> _submitStockIn() async {
    final qtyText = _quantityController.text.trim();
    if (qtyText.isEmpty) return;
    
    final qty = int.tryParse(qtyText);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid quantity')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(inventoryRepositoryProvider).adjustInventory(
        _scannedProduct!.id,
        qty,
        'stock_in',
        'Stock In via scanner workflow',
      );
      
      ref.read(productsProvider.notifier).fetchProducts(refresh: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock added successfully!')));
        // Reset to scan next item
        setState(() {
          _scannedProduct = null;
          _quantityController.clear();
          _isLoading = false;
        });
        _scannerController.start();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock In Workflow')),
      body: _scannedProduct == null ? _buildScanner() : _buildQuantityForm(),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onDetect,
        ),
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        const Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Scan product barcode to restock',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Product Identified:', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(_scannedProduct!.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Current Stock: ${_scannedProduct!.quantity} ${_scannedProduct!.unitType}', style: const TextStyle(fontSize: 16)),
          const Divider(height: 32),
          
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Quantity to Add',
              suffixText: _scannedProduct!.unitType,
              border: const OutlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 24),
            autofocus: true,
          ),
          
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _scannedProduct = null);
                    _quantityController.clear();
                    _scannerController.start();
                  },
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Cancel & Rescan'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Confirm',
                  isLoading: _isLoading,
                  onPressed: _submitStockIn,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
