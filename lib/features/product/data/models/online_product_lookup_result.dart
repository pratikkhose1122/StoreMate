/// Source from which a barcode lookup result was obtained.
enum LookupSource {
  /// Found in the local StoreMate database.
  local,

  /// Loaded from the unified Hive cache (previously fetched online).
  cache,

  /// Fetched live from the Open Food Facts API (food products).
  openFoodFacts,

  /// Fetched live from the Open Products Facts API (non-food products).
  openProductsFacts,

  /// Fetched live from the UPCItemDB API (universal products).
  upcItemDb,

  /// User chose to add the product manually (not found anywhere).
  manual,
}

/// A normalised product record returned by any online barcode database.
///
/// Both [OpenFoodFactsDataSource] and [OpenProductsFactsDataSource] convert
/// their raw API responses into this model so the rest of the app never
/// needs to know which API was called.
class OnlineProductLookupResult {
  final String name;
  final String? brand;
  final String? imageUrl;
  final String? quantity;
  final String? categories;
  final String? packaging;
  final String? description;
  final LookupSource source;
  final String barcode;

  const OnlineProductLookupResult({
    required this.name,
    required this.barcode,
    required this.source,
    this.brand,
    this.imageUrl,
    this.quantity,
    this.categories,
    this.packaging,
    this.description,
  });

  /// Convert to a map suitable for the product form's `prefillData` parameter.
  /// Keys match what [ProductFormScreen] already expects.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand ?? '',
      'imageUrl': imageUrl ?? '',
      'quantity': quantity ?? '',
      'packageSize': quantity ?? '',
      'categories': categories ?? '',
      'packaging': packaging ?? '',
      'description': description ?? '',
      'barcode': barcode,
      'source': source.name,
    };
  }

  /// Reconstruct from a cached map (Hive serialisation).
  factory OnlineProductLookupResult.fromCacheMap(
    Map<String, dynamic> map,
    LookupSource source,
  ) {
    return OnlineProductLookupResult(
      name: map['name'] as String? ?? 'Unknown Product',
      barcode: map['barcode'] as String? ?? '',
      source: source,
      brand: map['brand'] as String?,
      imageUrl: map['imageUrl'] as String?,
      quantity: map['quantity'] as String?,
      categories: map['categories'] as String?,
      packaging: map['packaging'] as String?,
      description: map['description'] as String?,
    );
  }

  /// Human-readable label for the source (shown in scanner UI and form banner).
  String get sourceLabel {
    switch (source) {
      case LookupSource.openFoodFacts:
        return 'Open Food Facts';
      case LookupSource.openProductsFacts:
        return 'Open Products Facts';
      case LookupSource.cache:
        return 'Cache';
      case LookupSource.upcItemDb:
        return 'UPC Item DB';
      case LookupSource.local:
        return 'Local Database';
      case LookupSource.manual:
        return 'Manual Entry';
    }
  }

  /// Emoji prefix for the source banner in the product form.
  String get sourceEmoji {
    switch (source) {
      case LookupSource.openFoodFacts:
        return '🌍';
      case LookupSource.openProductsFacts:
        return '📦';
      case LookupSource.cache:
        return '💾';
      case LookupSource.upcItemDb:
        return '🔎';
      case LookupSource.local:
        return '🏪';
      case LookupSource.manual:
        return '✍️';
    }
  }
}
