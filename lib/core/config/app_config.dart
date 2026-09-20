class AppConfig {
  /// Base URL (legacy NestJS API endpoint)
  static String get baseUrl {
    return 'https://storemate-api.onrender.com/api/v1';
  }

  /// Supabase Configuration
  static const String supabaseUrl = 'https://ztnopsxqjgyqviyjqier.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp0bm9wc3hxamd5cXZpeWpxaWVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg3MDUzODAsImV4cCI6MjEwNDI4MTM4MH0.5FrbEt-XH57cMj1pHZgzm_0sGA1QnQyWoWrBkIi1GTA';
}

