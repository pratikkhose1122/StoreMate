import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around [FlutterSecureStorage] for secure key-value persistence.
///
/// Used to store:
/// - JWT access tokens
/// - User session data
///
/// All data is encrypted at rest using platform-native secure storage:
/// - Android: EncryptedSharedPreferences (AES)
/// - iOS: Keychain
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );

  /// Read a value by key. Returns null if not found.
  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  /// Write a key-value pair.
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Delete a specific key.
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Delete all stored values. Used during logout.
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Check if a key exists.
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }
}
