import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/sales/data/models/hold_cart_model.dart';
import 'package:storemate/features/sales/data/repositories/hold_cart_repository.dart';

final holdCartRepositoryProvider = Provider<HoldCartRepository>((ref) {
  return HoldCartRepository();
});

class HoldCartNotifier extends StateNotifier<AsyncValue<List<HoldCartModel>>> {
  final HoldCartRepository _repository;

  HoldCartNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadCarts();
  }

  Future<void> _loadCarts() async {
    try {
      final carts = await _repository.getHoldCarts();
      state = AsyncValue.data(carts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> holdCart(HoldCartModel cart) async {
    await _repository.saveHoldCart(cart);
    await _loadCarts();
  }

  Future<void> deleteCart(String id) async {
    await _repository.deleteHoldCart(id);
    await _loadCarts();
  }
}

final holdCartProvider = StateNotifierProvider<HoldCartNotifier, AsyncValue<List<HoldCartModel>>>((ref) {
  return HoldCartNotifier(ref.watch(holdCartRepositoryProvider));
});
