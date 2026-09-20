import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/product/data/models/online_product_lookup_result.dart';
import 'package:storemate/features/product/data/providers/barcode_provider.dart';

final openFoodFactsDataSourceProvider = Provider<OpenFoodFactsDataSource>((ref) {
  return OpenFoodFactsDataSource();
});

/// Fetches food product data from the Open Food Facts v2 API.
///
/// Base URL: `https://world.openfoodfacts.org/api/v2/product/`
/// The v2 API returns `{ "product": {...} }` on success (no `status` field)
/// and `{ "status": 0 }` on miss.
///
/// Caching is NOT handled here — it lives in [OnlineBarcodeLookupService].
class OpenFoodFactsDataSource implements BarcodeProvider {
  late final Dio _dio;

  @override
  String get providerName => 'OpenFoodFacts';

  OpenFoodFactsDataSource() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://world.openfoodfacts.org/api/v2/product/',
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'User-Agent': 'StoreMate/1.0 (pratikkhose1122@gmail.com)',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Look up a barcode in Open Food Facts.
  ///
  /// Returns an [OnlineProductLookupResult] on hit, or `null` on miss/error.
  /// API parsing stays entirely within this datasource — callers never see
  /// the raw v2 response format.
  @override
  Future<OnlineProductLookupResult?> lookup(String barcode) async {
    if (!_isValidBarcode(barcode)) {
      debugPrint('[Barcode] OFF: Invalid barcode format');
      return null;
    }

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.get(
        '$barcode?fields=product_name,generic_name,brands,image_url,image_front_url,quantity,categories,packaging',
      );

      if (response.statusCode == 200 && response.data != null) {
        // API v2: found products have a "product" key with no "status" field;
        // not-found products have "status": 0.
        final status = response.data['status'];
        if (status == 0) {
          stopwatch.stop();
          debugPrint(
              '[Barcode] OFF: Not found (${stopwatch.elapsedMilliseconds}ms)');
          return null;
        }

        final productData =
            response.data['product'] as Map<String, dynamic>?;
        if (productData != null) {
          final result = _mapProduct(productData, barcode);

          // Validate: treat empty/useless product names as not found
          if (result == null) {
            stopwatch.stop();
            debugPrint(
                '[Barcode] OFF: Empty product name, treating as not found (${stopwatch.elapsedMilliseconds}ms)');
            return null;
          }

          stopwatch.stop();
          debugPrint(
              '[Barcode] OFF: HIT (${stopwatch.elapsedMilliseconds}ms)');
          return result;
        }
      }
    } on DioException catch (e) {
      stopwatch.stop();
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        debugPrint(
            '[Barcode] OFF: Timeout (${stopwatch.elapsedMilliseconds}ms)');
      } else {
        debugPrint(
            '[Barcode] OFF: Error (${stopwatch.elapsedMilliseconds}ms) - $e');
      }
      return null;
    } catch (e) {
      stopwatch.stop();
      debugPrint(
          '[Barcode] OFF: Error (${stopwatch.elapsedMilliseconds}ms) - $e');
      return null;
    }

    stopwatch.stop();
    debugPrint(
        '[Barcode] OFF: No data (${stopwatch.elapsedMilliseconds}ms)');
    return null;
  }

  bool _isValidBarcode(String barcode) {
    final RegExp numericRegex = RegExp(r'^\d+$');
    if (!numericRegex.hasMatch(barcode)) return false;
    return barcode.length == 8 ||
        barcode.length == 12 ||
        barcode.length == 13 ||
        barcode.length == 14;
  }

  /// Maps raw OFF product JSON → typed [OnlineProductLookupResult].
  /// Returns `null` if the product name is empty or useless.
  OnlineProductLookupResult? _mapProduct(
    Map<String, dynamic> raw,
    String barcode,
  ) {
    String name = raw['product_name']?.toString().trim() ?? '';
    final genericName = raw['generic_name']?.toString().trim() ?? '';
    final brands = raw['brands']?.toString().trim() ?? '';

    if (name.isEmpty) {
      name = genericName;
    }
    if (name.isEmpty) {
      name = brands;
    }
    if (name.isEmpty || name.toLowerCase() == 'unknown product') {
      return null;
    }

    final imageUrl = raw['image_front_url']?.toString().isNotEmpty == true
        ? raw['image_front_url'] as String
        : raw['image_url']?.toString().isNotEmpty == true
            ? raw['image_url'] as String
            : null;

    return OnlineProductLookupResult(
      name: name,
      barcode: barcode,
      source: LookupSource.openFoodFacts,
      brand: brands.isNotEmpty ? brands : null,
      imageUrl: imageUrl,
      quantity: raw['quantity']?.toString().isNotEmpty == true
          ? raw['quantity'] as String
          : null,
      categories: raw['categories']?.toString().isNotEmpty == true
          ? raw['categories'] as String
          : null,
      packaging: raw['packaging']?.toString().isNotEmpty == true
          ? raw['packaging'] as String
          : null,
      description: genericName.isNotEmpty && genericName != name ? genericName : null,
    );
  }
}
