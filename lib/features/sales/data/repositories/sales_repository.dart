import 'dart:convert';
import 'package:hive/hive.dart';
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
    String? searchText,
  }) async {
    try {
      final result = await _remoteDataSource.getSales(
        limit: limit,
        offset: offset,
        customerId: customerId,
        startDate: startDate,
        endDate: endDate,
        searchText: searchText,
      );
      
      if (offset == 0 && (searchText == null || searchText.isEmpty) && customerId == null) {
        final box = await Hive.openBox('sales_cache');
        final itemsJson = (result['data'] as List<SaleModel>).map((s) => s.toJson()).toList();
        await box.put('recent_sales', jsonEncode(itemsJson));
      }
      
      return result;
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('socketexception') || errStr.contains('timeout') || errStr.contains('clientexception')) {
        final box = await Hive.openBox('sales_cache');
        final cachedData = box.get('recent_sales');
        if (cachedData != null && cachedData is String) {
          final List<dynamic> decoded = jsonDecode(cachedData);
          var items = decoded.map((e) => SaleModel.fromJson(e as Map<String, dynamic>)).toList();
          
          if (searchText != null && searchText.isNotEmpty) {
            final s = searchText.toLowerCase();
            items = items.where((sale) => sale.invoiceNumber.toLowerCase().contains(s)).toList();
          }
          
          return {
            'data': items,
            'total': items.length,
            'isOffline': true,
          };
        }
      }
      rethrow;
    }
  }

  Future<SaleModel> getSale(String id) async {
    try {
      return await _remoteDataSource.getSale(id);
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('socketexception') || errStr.contains('timeout') || errStr.contains('clientexception')) {
        final box = await Hive.openBox('sales_cache');
        final cachedData = box.get('recent_sales');
        if (cachedData != null && cachedData is String) {
          final List<dynamic> decoded = jsonDecode(cachedData);
          final items = decoded.map((e) => SaleModel.fromJson(e as Map<String, dynamic>)).toList();
          final match = items.where((sale) => sale.id == id).firstOrNull;
          if (match != null) return match;
        }
      }
      rethrow;
    }
  }
}
