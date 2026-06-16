import 'package:dio/dio.dart';
import 'package:storemate/core/constants/api_constants.dart';
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/features/customer/data/models/customer_model.dart';

class CustomerRemoteDataSource {
  final DioClient _dio;

  CustomerRemoteDataSource(this._dio);

  Future<List<CustomerModel>> getCustomers([String? query]) async {
    final response = await _dio.get(
      ApiConstants.customers,
      queryParameters: query != null && query.isNotEmpty ? {'q': query} : null,
    );
    return (response.data as List)
        .map((json) => CustomerModel.fromJson(json))
        .toList();
  }

  Future<CustomerModel> getCustomer(String id) async {
    final response = await _dio.get('${ApiConstants.customers}/$id');
    return CustomerModel.fromJson(response.data);
  }

  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.customers, data: data);
    return CustomerModel.fromJson(response.data);
  }

  Future<CustomerModel> updateCustomer(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('${ApiConstants.customers}/$id', data: data);
    return CustomerModel.fromJson(response.data);
  }

  Future<void> deleteCustomer(String id) async {
    await _dio.delete('${ApiConstants.customers}/$id');
  }
}
