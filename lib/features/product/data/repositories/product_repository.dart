import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/product/data/datasources/product_remote_datasource.dart';
import 'package:storemate/features/product/data/models/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.read(productRemoteDataSourceProvider));
});

class ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepository(this._remoteDataSource);

  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
  }) async {
    return await _remoteDataSource.getProducts(
      page: page,
      limit: limit,
      search: search,
      categoryId: categoryId,
    );
  }

  Future<ProductModel> getProduct(String id) async {
    return await _remoteDataSource.getProduct(id);
  }

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    return await _remoteDataSource.createProduct(data);
  }

  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    return await _remoteDataSource.updateProduct(id, data);
  }

  Future<void> deleteProduct(String id) async {
    await _remoteDataSource.deleteProduct(id);
  }

  Future<ProductModel> uploadImage(String id, String filePath) async {
    return await _remoteDataSource.uploadImage(id, filePath);
  }

  Future<Map<String, dynamic>> previewBulkImport(String filePath) async {
    return await _remoteDataSource.previewBulkImport(filePath);
  }

  Future<Map<String, dynamic>> confirmBulkImport(String filePath) async {
    return await _remoteDataSource.confirmBulkImport(filePath);
  }
}
