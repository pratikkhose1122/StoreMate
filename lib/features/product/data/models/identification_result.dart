import 'package:storemate/features/product/data/models/product_model.dart';

/// Represents the source of a specific field's value.
enum DataSource {
  user,           // Highest priority
  localStore,     // Shop's local DB
  globalCatalog,  // Global shared DB
  barcodeApi,     // Online barcode databases
  objectDetection,// Local ML Kit object detection
  ocr,            // Local ML Kit OCR
}

/// The stage of the identification pipeline that produced a result.
enum IdentificationStage {
  local,
  cache,
  globalCatalog,
  onlineProvider,
  ocr,
  manual,
}

/// A single field's identified value along with its source and confidence.
class FieldIdentification<T> {
  final T value;
  final DataSource source;
  final double confidence;

  const FieldIdentification({
    required this.value,
    required this.source,
    required this.confidence,
  });

  /// Compares this field with another. Returns the one with higher priority/confidence.
  /// Priority: user > localStore > globalCatalog > barcodeApi > objectDetection > ocr.
  /// If sources are equal, highest confidence wins.
  FieldIdentification<T> merge(FieldIdentification<T> other) {
    if (source.index < other.source.index) return this;
    if (other.source.index < source.index) return other;
    return confidence >= other.confidence ? this : other;
  }
}

/// Unified result returned by the product identification pipeline.
class IdentificationResult {
  final IdentificationStage stage;
  final String? providerName;
  
  /// Holds FieldIdentification objects for each prefill field (e.g., 'name', 'brand', 'mrp').
  final Map<String, FieldIdentification> fieldIdentifications;

  final ProductModel? localProduct;
  
  /// Computed overall confidence based on the fields present.
  final double overallConfidence;

  const IdentificationResult({
    required this.stage,
    this.providerName,
    required this.fieldIdentifications,
    this.overallConfidence = 1.0,
    this.localProduct,
  });

  /// Extracts just the raw values for the UI form.
  Map<String, dynamic> get prefillData {
    return fieldIdentifications.map((key, field) => MapEntry(key, field.value));
  }

  /// Helper to merge two IdentificationResults
  IdentificationResult merge(IdentificationResult other) {
    final Map<String, FieldIdentification> mergedFields = Map.from(fieldIdentifications);
    
    for (final entry in other.fieldIdentifications.entries) {
      if (mergedFields.containsKey(entry.key)) {
        mergedFields[entry.key] = mergedFields[entry.key]!.merge(entry.value);
      } else {
        mergedFields[entry.key] = entry.value;
      }
    }

    // Rough calculation of overall confidence
    double totalConf = 0;
    for (var f in mergedFields.values) {
      totalConf += f.confidence;
    }
    double newOverall = mergedFields.isEmpty ? 0 : totalConf / mergedFields.length;

    // Pick the stage from the higher confidence or priority source
    // In reality, the orchestrator handles the stage label, so we keep the current one unless it's manual.
    IdentificationStage newStage = stage == IdentificationStage.manual ? other.stage : stage;

    return IdentificationResult(
      stage: newStage,
      providerName: providerName ?? other.providerName,
      fieldIdentifications: mergedFields,
      overallConfidence: newOverall,
      localProduct: localProduct ?? other.localProduct,
    );
  }

  bool get isLocal => stage == IdentificationStage.local;
  bool get isManual => stage == IdentificationStage.manual;

  String get stageLabel {
    switch (stage) {
      case IdentificationStage.local: return 'Local Database';
      case IdentificationStage.cache: return 'Cached Result';
      case IdentificationStage.globalCatalog: return 'Global Knowledge Base';
      case IdentificationStage.onlineProvider: return providerName ?? 'Online Database';
      case IdentificationStage.ocr: return 'Package Text (OCR)';
      case IdentificationStage.manual: return 'Manual Entry';
    }
  }

  String get stageEmoji {
    switch (stage) {
      case IdentificationStage.local: return '🏪';
      case IdentificationStage.cache: return '💾';
      case IdentificationStage.globalCatalog: return '🌐';
      case IdentificationStage.onlineProvider: return '🌍';
      case IdentificationStage.ocr: return '📝';
      case IdentificationStage.manual: return '✍️';
    }
  }
}
