/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'StoreMate';
  static const String appTagline = 'Smart Inventory & Billing';
  static const String appVersion = '1.0.0';

  /// Indian country code for phone number formatting.
  static const String countryCode = '+91';

  /// OTP length expected from Firebase Phone Auth.
  static const int otpLength = 6;

  /// Resend OTP cooldown in seconds.
  static const int otpResendCooldown = 30;

  /// Secure storage keys.
  static const String storageKeyAccessToken = 'access_token';
  static const String storageKeyUserData = 'user_data';

  /// Predefined business types matching the backend CHECK constraint.
  static const List<String> businessTypes = [
    'kirana',
    'electronics',
    'clothing',
    'hardware',
    'pharmacy',
    'restaurant',
    'general',
    'other',
  ];

  /// Human-readable labels for business types.
  static const Map<String, String> businessTypeLabels = {
    'general': 'General Store (Kirana)',
    'electronics': 'Electronics & Mobile',
    'clothing': 'Clothing & Apparel',
    'hardware': 'Hardware & Tools',
    'pharmacy': 'Pharmacy / Medical',
    'fmcg': 'FMCG Distributor',
    'other': 'Other Business',
  };

  // Phase 2: Product & Inventory Constants
  static const List<String> unitTypes = [
    'piece', 'kg', 'gram', 'litre', 'ml', 'meter', 'pack', 'box'
  ];

  static const List<String> productStatuses = [
    'active', 'inactive', 'out_of_stock', 'archived'
  ];

  static const List<String> inventoryActions = [
    'stock_in', 'stock_out', 'adjustment', 'sale', 'purchase', 'return'
  ];
}
