import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/product/data/models/online_product_lookup_result.dart';
import 'package:storemate/features/product/data/providers/barcode_provider.dart';

final upcItemDbDataSourceProvider = Provider<UpcItemDbDataSource>((ref) {
  return UpcItemDbDataSource();
});

/// Fetches universal product data from the UPCItemDB free trial API.
///
/// Endpoint: `https://api.upcitemdb.com/prod/trial/lookup?upc={barcode}`
/// Free tier: 100 requests/day, 6 requests/minute, no API key required.
///
/// Covers electronics, cosmetics, hardware, clothing, and other non-food
/// products that OpenFoodFacts/OpenProductsFacts typically miss.
class UpcItemDbDataSource implements BarcodeProvider {
  late final Dio _dio;

  @override
  String get providerName => 'UPCItemDB';

  UpcItemDbDataSource() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.upcitemdb.com/prod/trial/',
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'StoreMate/1.0',
        },
      ),
    );
  }

  @override
  Future<OnlineProductLookupResult?> lookup(String barcode) async {
    if (!_isValidBarcode(barcode)) {
      debugPrint('[Barcode] UPCItemDB: Invalid barcode format');
      return null;
    }

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.get('lookup', queryParameters: {'upc': barcode});

      if (response.statusCode == 200 && response.data != null) {
        final items = response.data['items'] as List?;
        if (items == null || items.isEmpty) {
          stopwatch.stop();
          debugPrint('[Barcode] UPCItemDB: Not found (${stopwatch.elapsedMilliseconds}ms)');
          return null;
        }

        final item = items.first as Map<String, dynamic>;
        final result = _mapProduct(item, barcode);

        if (result == null) {
          stopwatch.stop();
          debugPrint('[Barcode] UPCItemDB: Empty product, treating as not found (${stopwatch.elapsedMilliseconds}ms)');
          return null;
        }

        stopwatch.stop();
        debugPrint('[Barcode] UPCItemDB: HIT (${stopwatch.elapsedMilliseconds}ms)');
        return result;
      }
    } on DioException catch (e) {
      stopwatch.stop();
      if (e.response?.statusCode == 429) {
        debugPrint('[Barcode] UPCItemDB: Rate limited (${stopwatch.elapsedMilliseconds}ms)');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        debugPrint('[Barcode] UPCItemDB: Timeout (${stopwatch.elapsedMilliseconds}ms)');
      } else {
        debugPrint('[Barcode] UPCItemDB: Error (${stopwatch.elapsedMilliseconds}ms) - $e');
      }
      return null;
    } catch (e) {
      stopwatch.stop();
      debugPrint('[Barcode] UPCItemDB: Error (${stopwatch.elapsedMilliseconds}ms) - $e');
      return null;
    }

    stopwatch.stop();
    debugPrint('[Barcode] UPCItemDB: No data (${stopwatch.elapsedMilliseconds}ms)');
    return null;
  }

  bool _isValidBarcode(String barcode) {
    final RegExp numericRegex = RegExp(r'^\d+$');
    return numericRegex.hasMatch(barcode) && barcode.length >= 6 && barcode.length <= 16;
  }

  OnlineProductLookupResult? _mapProduct(Map<String, dynamic> item, String barcode) {
    final title = item['title']?.toString().trim() ?? '';
    if (title.isEmpty || title.toLowerCase() == 'unknown') {
      return null;
    }

    final brand = item['brand']?.toString().trim() ?? '';
    final description = item['description']?.toString().trim() ?? '';
    final category = item['category']?.toString().trim() ?? '';
    final size = item['size']?.toString().trim() ?? '';

    // Extract first image from images array
    String? imageUrl;
    final images = item['images'] as List?;
    if (images != null && images.isNotEmpty) {
      imageUrl = images.first.toString();
    }

    return OnlineProductLookupResult(
      name: title,
      barcode: barcode,
      source: LookupSource.upcItemDb,
      brand: brand.isNotEmpty ? brand : null,
      imageUrl: imageUrl,
      quantity: size.isNotEmpty ? size : null,
      categories: category.isNotEmpty ? category : null,
      description: description.isNotEmpty ? description : null,
    );
  }
}
