import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/product/data/models/identification_result.dart';
import 'package:storemate/features/product/data/services/online_barcode_lookup_service.dart';
import 'package:storemate/features/product/data/services/product_ocr_service.dart';
import 'package:storemate/features/product/data/utils/user_correction_cache.dart';
import 'package:storemate/features/product/data/services/telemetry_service.dart';

final productIdentificationServiceProvider = Provider<ProductIdentificationService>((ref) {
  return ProductIdentificationService(
    onlineLookupService: ref.read(onlineBarcodeLookupServiceProvider),
    ocrService: ref.read(productOcrServiceProvider),
    telemetryService: ref.read(telemetryServiceProvider),
  );
});

class ProductIdentificationService {
  final OnlineBarcodeLookupService _onlineLookupService;
  final ProductOcrService _ocrService;
  final TelemetryService _telemetryService;

  ProductIdentificationService({
    required OnlineBarcodeLookupService onlineLookupService,
    required ProductOcrService ocrService,
    required TelemetryService telemetryService,
  })  : _onlineLookupService = onlineLookupService,
        _ocrService = ocrService,
        _telemetryService = telemetryService;

  /// Parallel execution of OCR + Barcode APIs with Object Detection preprocessing.
  Future<IdentificationResult> identifyParallel(
    String barcode, 
    String imagePath, // Use file path for ML Kit to avoid dimensions issues
  ) async {
    final stopwatch = Stopwatch()..start();

    // Run Barcode APIs and OCR in parallel
    final results = await Future.wait([
      _lookupOnline(barcode),
      _runOcr(imagePath, barcode),
    ]);

    IdentificationResult apiResult = results[0];
    IdentificationResult ocrResult = results[1];

    // Merge them: Priority goes to Barcode APIs over OCR
    IdentificationResult merged = apiResult.merge(ocrResult);
    
    stopwatch.stop();

    _telemetryService.logIdentification(
      provider: 'Parallel Pipeline',
      latencyMs: stopwatch.elapsedMilliseconds,
      success: merged.fieldIdentifications.isNotEmpty,
      confidence: merged.overallConfidence,
      isUserCorrected: false,
      isSaved: false,
    );

    if (merged.fieldIdentifications.isEmpty && barcode.isNotEmpty) {
      merged.fieldIdentifications['barcode'] = FieldIdentification(
        value: barcode,
        source: DataSource.ocr,
        confidence: 1.0,
      );
    }

    return merged;
  }

  Future<IdentificationResult> _lookupOnline(String barcode) async {
    final result = await _onlineLookupService.lookupBarcode(barcode);
    
    if (result != null) {
      final fields = <String, FieldIdentification>{};
      final data = result.toMap();
      
      void addField(String key, dynamic val) {
        if (val != null && val.toString().isNotEmpty) {
          fields[key] = FieldIdentification(
            value: val,
            source: DataSource.barcodeApi,
            confidence: 0.95, // High confidence for barcode APIs
          );
        }
      }

      addField('name', data['name']);
      addField('brand', data['brand']);
      addField('mrp', data['mrp']);
      addField('weight', data['weight']);
      addField('imageUrl', data['imageUrl']);
      addField('categories', data['categories']);

      return IdentificationResult(
        stage: IdentificationStage.onlineProvider,
        providerName: result.sourceLabel,
        fieldIdentifications: fields,
      );
    }

    return IdentificationResult(
      stage: IdentificationStage.onlineProvider,
      fieldIdentifications: {},
    );
  }

  Future<IdentificationResult> _runOcr(String imagePath, String barcode) async {
    // In reality, run Object Detection first, then crop image, then OCR.
    // For now, pass directly to OCR.
    final ocrData = await _ocrService.extractFromImagePath(imagePath);
    
    final fields = <String, FieldIdentification>{};
    final data = ocrData.toMap();
    
    // 1. Check UserCorrectionCache
    final cachedName = UserCorrectionCache.lookup(barcode: barcode, ocrText: ocrData.rawOcrName);
    if (cachedName != null && cachedName.isNotEmpty) {
      data['name'] = cachedName;
      ocrData.wordConfidences.clear(); // Clear alternatives since it's user verified
    }
    
    // OCR Confidence mapping
    double baseConf = cachedName != null ? 1.0 : ocrData.confidence;

    void addField(String key, dynamic val, double boost) {
      if (val != null && val.toString().isNotEmpty) {
        fields[key] = FieldIdentification(
          value: val,
          source: DataSource.ocr,
          confidence: (baseConf + boost).clamp(0.0, 1.0),
        );
      }
    }

    addField('name', data['name'], 0.20);
    addField('brand', data['brand'], 0.15);
    addField('mrp', data['mrp'], 0.10);
    addField('weight', data['packageSize'], 0.10);
    addField('barcode', barcode, 0.0);
    
    // Pass word confidences directly in the result
    if (ocrData.wordConfidences.isNotEmpty) {
      fields['wordConfidences'] = FieldIdentification(
        value: ocrData.wordConfidences,
        source: DataSource.ocr,
        confidence: baseConf,
      );
    }
    
    return IdentificationResult(
      stage: IdentificationStage.ocr,
      providerName: 'ML Kit OCR',
      fieldIdentifications: fields,
    );
  }

  /// Empty manual entry result
  IdentificationResult manualEntry(String barcode) {
    final fields = <String, FieldIdentification>{};
    if (barcode.isNotEmpty) {
      fields['barcode'] = FieldIdentification(
        value: barcode,
        source: DataSource.user,
        confidence: 1.0,
      );
    }
    return IdentificationResult(
      stage: IdentificationStage.manual,
      fieldIdentifications: fields,
    );
  }
}
