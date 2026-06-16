import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/inventory/data/datasources/inventory_remote_datasource.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.read(inventoryRemoteDataSourceProvider));
});

class InventoryRepository {
  final InventoryRemoteDataSource _remoteDataSource;

  InventoryRepository(this._remoteDataSource);

  Future<void> adjustInventory(String productId, int quantityChange, String actionType, [String? notes]) async {
    return await _remoteDataSource.adjustInventory(productId, quantityChange, actionType, notes);
  }

  Future<List<dynamic>> getLogs(String? productId, {int limit = 50}) async {
    return await _remoteDataSource.getLogs(productId, limit);
  }

  Future<Map<String, dynamic>> getHistory(String productId, {int page = 1, int limit = 20}) async {
    return await _remoteDataSource.getHistory(productId, page, limit);
  }
}
