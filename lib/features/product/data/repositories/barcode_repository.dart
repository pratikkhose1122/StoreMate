import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/product/data/datasources/product_remote_datasource.dart';
import 'package:storemate/features/product/data/models/identification_result.dart';
import 'package:storemate/features/product/data/models/product_model.dart';
import 'package:storemate/features/product/data/services/product_identification_service.dart';

final barcodeRepositoryProvider = Provider<BarcodeRepository>((ref) {
  return BarcodeRepository(
    ref.read(productRemoteDataSourceProvider),
    ref.read(productIdentificationServiceProvider),
  );
});

/// Handles Stage 1 (Local Lookup) and delegates online lookup to the 
/// orchestrator.
class BarcodeRepository {
  final ProductRemoteDataSource _localDataSource;
  final ProductIdentificationService _identificationService;

  BarcodeRepository(this._localDataSource, this._identificationService);

  /// Performs a Stage 1 local database lookup for a barcode.
  /// 
  /// Returns an [IdentificationResult] if found locally, otherwise null.
  Future<IdentificationResult?> lookupLocal(
    String barcode, {
    void Function(String status)? onStatusChange,
  }) async {
    debugPrint('[Identify] Starting identification for: $barcode');
    
    // 1. Check local StoreMate database first
    onStatusChange?.call('Searching StoreMate...');
    final localStopwatch = Stopwatch()..start();
    
    try {
      final localData = await _localDataSource.lookupBarcode(barcode);
      localStopwatch.stop();
      
      if (localData['found'] == true) {
        debugPrint('[Identify] Stage 1 Local: HIT (${localStopwatch.elapsedMilliseconds}ms)');
        return IdentificationResult(
          stage: IdentificationStage.local,
          fieldIdentifications: {},
          localProduct: ProductModel.fromJson(localData['product']),
        );
      }
      
      debugPrint('[Identify] Stage 1 Local: MISS (${localStopwatch.elapsedMilliseconds}ms)');
    } catch (e) {
      localStopwatch.stop();
      debugPrint('[Identify] Stage 1 Local: Error (${localStopwatch.elapsedMilliseconds}ms) - $e');
    }

    return null;
  }
}
