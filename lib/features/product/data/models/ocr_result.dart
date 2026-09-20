/// Result of ML Kit OCR text extraction from a product image.
///
/// Contains extracted fields and a confidence score (0.0–1.0).
/// Used by [ProductIdentificationService] as a fallback
/// when barcode lookup fails.
class OcrResult {
  final String? productName;
  final String? brand;
  final String? mrp;
  final String? netQuantity;
  final String? modelNumber;
  final String? sku;
  final String? barcodeText;
  final String? rawOcrName;
  final String? cleanedName;
  final String? correctedName;
  final double confidence;
  final List<dynamic> wordConfidences; // Will be typed as CorrectedWord later
  final List<String> allExtractedLines;

  const OcrResult({
    this.productName,
    this.brand,
    this.mrp,
    this.netQuantity,
    this.modelNumber,
    this.sku,
    this.barcodeText,
    this.rawOcrName,
    this.cleanedName,
    this.correctedName,
    this.confidence = 0.0,
    this.wordConfidences = const [],
    this.allExtractedLines = const [],
  });

  /// Convert to the prefill data format expected by [ProductFormScreen].
  Map<String, dynamic> toMap() {
    return {
      'name': correctedName ?? productName ?? '',
      'originalOcrName': rawOcrName,
      'brand': brand ?? '',
      'packageSize': netQuantity ?? '',
      'barcode': barcodeText ?? '',
      'description': '',
      'imageUrl': '',
      'categories': '',
      'source': 'ocr',
      'wordConfidences': wordConfidences,
    };
  }

  int get fieldsExtracted {
    int count = 0;
    if (productName != null && productName!.isNotEmpty) count++;
    if (brand != null && brand!.isNotEmpty) count++;
    if (mrp != null && mrp!.isNotEmpty) count++;
    if (netQuantity != null && netQuantity!.isNotEmpty) count++;
    if (modelNumber != null && modelNumber!.isNotEmpty) count++;
    if (sku != null && sku!.isNotEmpty) count++;
    if (barcodeText != null && barcodeText!.isNotEmpty) count++;
    return count;
  }

  @override
  String toString() =>
      'OcrResult(name=$productName, brand=$brand, mrp=$mrp, '
      'qty=$netQuantity, model=$modelNumber, confidence=$confidence, '
      'fields=$fieldsExtracted)';
}
