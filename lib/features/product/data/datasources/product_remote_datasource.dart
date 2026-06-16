import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/constants/api_constants.dart';
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/core/providers/core_providers.dart';
import 'package:storemate/features/product/data/models/product_model.dart';

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource(ref.read(dioClientProvider));
});

class ProductRemoteDataSource {
  final DioClient _dio;

  ProductRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (categoryId != null && categoryId.isNotEmpty) queryParams['categoryId'] = categoryId;

    final response = await _dio.get(ApiConstants.products, queryParameters: queryParams);
    
    final data = response.data['data']['items'] as List;
    final meta = response.data['data']['meta'] as Map<String, dynamic>;
    
    return {
      'items': data.map((e) => ProductModel.fromJson(e)).toList(),
      'meta': meta,
    };
  }

  Future<ProductModel> getProduct(String id) async {
    final response = await _dio.get('${ApiConstants.products}/$id');
    return ProductModel.fromJson(response.data['data']);
  }

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.products, data: data);
    return ProductModel.fromJson(response.data['data']);
  }

  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('${ApiConstants.products}/$id', data: data);
    return ProductModel.fromJson(response.data['data']);
  }

  Future<void> deleteProduct(String id) async {
    await _dio.delete('${ApiConstants.products}/$id');
  }

  Future<ProductModel> uploadImage(String id, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post('${ApiConstants.products}/$id/image', data: formData);
    return ProductModel.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> previewBulkImport(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post('${ApiConstants.products}/bulk-import/preview', data: formData);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> confirmBulkImport(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post('${ApiConstants.products}/bulk-import/confirm', data: formData);
    return response.data['data'] as Map<String, dynamic>;
  }
}
