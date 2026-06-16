import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/features/product/presentation/providers/products_provider.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    final String barcode = barcodes.first.rawValue!;
    setState(() => _isProcessing = true);
    
    _controller.stop(); // Pause scanning

    try {
      // Cascading search: Barcode -> SKU -> Name
      // Our backend findAll endpoint supports `search` which does ILIKE on name.
      // But we probably want a specific endpoint to find by barcode or sku, or use findAll with a specific filter.
      // We will fetch products and try to match locally if we have a small set, or better, we modify `fetchProducts` or call an API.
      // For now, let's fetch products with `search=barcode`
      
      final productsNotifier = ref.read(productsProvider.notifier);
      await productsNotifier.fetchProducts(search: barcode, refresh: true);
      final productsState = ref.read(productsProvider);
      
      if (productsState.products.value?.isNotEmpty == true) {
        // If found, go to details
        if (mounted) {
          context.replaceNamed('products-details', extra: productsState.products.value!.first);
        }
      } else {
        // If not found, go to add product with barcode pre-filled
        if (mounted) {
          // We can pass the barcode as extra or query param to product form
          // Actually ProductFormScreen takes a product object for edit, or we can just pass a dummy map or string.
          // In ProductFormScreen we might need to handle this. For now we will just pop with the barcode.
          context.pop(barcode);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isProcessing = false);
        _controller.start(); // Resume
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: Container(),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16))),
      ),
      paint,
    );
    
    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    canvas.drawRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
