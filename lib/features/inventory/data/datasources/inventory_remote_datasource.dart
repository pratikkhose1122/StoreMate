import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/constants/api_constants.dart';
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/core/providers/core_providers.dart';

final inventoryRemoteDataSourceProvider = Provider<InventoryRemoteDataSource>((ref) {
  return InventoryRemoteDataSource(ref.read(dioClientProvider));
});

class InventoryRemoteDataSource {
  final DioClient _dio;

  InventoryRemoteDataSource(this._dio);

  Future<void> adjustInventory(String productId, int quantityChange, String actionType, [String? notes]) async {
    await _dio.post(ApiConstants.inventoryAdjust, data: {
      'productId': productId,
      'quantityChange': quantityChange,
      'actionType': actionType,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  Future<List<dynamic>> getLogs(String? productId, int limit) async {
    final response = await _dio.get(ApiConstants.inventoryLogs, queryParameters: {
      if (productId != null) 'productId': productId,
      'limit': limit,
    });
    return response.data['data'] as List;
  }

  Future<Map<String, dynamic>> getHistory(String productId, int page, int limit) async {
    final response = await _dio.get('${ApiConstants.inventory}/history/$productId', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return response.data['data'] as Map<String, dynamic>;
  }
}
