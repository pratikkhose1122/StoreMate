import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storemate/features/product/data/datasources/open_food_facts_datasource.dart';
import 'package:storemate/features/product/data/datasources/open_products_facts_datasource.dart';
import 'package:storemate/features/product/data/datasources/upc_item_db_datasource.dart';
import 'package:storemate/features/product/data/models/online_product_lookup_result.dart';
import 'package:storemate/features/product/data/providers/barcode_provider.dart';

final onlineBarcodeLookupServiceProvider =
    Provider<OnlineBarcodeLookupService>((ref) {
  return OnlineBarcodeLookupService(
    providers: [
      ref.read(openFoodFactsDataSourceProvider),
      ref.read(openProductsFactsDataSourceProvider),
      ref.read(upcItemDbDataSourceProvider),
    ],
  );
});

/// In-memory cache entry with expiry.
class _MemoryCacheEntry {
  final OnlineProductLookupResult? result;
  final bool isNegative;
  final DateTime cachedAt;

  _MemoryCacheEntry({
    required this.result,
    required this.isNegative,
    required this.cachedAt,
  });

  bool get isExpired =>
      DateTime.now().difference(cachedAt).inHours >= 24;
}

/// Unified service for handling all online barcode lookups.
///
/// Chains external APIs sequentially through a pluggable [BarcodeProvider]
/// list. Implements two cache layers:
/// - **Memory cache**: `Map<String, _MemoryCacheEntry>` with 24-hour TTL
/// - **Hive cache**: Persistent storage with 30-day positive / 24-hour negative TTL
///
/// Checks connectivity before attempting online calls. Never throws.
class OnlineBarcodeLookupService {
  final List<BarcodeProvider> _providers;
  late final Box<Map> _cacheBox;
  final Map<String, _MemoryCacheEntry> _memoryCache = {};

  OnlineBarcodeLookupService({required List<BarcodeProvider> providers})
      : _providers = providers {
    _cacheBox = Hive.box<Map>('online_barcode_cache');
  }

  /// Looks up a barcode across all configured providers.
  ///
  /// The [onStatusChange] callback provides progressive UI updates.
  /// Returns null if no provider finds the barcode.
  Future<OnlineProductLookupResult?> lookupBarcode(
    String barcode, {
    void Function(String status)? onStatusChange,
  }) async {
    // 1. Memory cache
    final memEntry = _memoryCache[barcode];
    if (memEntry != null && !memEntry.isExpired) {
      if (memEntry.isNegative) {
        debugPrint('[Barcode] Memory cache: HIT (Negative)');
        return null;
      }
      debugPrint('[Barcode] Memory cache: HIT');
      return memEntry.result;
    }

    // 2. Hive cache
    final hiveCacheResult = _checkHiveCache(barcode);
    if (hiveCacheResult != null) {
      if (hiveCacheResult.containsKey('not_found') && hiveCacheResult['not_found'] == true) {
        debugPrint('[Barcode] Hive cache: HIT (Negative)');
        _memoryCache[barcode] = _MemoryCacheEntry(
          result: null, isNegative: true, cachedAt: DateTime.now(),
        );
        return null;
      }

      debugPrint('[Barcode] Hive cache: HIT');
      final result = OnlineProductLookupResult.fromCacheMap(
        Map<String, dynamic>.from(hiveCacheResult['data'] as Map),
        LookupSource.cache,
      );
      _memoryCache[barcode] = _MemoryCacheEntry(
        result: result, isNegative: false, cachedAt: DateTime.now(),
      );
      return result;
    }

    debugPrint('[Barcode] Cache: MISS');

    // 3. Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = connectivityResult.every((c) => c == ConnectivityResult.none);
    if (isOffline) {
      debugPrint('[Barcode] Offline: Skipping online providers');
      onStatusChange?.call('No internet connection');
      return null;
    }

    // 4. Chain through providers sequentially
    for (int i = 0; i < _providers.length; i++) {
      final provider = _providers[i];
      final previousProviders = _providers.sublist(0, i).map((p) => '✓ ${p.providerName} not found').join('\n');
      final statusText = previousProviders.isEmpty
          ? 'Searching ${provider.providerName}...'
          : '$previousProviders\n\nSearching ${provider.providerName}...';
      onStatusChange?.call(statusText);

      final stopwatch = Stopwatch()..start();
      try {
        final result = await Future.any([
          provider.lookup(barcode),
          Future.delayed(const Duration(seconds: 3), () => null),
        ]);
        stopwatch.stop();

        debugPrint('[Barcode] ${provider.providerName}: ${result != null ? 'HIT' : 'MISS'} (${stopwatch.elapsedMilliseconds}ms)');

        if (result != null) {
          _saveToHiveCache(barcode, result, isNegative: false);
          _memoryCache[barcode] = _MemoryCacheEntry(
            result: result, isNegative: false, cachedAt: DateTime.now(),
          );
          return result;
        }
      } catch (e) {
        stopwatch.stop();
        debugPrint('[Barcode] ${provider.providerName}: Error (${stopwatch.elapsedMilliseconds}ms) - $e');
      }
    }

    // 5. No provider found the barcode
    onStatusChange?.call('No online match found');
    _saveToHiveCache(barcode, null, isNegative: true);
    _memoryCache[barcode] = _MemoryCacheEntry(
      result: null, isNegative: true, cachedAt: DateTime.now(),
    );
    return null;
  }

  Map<dynamic, dynamic>? _checkHiveCache(String barcode) {
    final cached = _cacheBox.get(barcode);
    if (cached != null) {
      final cacheTime = DateTime.parse(cached['cached_at'] as String);
      final isNegative = cached['not_found'] == true;
      final ttlDays = isNegative ? 1 : 30;

      if (DateTime.now().difference(cacheTime).inDays < ttlDays) {
        return cached;
      } else {
        _cacheBox.delete(barcode);
      }
    }
    return null;
  }

  void _saveToHiveCache(
    String barcode,
    OnlineProductLookupResult? result, {
    required bool isNegative,
  }) {
    if (isNegative) {
      _cacheBox.put(barcode, {
        'cached_at': DateTime.now().toIso8601String(),
        'not_found': true,
      });
    } else {
      _cacheBox.put(barcode, {
        'cached_at': DateTime.now().toIso8601String(),
        'not_found': false,
        'source': result!.source.name,
        'data': result.toMap(),
      });
    }
  }
}
