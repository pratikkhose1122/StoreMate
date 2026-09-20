import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/product/data/models/product_model.dart';
import 'package:storemate/features/product/data/models/identification_result.dart';
import 'package:storemate/features/product/data/repositories/barcode_repository.dart';
import 'package:storemate/features/product/data/repositories/global_catalog_repository.dart';
import 'package:storemate/features/product/data/services/product_identification_service.dart';
import 'package:storemate/features/sales/presentation/providers/cart_provider.dart';
import 'package:storemate/core/widgets/app_button.dart';
import 'package:storemate/core/widgets/app_text_field.dart';
import 'package:storemate/features/product/presentation/screens/package_capture_screen.dart' as package_capture;
import 'package:storemate/features/product/data/utils/scan_session_cache.dart';
import 'package:uuid/uuid.dart';

enum ScannerMode { barcode, package }
enum ScannerState { scanning, processing, resultReady }

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  final bool returnToPos;
  const BarcodeScannerScreen({super.key, this.returnToPos = false});

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.all],
    detectionSpeed: DetectionSpeed.normal,
    returnImage: true, // Crucial for getting the frame instantly
  );
  
  final TextEditingController _manualController = TextEditingController();
  
  ScannerMode _mode = ScannerMode.barcode;
  ScannerState _state = ScannerState.scanning;
  String _statusText = 'Point camera at a barcode';
  
  String? _scannedBarcode;
  IdentificationResult? _result;
  Uint8List? _lastFrameBytes;
  String? _lastFramePath;

  final List<String> _recentScans = [];

  @override
  void dispose() {
    _controller.dispose();
    _manualController.dispose();
    super.dispose();
  }

  Future<String> _saveTempImage(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${const Uuid().v4()}.jpg');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_state != ScannerState.scanning) return;

    if (_mode == ScannerMode.barcode) {
      final List<Barcode> barcodes = capture.barcodes;
      if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

      final String rawBarcode = barcodes.first.rawValue!;
      final String barcode = rawBarcode.trim().replaceAll(RegExp(r'\s+'), '');
      if (barcode.isEmpty) return;

      HapticFeedback.mediumImpact();
      _lastFrameBytes = capture.image;
      
      await _processIdentification(barcode: barcode);
    }
  }



  Future<void> _processIdentification({required String barcode}) async {
    setState(() {
      _state = ScannerState.processing;
      _scannedBarcode = barcode.isNotEmpty ? barcode : null;
      _result = null;
      _statusText = 'Checking Local Databases...';
    });
    _controller.stop(); // Freeze frame UX

    if (barcode.isNotEmpty && !_recentScans.contains(barcode)) {
      _recentScans.insert(0, barcode);
      if (_recentScans.length > 5) _recentScans.removeLast();
    }

    try {
      // 1. Local Store Lookup
      if (barcode.isNotEmpty) {
        final localResult = await ref.read(barcodeRepositoryProvider).lookupLocal(barcode);
        if (localResult != null) {
          _completeWithResult(localResult);
          return;
        }
      }

      setState(() => _statusText = 'Checking Global Knowledge Base...');

      // 2. Global Catalog Lookup (Simulated check)
      final globalRepo = ref.read(globalCatalogRepositoryProvider);
      final globalResult = await globalRepo.lookup(barcode: barcode);
      if (globalResult != null && globalResult.overallConfidence > 0.8) {
        _completeWithResult(globalResult);
        return;
      }

      setState(() => _statusText = 'Identifying Product...');

      // 3. Parallel Execution
      if (_lastFramePath != null) {
        final parallelResult = await ref.read(productIdentificationServiceProvider)
            .identifyParallel(barcode, _lastFramePath!);
            
        // If Global result existed but was low confidence, merge it here
        IdentificationResult finalResult = parallelResult;
        if (globalResult != null) {
           finalResult = finalResult.merge(globalResult);
        }

        _completeWithResult(finalResult);
      } else {
         // No image bytes
         _completeWithResult(ref.read(productIdentificationServiceProvider).manualEntry(barcode));
      }
    } catch (e) {
      _completeWithResult(ref.read(productIdentificationServiceProvider).manualEntry(barcode));
    }
  }

  void _completeWithResult(IdentificationResult result) {
    if (!mounted) return;

    if (result.isLocal) {
        setState(() {
          _result = result;
          _state = ScannerState.resultReady;
        });
        return;
    }

    final conf = result.overallConfidence;
    
    ScanSessionCache.instance.originalPrefill = result.prefillData;
    
    if (conf >= 0.8) {
      // High confidence: Auto-open form
      _openProductForm(result.prefillData);
    } else if (conf >= 0.5) {
      // Medium confidence: Show prompt
      setState(() {
        _result = result;
        _state = ScannerState.resultReady;
      });
    } else {
      // Low confidence
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("We couldn't confidently identify this package."),
          backgroundColor: Colors.orange,
        ),
      );
      _openProductForm(result.prefillData);
    }
  }

  Future<void> _openProductForm(Map<String, dynamic> prefillData) async {
    final newProduct = await context.push<ProductModel?>('/products/add', extra: {'prefill': prefillData});
    if (!mounted) return;
    if (newProduct != null && widget.returnToPos) {
        ref.read(cartProvider.notifier).addProduct(newProduct);
        context.pop();
        return;
    }
    _resumeScanning();
  }

  void _resumeScanning() {
    setState(() {
      _result = null;
      _scannedBarcode = null;
      _state = ScannerState.scanning;
      _statusText = _mode == ScannerMode.barcode ? 'Point camera at a barcode' : 'Point camera at the package';
    });
    _controller.start();
  }



  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Scanner')),
      body: SafeArea(
        child: Column(
          children: [
            // ── Scanner Viewport ──
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                  ),
                  
                  if (_state == ScannerState.processing)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: colors.primary, strokeWidth: 2),
                            const SizedBox(height: 16),
                            Text(
                              _statusText,
                              style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                  CustomPaint(
                    painter: _ScanOverlay(accentColor: colors.primary),
                    child: const SizedBox.expand(),
                  ),
                  
                  // Dual Mode Toggle
                  if (_state == ScannerState.scanning)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildModeToggle(ScannerMode.barcode, 'Barcode', Icons.qr_code_scanner),
                              _buildModeToggle(ScannerMode.package, 'Package', Icons.inventory_2_outlined),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Content Below Scanner ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_result != null && _state == ScannerState.resultReady) ...[
                      _buildResultCard(),
                      const SizedBox(height: 16),
                    ],

                    if (_state == ScannerState.scanning) ...[
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _manualController,
                              hintText: 'Enter barcode manually...',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icon(Icons.keyboard_outlined, size: 18, color: colors.textTertiary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              if (_manualController.text.isNotEmpty) {
                                _processIdentification(barcode: _manualController.text);
                                _manualController.clear();
                              }
                            },
                            child: Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: colors.elevatedCard,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: colors.border),
                              ),
                              child: Icon(Icons.arrow_forward, color: colors.textPrimary, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (_recentScans.isNotEmpty && _state == ScannerState.scanning) ...[
                      Text('Recent Scans', style: AppTextStyles.labelMd.copyWith(color: colors.textSecondary)),
                      const SizedBox(height: 8),
                      ..._recentScans.map((b) => _buildRecentRow(b)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle(ScannerMode mode, String label, IconData icon) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () async {
        if (mode == ScannerMode.package) {
          final imagePath = await Navigator.of(context).push<String>(
            MaterialPageRoute(builder: (_) => const package_capture.PackageCaptureScreen()),
          );
          if (imagePath != null && imagePath.isNotEmpty) {
            HapticFeedback.heavyImpact();
            _lastFramePath = imagePath;
            
            final fileBytes = await File(imagePath).readAsBytes();
            ScanSessionCache.instance.lastImageBytes = fileBytes;
            ScanSessionCache.instance.lastBarcode = null;
            
            await _processIdentification(barcode: '');
          }
        } else {
          setState(() => _mode = mode);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRow(String barcode) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () {
        if (_state == ScannerState.scanning || _state == ScannerState.resultReady) {
          _processIdentification(barcode: barcode);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.elevatedCard,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(barcode, style: AppTextStyles.bodyMd.copyWith(color: colors.textPrimary)),
      ),
    );
  }

  Widget _buildResultCard() {
    final colors = context.colors;
    final res = _result!;

    if (res.isLocal) {
      final product = res.localProduct!;
      return _buildLocalProduct(colors, product);
    }

    final conf = res.overallConfidence;
    Color confColor = colors.success;
    String confText = 'High Confidence';
    IconData confIcon = Icons.check_circle;

    if (conf < 0.5) {
      confColor = colors.danger;
      confText = 'Low Confidence';
      confIcon = Icons.error;
    } else if (conf < 0.8) {
      confColor = colors.warning;
      confText = 'Medium Confidence';
      confIcon = Icons.warning;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: confColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(confIcon, color: confColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$confText (${(conf * 100).toInt()}%)',
                    style: AppTextStyles.labelMd.copyWith(color: confColor),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _resumeScanning,
                child: Icon(Icons.close, color: colors.textSecondary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (res.prefillData['wordConfidences'] != null)
            _buildRichName(colors, res.prefillData['name']?.toString() ?? '', res.prefillData['wordConfidences'] as List<dynamic>)
          else
            Text(
              res.prefillData['name']?.toString() ?? 'Unknown Product',
              style: AppTextStyles.productLg.copyWith(color: colors.textPrimary),
            ),
            
          if (res.prefillData['brand'] != null && res.prefillData['brand'].toString().isNotEmpty)
            Text(
              res.prefillData['brand'].toString(),
              style: AppTextStyles.bodyMd.copyWith(color: colors.textSecondary),
            ),
            
          if (res.prefillData['originalOcrName'] != null &&
              res.prefillData['originalOcrName'].toString().toLowerCase() != res.prefillData['name']?.toString().toLowerCase()) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.warning.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detected: ${res.prefillData['originalOcrName']}', style: AppTextStyles.labelSm.copyWith(color: colors.warning)),
                  const SizedBox(height: 4),
                  Text('Suggested: ${res.prefillData['name']}', style: AppTextStyles.bodyMd.copyWith(color: colors.textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              res.prefillData['name'] = res.prefillData['originalOcrName'];
                              res.prefillData['originalOcrName'] = res.prefillData['name']; // swap back
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.textSecondary,
                            side: BorderSide(color: colors.border),
                          ),
                          child: const Text('Keep Original'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
            
          const SizedBox(height: 20),
          


          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Use This',
                  variant: AppButtonVariant.primary,
                  onPressed: () {
                    ScanSessionCache.instance.originalPrefill = res.prefillData;
                    _openProductForm(res.prefillData);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: 'Edit Name',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    ScanSessionCache.instance.originalPrefill = res.prefillData;
                    _openProductForm(res.prefillData);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRichName(AppCustomColors colors, String name, List<dynamic> confidences) {
    List<TextSpan> spans = [];
    final words = name.split(' ');
    
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      double conf = 1.0;
      
      // Try to find matching confidence for this word
      try {
        final match = confidences.firstWhere(
          (c) => c['corrected'].toString().toLowerCase() == word.toLowerCase(),
          orElse: () => null,
        );
        if (match != null) conf = match['confidence'] as double;
      } catch (_) {}
      
      spans.add(TextSpan(
        text: '$word ',
        style: TextStyle(
          color: colors.textPrimary,
          decoration: conf < 0.8 ? TextDecoration.underline : TextDecoration.none,
          decorationColor: colors.warning,
          decorationStyle: TextDecorationStyle.wavy,
        ),
      ));
    }
    
    return RichText(
      text: TextSpan(
        style: AppTextStyles.productLg,
        children: spans,
      ),
    );
  }

  Widget _buildLocalProduct(AppCustomColors colors, ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Row(
             children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Found in Inventory', style: AppTextStyles.labelSm.copyWith(color: colors.primary)),
                      const SizedBox(height: 4),
                      Text(product.name, style: AppTextStyles.productLg.copyWith(color: colors.textPrimary)),
                      Text('${product.quantity} in stock • ₹${product.sellingPrice}', style: AppTextStyles.bodyMd.copyWith(color: colors.textSecondary)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _resumeScanning,
                  child: Icon(Icons.close, color: colors.textSecondary, size: 20),
                ),
             ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: AppButton(text: 'Sell', onPressed: () {
                ref.read(cartProvider.notifier).addProduct(product);
                if (widget.returnToPos) {
                  context.pop();
                } else {
                  context.push('/pos');
                }
              }, variant: AppButtonVariant.primary)),
              const SizedBox(width: 12),
              Expanded(child: AppButton(text: 'Edit', onPressed: () {
                context.push('/products/edit', extra: product);
              }, variant: AppButtonVariant.secondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends CustomPainter {
  final Color accentColor;
  _ScanOverlay({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawPath(Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
