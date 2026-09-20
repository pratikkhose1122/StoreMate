import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/product/data/models/online_product_lookup_result.dart';
import 'package:storemate/features/product/data/providers/barcode_provider.dart';

final openProductsFactsDataSourceProvider =
    Provider<OpenProductsFactsDataSource>((ref) {
  return OpenProductsFactsDataSource();
});

/// Fetches non-food product data from the Open Products Facts v0 API.
///
/// Base URL: `https://world.openproductsfacts.org/api/v0/product/`
/// The v0 API returns `{ "status": 1, "product": {...} }` on success
/// and `{ "status": 0 }` on miss.
class OpenProductsFactsDataSource implements BarcodeProvider {
  late final Dio _dio;

  @override
  String get providerName => 'OpenProductsFacts';

  OpenProductsFactsDataSource() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://world.openproductsfacts.org/api/v0/product/',
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'User-Agent': 'StoreMate/1.0 (pratikkhose1122@gmail.com)',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Look up a barcode in Open Products Facts.
  ///
  /// Returns an [OnlineProductLookupResult] on hit, or `null` on miss/error.
  /// API parsing stays entirely within this datasource — callers never see
  /// the raw v0 response format.
  @override
  Future<OnlineProductLookupResult?> lookup(String barcode) async {
    if (!_isValidBarcode(barcode)) {
      debugPrint('[Barcode] OPF: Invalid barcode format');
      return null;
    }

    final stopwatch = Stopwatch()..start();
    try {
      // v0 API requires .json suffix
      final response = await _dio.get('$barcode.json');

      if (response.statusCode == 200 && response.data != null) {
        final status = response.data['status'];
        if (status != 1) {
          stopwatch.stop();
          debugPrint(
              '[Barcode] OPF: Not found (${stopwatch.elapsedMilliseconds}ms)');
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
                '[Barcode] OPF: Empty product name, treating as not found (${stopwatch.elapsedMilliseconds}ms)');
            return null;
          }

          stopwatch.stop();
          debugPrint(
              '[Barcode] OPF: HIT (${stopwatch.elapsedMilliseconds}ms)');
          return result;
        }
      }
    } on DioException catch (e) {
      stopwatch.stop();
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        debugPrint(
            '[Barcode] OPF: Timeout (${stopwatch.elapsedMilliseconds}ms)');
      } else {
        debugPrint(
            '[Barcode] OPF: Error (${stopwatch.elapsedMilliseconds}ms) - $e');
      }
      return null;
    } catch (e) {
      stopwatch.stop();
      debugPrint(
          '[Barcode] OPF: Error (${stopwatch.elapsedMilliseconds}ms) - $e');
      return null;
    }

    stopwatch.stop();
    debugPrint(
        '[Barcode] OPF: No data (${stopwatch.elapsedMilliseconds}ms)');
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

  /// Maps raw OPF product JSON → typed [OnlineProductLookupResult].
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
      source: LookupSource.openProductsFacts,
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
