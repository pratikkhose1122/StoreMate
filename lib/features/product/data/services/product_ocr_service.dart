import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:storemate/features/product/data/models/ocr_result.dart';
import 'package:storemate/features/product/data/utils/product_name_cleaner.dart';
import 'package:storemate/features/product/data/services/spell_correction_service.dart';

final productOcrServiceProvider = Provider<ProductOcrService>((ref) {
  return ProductOcrService();
});

/// On-device text recognition service using Google ML Kit.
///
/// Extracts product information (name, brand, MRP, weight, model number)
/// from packaging images using heuristic analysis of OCR text blocks.
/// Returns an [OcrResult] with a confidence score.
class ProductOcrService {
  /// Maximum number of fields we try to extract (for confidence calculation).
  static const int _maxFields = 7;

  /// Extract product information from an image file.
  Future<OcrResult> extractFromImagePath(String imagePath) async {
    final stopwatch = Stopwatch()..start();
    final textRecognizer = TextRecognizer();

    try {
      // 1. Image Preprocessing (Cropping & Resizing)
      final bytes = await File(imagePath).readAsBytes();
      img.Image? decoded = img.decodeImage(bytes);
      if (decoded != null) {
        decoded = img.bakeOrientation(decoded);
        
        if (decoded.width > 1800 || decoded.height > 1800) {
          if (decoded.width > decoded.height) {
            decoded = img.copyResize(decoded, width: 1800);
          } else {
            decoded = img.copyResize(decoded, height: 1800);
          }
        }
        
        int cropW = (decoded.width * 0.75).toInt();
        int cropH = (decoded.height * 0.75).toInt();
        int x = (decoded.width - cropW) ~/ 2;
        int y = (decoded.height - cropH) ~/ 2;
        decoded = img.copyCrop(decoded, x: x, y: y, width: cropW, height: cropH);
        
        await File(imagePath).writeAsBytes(img.encodeJpg(decoded));
      }

      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);
      stopwatch.stop();

      debugPrint('[OCR] Text recognition completed (${stopwatch.elapsedMilliseconds}ms)');
      debugPrint('[OCR] Blocks: ${recognizedText.blocks.length}, '
          'Lines: ${recognizedText.blocks.fold<int>(0, (sum, b) => sum + b.lines.length)}');

      return _analyzeText(recognizedText);
    } catch (e) {
      stopwatch.stop();
      debugPrint('[OCR] Error (${stopwatch.elapsedMilliseconds}ms): $e');
      return const OcrResult(confidence: 0.0);
    } finally {
      textRecognizer.close();
    }
  }

  OcrResult _analyzeText(RecognizedText recognizedText) {
    final allLines = <String>[];
    final allBlocks = <TextBlock>[];
    double maxBottom = 0;

    for (final block in recognizedText.blocks) {
      allBlocks.add(block);
      final bottom = block.boundingBox.bottom;
      if (bottom > maxBottom) maxBottom = bottom;
      for (final line in block.lines) {
        final text = line.text.trim();
        if (text.isNotEmpty) {
          allLines.add(text);
        }
      }
    }

    if (allLines.isEmpty) {
      return const OcrResult(confidence: 0.0);
    }

    // 6a. Vertical Line Merging
    final mergedBlocks = _mergeVerticalBlocks(allBlocks, maxBottom);
    final mergedLines = mergedBlocks.map((b) => b.text).toList();

    final rawText = allLines.join('\n');

    // Extract basic fields
    final mrp = _extractMrp(allLines);
    final netQuantity = _extractNetQuantity(allLines);
    final modelNumber = _extractModelNumber(allLines);
    final sku = _extractSku(allLines);
    final barcodeText = _extractBarcodeText(allLines);
    final brand = _extractBrand(allLines, allBlocks);

    // Extract product name with weighted scoring
    String? rawOcrName = _extractProductName(mergedBlocks, allLines, brand, maxBottom);

    // Fallback generator
    if (rawOcrName == null) {
      if (brand != null || modelNumber != null) {
        rawOcrName = '${brand ?? ''} ${modelNumber ?? ''}'.trim();
        if (rawOcrName.isEmpty) rawOcrName = null;
      }
    }

    String? cleanedName;
    String? correctedName;
    List<dynamic> wordConfidences = [];

    if (rawOcrName != null) {
      // 6d. Post-processing
      final correctedWordsList = SpellCorrectionService.correctWords(rawOcrName);
      wordConfidences = correctedWordsList.map((w) => w.toMap()).toList();
      
      final correctedRaw = correctedWordsList.map((w) => w.corrected).join(' ');
      cleanedName = ProductNameCleaner.clean(rawOcrName, brand: brand);
      correctedName = ProductNameCleaner.clean(correctedRaw, brand: brand);
    }

    // Calculate confidence
    int fieldsFound = 0;
    if (correctedName != null && correctedName.isNotEmpty) fieldsFound++;
    if (brand != null && brand.isNotEmpty) fieldsFound++;
    if (mrp != null && mrp.isNotEmpty) fieldsFound++;
    if (netQuantity != null && netQuantity.isNotEmpty) fieldsFound++;
    if (modelNumber != null && modelNumber.isNotEmpty) fieldsFound++;
    if (sku != null && sku.isNotEmpty) fieldsFound++;
    if (barcodeText != null && barcodeText.isNotEmpty) fieldsFound++;

    final confidence = fieldsFound == 0
        ? 0.1
        : (fieldsFound / _maxFields).clamp(0.0, 1.0);

    final result = OcrResult(
      productName: null,
      brand: brand,
      mrp: mrp,
      netQuantity: netQuantity,
      modelNumber: modelNumber,
      sku: sku,
      barcodeText: barcodeText,
      rawOcrName: rawOcrName,
      cleanedName: cleanedName,
      correctedName: correctedName,
      confidence: confidence,
      wordConfidences: wordConfidences,
      allExtractedLines: mergedLines,
    );

    debugPrint('[OCR] $result');
    return result;
  }

  /// Merges OCR blocks that are vertically adjacent and horizontally overlapping
  List<_MergedBlock> _mergeVerticalBlocks(List<TextBlock> blocks, double imageHeight) {
    if (blocks.isEmpty) return [];

    final result = <_MergedBlock>[];
    
    // Sort blocks top to bottom
    final sorted = List<TextBlock>.from(blocks)
      ..sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    for (final block in sorted) {
      bool merged = false;
      final blockRect = block.boundingBox;
      
      for (var existing in result) {
        // Vertical gap
        final verticalGap = blockRect.top - existing.bottom;
        // Horizontal overlap
        final leftMax = [blockRect.left, existing.left].reduce(max);
        final rightMin = [blockRect.right, existing.right].reduce(min);
        final overlapWidth = rightMin - leftMax;
        
        final isHorizontallyOverlapping = overlapWidth > 0 && 
            (overlapWidth / (blockRect.right - blockRect.left) > 0.5 || 
             overlapWidth / (existing.right - existing.left) > 0.5);

        // If gap is small (e.g. less than 1.5x average block height) and overlaps
        if (verticalGap > 0 && verticalGap < 50 && isHorizontallyOverlapping) {
          existing.text += ' ${block.text.replaceAll('\n', ' ').trim()}';
          existing.bottom = blockRect.bottom;
          existing.left = min(existing.left, blockRect.left);
          existing.right = max(existing.right, blockRect.right);
          merged = true;
          break;
        }
      }
      if (!merged) {
        result.add(_MergedBlock(
          text: block.text.replaceAll('\n', ' ').trim(),
          top: blockRect.top,
          bottom: blockRect.bottom,
          left: blockRect.left,
          right: blockRect.right,
          height: blockRect.height,
        ));
      }
    }
    return result;
  }

  /// Extract MRP from patterns like "MRP ₹120", "M.R.P. Rs.120.00", "MRP:120"
  String? _extractMrp(List<String> lines) {
    final mrpPatterns = [
      RegExp(r'M\.?R\.?P\.?\s*[:\s]?\s*[₹Rs.]*\s*(\d+[\.,]?\d*)', caseSensitive: false),
      RegExp(r'[₹]\s*(\d+[\.,]?\d*)', caseSensitive: false),
      RegExp(r'Rs\.?\s*(\d+[\.,]?\d*)', caseSensitive: false),
      RegExp(r'Price\s*[:\s]?\s*[₹Rs.]*\s*(\d+[\.,]?\d*)', caseSensitive: false),
    ];

    for (final line in lines) {
      for (final pattern in mrpPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          return match.group(1)?.replaceAll(',', '');
        }
      }
    }
    return null;
  }

  /// Extract net quantity from patterns like "500 ml", "1.5 L", "250 g", "2 pcs"
  String? _extractNetQuantity(List<String> lines) {
    final qtyPatterns = [
      RegExp(r'Net\s*(?:Wt|Weight|Qty|Quantity|Content)[:\s.]*\s*(\d+[\.,]?\d*\s*(?:ml|l|g|kg|pcs?|piece|pack|oz|lb)s?)', caseSensitive: false),
      RegExp(r'(\d+[\.,]?\d*\s*(?:ml|l|g|kg|pcs?|piece|pack|oz|lb)s?)\b', caseSensitive: false),
    ];

    for (final line in lines) {
      for (final pattern in qtyPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          return match.group(1)?.trim();
        }
      }
    }
    return null;
  }

  /// Extract model number from patterns like "Model: ABC123", "Mod. No. XYZ"
  String? _extractModelNumber(List<String> lines) {
    final patterns = [
      RegExp(r'Model\s*(?:No\.?|Number|#)?\s*[:\s]\s*([A-Za-z0-9\-\/]+)', caseSensitive: false),
      RegExp(r'Part\s*(?:No\.?|Number|#)\s*[:\s]\s*([A-Za-z0-9\-\/]+)', caseSensitive: false),
      RegExp(r'Item\s*(?:No\.?|Number|#)\s*[:\s]\s*([A-Za-z0-9\-\/]+)', caseSensitive: false),
    ];

    for (final line in lines) {
      for (final pattern in patterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          return match.group(1)?.trim();
        }
      }
    }
    return null;
  }

  /// Extract SKU from patterns like "SKU: ABC123"
  String? _extractSku(List<String> lines) {
    final pattern = RegExp(r'SKU\s*[:\s#]\s*([A-Za-z0-9\-]+)', caseSensitive: false);
    for (final line in lines) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    return null;
  }

  /// Extract barcode text — any 8-14 digit numeric string
  String? _extractBarcodeText(List<String> lines) {
    final pattern = RegExp(r'\b(\d{8,14})\b');
    for (final line in lines) {
      final match = pattern.firstMatch(line.replaceAll(' ', ''));
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  /// Extract brand — typically the most prominent uppercase text block, or
  /// text following "Brand:", "By:", "From:"
  String? _extractBrand(List<String> lines, List<TextBlock> blocks) {
    // First check for explicit brand labels
    final brandPattern = RegExp(r'(?:Brand|By|From|Mfg\.?\s*by|Manufactured\s*by)\s*[:\s]\s*(.+)', caseSensitive: false);
    for (final line in lines) {
      final match = brandPattern.firstMatch(line);
      if (match != null) {
        final brand = match.group(1)?.trim();
        if (brand != null && brand.isNotEmpty && brand.length <= 40) {
          return brand;
        }
      }
    }

    // Fallback: find the largest block that looks like a brand (all uppercase,
    // short, near the top of the image)
    if (blocks.isNotEmpty) {
      final sortedBlocks = List<TextBlock>.from(blocks)
        ..sort((a, b) {
          // Prefer blocks near top with larger bounding boxes
          final aScore = (a.boundingBox.height ?? 0) * 2 - (a.boundingBox.top ?? 0);
          final bScore = (b.boundingBox.height ?? 0) * 2 - (b.boundingBox.top ?? 0);
          return bScore.compareTo(aScore);
        });

      for (final block in sortedBlocks.take(3)) {
        final text = block.text.trim();
        if (text.length >= 2 &&
            text.length <= 30 &&
            text == text.toUpperCase() &&
            !RegExp(r'^\d+').hasMatch(text) &&
            !RegExp(r'MRP|NET|WEIGHT|QTY|PRICE|BEST|BEFORE|INGREDIENTS|USE', caseSensitive: false).hasMatch(text)) {
          return text;
        }
      }
    }

    return null;
  }

  /// Extract product name — scores candidates based on heuristic rules
  /// and merges the top candidates if they belong together.
  String? _extractProductName(
    List<_MergedBlock> blocks,
    List<String> allLines,
    String? detectedBrand,
    double imageHeight,
  ) {
    if (blocks.isEmpty) return null;

    final negativePatterns = RegExp(
      r'www\.|http|\.com|Google\s*Play|App\s*Store|Download|Install|Magnifie|'
      r'Manufactured|Imported|Packed\s*On|Mfg|FSSAI|Customer\s*Care|Toll\s*Free|'
      r'MRP|M\.R\.P|₹|Rs\.|Price|Net\s*W|Ingredients|Best\s*Before|'
      r'Batch|Lot|Exp|Barcode|SKU|Model|Part\s*No|'
      r'GST|CE|Warning|Caution|Expiry|Directions|Storage|'
      r'Made\s*In|Country\s*Of\s*Origin|Marketed\s*By|Distributed\s*By|'
      r'Nutrition|Serving|Calories|Protein|Fat|Carbohydrate|'
      r'Weight|Height|Length|Width|Dimensions|'
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}|'
      r'\b\d{10,14}\b', // phone numbers, barcodes
      caseSensitive: false,
    );

    final brands = RegExp(r'\b(Samsung|Apple|Redmi|Xiaomi|OnePlus|Realme|Vivo|OPPO|Nokia|boAt|JBL|Sony|Philips|HP|Dell|Lenovo|Logitech|Portronics|Zebronics|Ambrane|Syska|Ubon|Oraimo|Mi|Nothing|Anker)\b', caseSensitive: false);
    final keywords = RegExp(r'\b(Charger|Adapter|Cable|Earbuds|Power Bank|Neckband|Speaker|Mouse|Keyboard|Stand|Glass|Cover|Bulb|Torch|Battery|Watch)\b', caseSensitive: false);

    // Calculate percentiles
    final heights = blocks.map((b) => b.height).toList()..sort();
    final p75Height = heights.isEmpty ? 0 : heights[(heights.length * 0.75).floor()];
    final p90Height = heights.isEmpty ? 0 : heights[(heights.length * 0.90).floor()];
    
    // For horizontal centering, we need image width. Since we cropped to 75%, 
    // we can approximate it or just check if left and right margins are somewhat equal.
    // We'll estimate center based on bounding box.

    final scoredBlocks = <Map<String, dynamic>>[];

    for (final block in blocks) {
      final text = block.text;
      if (text.length < 3) continue;
      if (detectedBrand != null && text.toLowerCase() == detectedBrand.toLowerCase()) continue;
      
      int score = 0;
      bool rejected = false;

      // Negative Signals
      if (negativePatterns.hasMatch(text)) score -= 15;
      if (RegExp(r'^\d+$').hasMatch(text)) score -= 10;
      if (block.height < p75Height * 0.5) score -= 8;

      // Positive Signals
      if (brands.hasMatch(text)) score += 5;
      if (keywords.hasMatch(text)) score += 4;
      if (block.height >= p90Height) {
        score += 5;
      } else if (block.height >= p75Height) score += 3;
      
      if (imageHeight > 0 && block.top < imageHeight * 0.4) score += 4;
      if (imageHeight > 0 && block.top > imageHeight * 0.3 && block.bottom < imageHeight * 0.7) score += 5; // Near center vertically

      if (text == text.toUpperCase() || text == _toTitleCase(text)) score += 2;
      
      // Mixed letters and numbers
      if (RegExp(r'[A-Za-z]').hasMatch(text) && RegExp(r'\d').hasMatch(text)) score += 3;
      
      if (text.split(' ').length > 1) score += 2;
      
      int occurences = allLines.where((l) => l.toLowerCase().contains(text.toLowerCase())).length;
      if (occurences > 1) score += 2;

      scoredBlocks.add({
        'block': block,
        'score': score,
      });
    }

    scoredBlocks.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    // Keep top 3 candidates that have a positive score
    final topCandidates = scoredBlocks.where((s) => (s['score'] as int) > 0).take(3).toList();
    if (topCandidates.isEmpty) return null;

    // Sort the top 3 by vertical position to merge them in correct reading order
    topCandidates.sort((a, b) => (a['block'] as _MergedBlock).top.compareTo((b['block'] as _MergedBlock).top));

    return topCandidates.map((c) => (c['block'] as _MergedBlock).text).join(' ').trim();
  }
  
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }
}

class _MergedBlock {
  String text;
  double top;
  double bottom;
  double left;
  double right;
  double height;

  _MergedBlock({
    required this.text,
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
    required this.height,
  });
}
