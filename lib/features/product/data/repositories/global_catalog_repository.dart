import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:storemate/features/product/data/models/identification_result.dart';
import 'package:flutter/foundation.dart';

final globalCatalogRepositoryProvider = Provider((ref) {
  return GlobalCatalogRepository(Supabase.instance.client);
});

class GlobalCatalogRepository {
  final SupabaseClient _supabase;

  GlobalCatalogRepository(this._supabase);

  /// Look up a product in the global catalog by barcode or image hash (phash/sha256).
  Future<IdentificationResult?> lookup({String? barcode, String? imageHash, String? pHash}) async {
    try {
      if (barcode == null && imageHash == null && pHash == null) return null;

      var query = _supabase.from('identified_products').select('*');
      
      // We will do a simple match. Supabase allows 'or' conditions.
      List<String> conditions = [];
      if (barcode != null && barcode.isNotEmpty) conditions.add('barcode.eq.$barcode');
      if (imageHash != null && imageHash.isNotEmpty) conditions.add('image_hash.eq.$imageHash');
      if (pHash != null && pHash.isNotEmpty) conditions.add('phash.eq.$pHash');
      
      if (conditions.isEmpty) return null;
      
      query = query.or(conditions.join(','));

      final response = await query.order('verified_by_human', ascending: false).order('confidence', ascending: false).limit(1);

      if (response.isNotEmpty) {
        final data = response.first;
        final metadata = data['metadata'] as Map<String, dynamic>? ?? {};
        
        final confidence = (data['confidence'] as num?)?.toDouble() ?? 1.0;
        final isVerified = data['verified_by_human'] == true;
        
        final source = isVerified ? DataSource.globalCatalog : DataSource.ocr; // Treat unverified as slightly lower priority than verified global catalog. Actually let's keep it globalCatalog, but adjust confidence.

        // Reconstruct field identifications
        final Map<String, FieldIdentification> fields = {};
        
        void addField(String key, dynamic value) {
          if (value != null && value.toString().isNotEmpty) {
            fields[key] = FieldIdentification(
              value: value,
              source: DataSource.globalCatalog,
              confidence: confidence,
            );
          }
        }

        addField('name', data['product_name']);
        addField('brand', data['brand']);
        addField('category', data['category']);
        addField('mrp', data['mrp']);
        addField('weight', data['weight']);
        
        metadata.forEach((k, v) => addField(k, v));

        return IdentificationResult(
          stage: IdentificationStage.globalCatalog,
          fieldIdentifications: fields,
          overallConfidence: confidence,
        );
      }
    } catch (e) {
      debugPrint('[GlobalCatalog] Lookup Error: $e');
    }
    return null;
  }

  /// Queues an upload to the global catalog. 
  /// In an offline-first app, this should write to a local sync queue.
  Future<void> queueUpload({
    String? barcode,
    String? imageHash,
    String? pHash,
    required Map<String, dynamic> data,
    required double confidence,
    bool verified = true,
  }) async {
    try {
      // Background Sync Logic
      // For this implementation, we attempt an immediate non-blocking upload.
      // A robust sync queue would persist this to SQLite and retry on network restore.
      
      // Fire and forget
      _uploadNow(barcode, imageHash, pHash, data, confidence, verified).ignore();
      
    } catch (e) {
      debugPrint('[GlobalCatalog] Queue Upload Error: $e');
    }
  }

  Future<void> _uploadNow(String? barcode, String? imageHash, String? pHash, Map<String, dynamic> data, double confidence, bool verified) async {
     try {
       // Only upload if we have identifying keys
       if (barcode == null && imageHash == null) return;
       
       final Map<String, dynamic> row = {
         'barcode': barcode,
         'image_hash': imageHash,
         'phash': pHash,
         'product_name': data['name'],
         'brand': data['brand'],
         'category': data['category'],
         'mrp': data['mrp'],
         'weight': data['weight'],
         'metadata': data,
         'confidence': confidence,
         'verified_by_human': verified,
         'updated_at': DateTime.now().toIso8601String(),
       };
       
       row.removeWhere((k, v) => v == null);

       // Upsert logic: in a real environment, you'd handle conflicts via Supabase RPC or ON CONFLICT DO UPDATE
       // where confidence > existing.confidence.
       await _supabase.from('identified_products').upsert(
         row,
         onConflict: barcode != null ? 'barcode' : 'image_hash',
       );
       
       debugPrint('[GlobalCatalog] Uploaded successfully.');
     } catch (e) {
       debugPrint('[GlobalCatalog] UploadNow Error: $e');
     }
  }
}
