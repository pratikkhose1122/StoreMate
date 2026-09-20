import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// Learns from user edits so the same OCR mistake is never repeated.
/// Uses a Hive box for local offline storage.
class UserCorrectionCache {
  static const String _boxName = 'ocr_corrections';
  static Box<String>? _box;
  static bool _isInitialized = false;

  /// Initialize the Hive box. Called in main.dart during startup.
  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      _box = await Hive.openBox<String>(_boxName);
      _isInitialized = true;
      debugPrint('UserCorrectionCache initialized. Entries: ${_box?.length}');
    } catch (e) {
      debugPrint('Failed to initialize UserCorrectionCache: $e');
    }
  }

  /// Look up a corrected name using barcode or original OCR text.
  /// Priority: barcode match > ocr text match.
  static String? lookup({String? barcode, String? ocrText}) {
    if (!_isInitialized || _box == null) return null;

    // 1. Try barcode
    if (barcode != null && barcode.isNotEmpty) {
      final val = _box!.get('barcode:$barcode');
      if (val != null) return val;
    }

    // 2. Try raw OCR text
    if (ocrText != null && ocrText.isNotEmpty) {
      final key = 'ocr:${ocrText.toLowerCase().trim()}';
      final val = _box!.get(key);
      if (val != null) return val;
    }

    return null;
  }

  /// Save a user's correction to the cache for future scans.
  static Future<void> save({String? barcode, String? ocrText, required String correctedName}) async {
    if (!_isInitialized || _box == null || correctedName.isEmpty) return;

    try {
      if (barcode != null && barcode.isNotEmpty) {
        await _box!.put('barcode:$barcode', correctedName);
      }

      if (ocrText != null && ocrText.isNotEmpty) {
        final key = 'ocr:${ocrText.toLowerCase().trim()}';
        await _box!.put(key, correctedName);
      }
      
      debugPrint('UserCorrectionCache saved correction: "$correctedName"');
    } catch (e) {
      debugPrint('Error saving to UserCorrectionCache: $e');
    }
  }
}
