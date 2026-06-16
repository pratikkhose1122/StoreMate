import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/router/app_router.dart';
import 'package:storemate/core/theme/app_theme.dart';
import 'package:storemate/core/config/app_config.dart';
import 'package:storemate/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set the environment to Production for Cloud Deployment
  AppConfig.init(ApiEnvironment.production);

  // Initialize Firebase
  debugPrint('Firebase initialize start');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialize success');
  } catch (e) {
    debugPrint('Firebase initialize exception: $e');
  }

  runApp(
    // Wrap the entire app in ProviderScope for Riverpod
    const ProviderScope(child: StoreMateApp()),
  );
}

class StoreMateApp extends ConsumerWidget {
  const StoreMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'StoreMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
