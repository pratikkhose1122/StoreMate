import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/core/providers/core_providers.dart';
import 'package:storemate/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:storemate/features/sales/data/models/sale_model.dart';
import 'package:storemate/features/sales/data/repositories/sales_repository.dart';

final salesRemoteDataSourceProvider = Provider<SalesRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return SalesRemoteDataSource(dio);
});

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final remoteDataSource = ref.watch(salesRemoteDataSourceProvider);
  return SalesRepository(remoteDataSource);
});

class SalesHistoryNotifier extends StateNotifier<AsyncValue<List<SaleModel>>> {
  final SalesRepository _repository;

  SalesHistoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchSales();
  }

  Future<void> fetchSales({
    int limit = 20,
    int offset = 0,
    String? customerId,
    String? startDate,
    String? endDate,
    bool refresh = false,
  }) async {
    if (refresh) state = const AsyncValue.loading();
    try {
      final result = await _repository.getSales(
        limit: limit,
        offset: offset,
        customerId: customerId,
        startDate: startDate,
        endDate: endDate,
      );
      state = AsyncValue.data(result['data'] as List<SaleModel>);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final salesHistoryProvider = StateNotifierProvider<SalesHistoryNotifier, AsyncValue<List<SaleModel>>>((ref) {
  final repository = ref.watch(salesRepositoryProvider);
  return SalesHistoryNotifier(repository);
});
