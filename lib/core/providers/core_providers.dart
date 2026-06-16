import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/storage/secure_storage_service.dart';
import 'package:storemate/core/network/dio_client.dart';

/// Global provider for [SecureStorageService].
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Global provider for [DioClient].
/// Depends on [SecureStorageService] for JWT injection.
final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage);
});
