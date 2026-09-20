import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/sales/data/models/return_model.dart';
import 'package:storemate/features/sales/data/repositories/refund_repository.dart';

final refundRepositoryProvider = Provider<RefundRepository>((ref) {
  return RefundRepository();
});

final returnsForSaleProvider = FutureProvider.family<List<ReturnModel>, String>((ref, saleId) async {
  final repository = ref.watch(refundRepositoryProvider);
  return repository.getReturnsForSale(saleId);
});

final customerReturnsProvider = FutureProvider.family<List<ReturnModel>, String>((ref, customerId) async {
  final repository = ref.watch(refundRepositoryProvider);
  return repository.getReturnsForCustomer(customerId);
});
