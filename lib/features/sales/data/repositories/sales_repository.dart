import 'package:storemate/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:storemate/features/sales/data/models/sale_model.dart';

class SalesRepository {
  final SalesRemoteDataSource _remoteDataSource;

  SalesRepository(this._remoteDataSource);

  Future<SaleModel> checkout(Map<String, dynamic> data) async {
    return await _remoteDataSource.checkout(data);
  }

  Future<Map<String, dynamic>> getSales({
    int limit = 20,
    int offset = 0,
    String? customerId,
    String? startDate,
    String? endDate,
  }) async {
    return await _remoteDataSource.getSales(
      limit: limit,
      offset: offset,
      customerId: customerId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<SaleModel> getSale(String id) async {
    return await _remoteDataSource.getSale(id);
  }
}
