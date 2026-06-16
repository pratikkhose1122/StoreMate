import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/category/data/datasources/category_remote_datasource.dart';
import 'package:storemate/features/category/data/models/category_model.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.read(categoryRemoteDataSourceProvider));
});

class CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepository(this._remoteDataSource);

  Future<List<CategoryModel>> getCategories() async {
    return await _remoteDataSource.getCategories();
  }

  Future<CategoryModel> createCategory(String name, String? description) async {
    return await _remoteDataSource.createCategory(name, description);
  }

  Future<CategoryModel> updateCategory(String id, String name, String? description) async {
    return await _remoteDataSource.updateCategory(id, name, description);
  }

  Future<void> deleteCategory(String id) async {
    return await _remoteDataSource.deleteCategory(id);
  }
}
