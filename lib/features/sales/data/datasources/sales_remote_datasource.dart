import 'package:dio/dio.dart';
import 'package:storemate/core/constants/api_constants.dart';
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/features/sales/data/models/sale_model.dart';

class SalesRemoteDataSource {
  final DioClient _dio;

  SalesRemoteDataSource(this._dio);

  Future<SaleModel> checkout(Map<String, dynamic> data) async {
    final response = await _dio.post('${ApiConstants.sales}/checkout', data: data);
    return SaleModel.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> getSales({
    int limit = 20,
    int offset = 0,
    String? customerId,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> queryParams = {
      'limit': limit,
      'offset': offset,
    };
    if (customerId != null) queryParams['customerId'] = customerId;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _dio.get(ApiConstants.sales, queryParameters: queryParams);
    final data = response.data['data'] as List;
    return {
      'data': data.map((json) => SaleModel.fromJson(json)).toList(),
      'total': response.data['total'],
    };
  }

  Future<SaleModel> getSale(String id) async {
    final response = await _dio.get('${ApiConstants.sales}/$id');
    return SaleModel.fromJson(response.data['data']);
  }
}
