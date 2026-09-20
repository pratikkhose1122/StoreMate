import 'package:storemate/features/product/data/models/online_product_lookup_result.dart';

/// Contract that every external barcode lookup source must implement.
///
/// Adding a new provider (e.g. EAN-Search, Go-UPC) requires implementing
/// this single interface and registering it in the provider chain.
abstract class BarcodeProvider {
  /// Human-readable name for logging (e.g. 'OpenFoodFacts').
  String get providerName;

  /// Look up a barcode. Returns a normalised result on hit, or `null`
  /// on miss, error, or timeout.
  ///
  /// Implementations must never throw. All exceptions are caught
  /// internally and logged.
  Future<OnlineProductLookupResult?> lookup(String barcode);
}
