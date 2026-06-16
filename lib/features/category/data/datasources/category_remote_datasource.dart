import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/constants/api_constants.dart';
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/core/providers/core_providers.dart';
import 'package:storemate/features/category/data/models/category_model.dart';

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((ref) {
  return CategoryRemoteDataSource(ref.read(dioClientProvider));
});

class CategoryRemoteDataSource {
  final DioClient _dio;

  CategoryRemoteDataSource(this._dio);

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get(ApiConstants.categories);
    final data = response.data['data'] as List;
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<CategoryModel> createCategory(String name, String? description) async {
    final response = await _dio.post(ApiConstants.categories, data: {
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
    });
    return CategoryModel.fromJson(response.data['data']);
  }

  Future<CategoryModel> updateCategory(String id, String name, String? description) async {
    final response = await _dio.patch('${ApiConstants.categories}/$id', data: {
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
    });
    return CategoryModel.fromJson(response.data['data']);
  }

  Future<void> deleteCategory(String id) async {
    await _dio.delete('${ApiConstants.categories}/$id');
  }
}
