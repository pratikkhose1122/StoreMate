import 'package:storemate/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:storemate/features/customer/data/models/customer_model.dart';

class CustomerRepository {
  final CustomerRemoteDataSource _remoteDataSource;

  CustomerRepository(this._remoteDataSource);

  Future<List<CustomerModel>> getCustomers([String? query]) async {
    return await _remoteDataSource.getCustomers(query);
  }

  Future<CustomerModel> getCustomer(String id) async {
    return await _remoteDataSource.getCustomer(id);
  }

  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    return await _remoteDataSource.createCustomer(data);
  }

  Future<CustomerModel> updateCustomer(String id, Map<String, dynamic> data) async {
    return await _remoteDataSource.updateCustomer(id, data);
  }

  Future<void> deleteCustomer(String id) async {
    await _remoteDataSource.deleteCustomer(id);
  }
}
