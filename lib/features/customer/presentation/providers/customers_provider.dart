import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/core/providers/core_providers.dart';
import 'package:storemate/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:storemate/features/customer/data/models/customer_model.dart';
import 'package:storemate/features/customer/data/repositories/customer_repository.dart';

final customerRemoteDataSourceProvider = Provider<CustomerRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return CustomerRemoteDataSource(dio);
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final remoteDataSource = ref.watch(customerRemoteDataSourceProvider);
  return CustomerRepository(remoteDataSource);
});

class CustomersNotifier extends StateNotifier<AsyncValue<List<CustomerModel>>> {
  final CustomerRepository _repository;

  CustomersNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchCustomers();
  }

  Future<void> fetchCustomers([String? query]) async {
    state = const AsyncValue.loading();
    try {
      final customers = await _repository.getCustomers(query);
      state = AsyncValue.data(customers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final customersProvider = StateNotifierProvider<CustomersNotifier, AsyncValue<List<CustomerModel>>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CustomersNotifier(repository);
});
