import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storemate/core/constants/app_constants.dart';
import 'package:storemate/core/config/app_config.dart';
import 'package:storemate/core/storage/secure_storage_service.dart';
import 'package:storemate/core/router/app_router.dart';
import 'package:storemate/core/theme/app_theme.dart';
import 'package:storemate/core/providers/theme_provider.dart';
import 'package:storemate/firebase_options.dart';
import 'package:storemate/features/product/data/services/spell_correction_service.dart';
import 'package:storemate/features/product/data/utils/user_correction_cache.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('App Start: ${DateTime.now().toIso8601String()}');
  
  // Initialize Shared Preferences for Theme Mode
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize Offline Dictionaries and Cache
  await SpellCorrectionService.init();
  await UserCorrectionCache.init();
  
  // Cache migration: old OFF cache -> new unified cache
  final unifiedCacheExists = await Hive.boxExists('online_barcode_cache');
  final oldCacheExists = await Hive.boxExists('open_food_facts_cache');
  
  final cacheBox = await Hive.openBox<Map>('online_barcode_cache');
  
  if (!unifiedCacheExists && oldCacheExists) {
    debugPrint('Migrating old Open Food Facts cache to unified cache...');
    final oldBox = await Hive.openBox<Map>('open_food_facts_cache');
    for (var key in oldBox.keys) {
      final value = oldBox.get(key);
      if (value != null) {
        // Adapt old cache format to new format
        cacheBox.put(key, {
          'cached_at': value['cached_at'],
          'not_found': false,
          'source': 'openFoodFacts', // Old cache was exclusively OFF
          'data': value['data'],
        });
      }
    }
    await oldBox.clear();
    await Hive.deleteBoxFromDisk('open_food_facts_cache');
    debugPrint('Cache migration complete.');
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      accessToken: () async {
        final storage = SecureStorageService();
        return await storage.read(AppConstants.storageKeyAccessToken);
      },
    );
    debugPrint('Supabase Initialized Successfully');
  } catch (e) {
    debugPrint('Supabase Initialization Exception: $e');
  }

  // Initialize Firebase
  debugPrint('Firebase Start: ${DateTime.now().toIso8601String()}');
  try {
    await Future.any([
      Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      Future.delayed(const Duration(seconds: 3)).then((_) {
        throw Exception('Firebase initialization timed out after 3 seconds');
      }),
    ]);
    debugPrint('Firebase Complete: ${DateTime.now().toIso8601String()}');
    debugPrint('Firebase Project: ${Firebase.app().options.projectId}');
    debugPrint('Firebase App ID: ${Firebase.app().options.appId}');
  } catch (e) {
    debugPrint('Firebase initialize exception: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const StoreMateApp(),
    ),
  );
}

class StoreMateApp extends ConsumerWidget {
  const StoreMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'StoreMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme. lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
