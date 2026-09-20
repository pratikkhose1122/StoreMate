import 'dart:typed_data';

/// A singleton cache used to hold scan session data,
/// specifically high-resolution captured images, between
/// the scanner screens and the product form.
/// 
/// This prevents passing large byte arrays through router parameters.
class ScanSessionCache {
  ScanSessionCache._privateConstructor();

  static final ScanSessionCache _instance = ScanSessionCache._privateConstructor();

  static ScanSessionCache get instance => _instance;

  Uint8List? lastImageBytes;
  String? lastBarcode;
  Map<String, dynamic>? originalPrefill;

  void clear() {
    lastImageBytes = null;
    lastBarcode = null;
    originalPrefill = null;
  }
}
