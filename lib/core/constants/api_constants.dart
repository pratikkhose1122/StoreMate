import 'package:storemate/core/config/app_config.dart';

/// API configuration constants.
///
/// Dynamic [baseUrl] based on the current AppConfig environment.
class ApiConstants {
  ApiConstants._();

  /// Base URL for the NestJS API.
  static String get baseUrl => AppConfig.baseUrl;

  /// Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ── Auth Endpoints ────────────────────────────────────────
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';

  // ── Shop Endpoints ────────────────────────────────────────
  static const String shops = '/shops';

  // ── Categories Endpoints ────────────────────────────────────
  static const String categories = '/categories';

  // ── Products Endpoints ──────────────────────────────────────
  static const String products = '/products';

  // ── Inventory Endpoints ─────────────────────────────────────
  static const String inventoryAdjust = '/inventory/adjust';
  static const String inventoryLogs = '/inventory/logs';

  // ── Dashboard Endpoints ─────────────────────────────────────
  static const String dashboardSummary = '/dashboard/summary';

  // ── Missing Endpoints ─────────────────────────────────────
  static const String inventory = '/inventory';
  static const String customers = '/customers';
  static const String sales = '/sales';
}
