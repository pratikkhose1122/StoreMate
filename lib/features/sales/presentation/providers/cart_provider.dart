import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/product/data/models/product_model.dart';
import 'package:storemate/features/sales/data/models/cart_item_model.dart';

class CartState {
  final List<CartItemModel> items;
  final String? customerId;
  
  CartState({
    this.items = const [],
    this.customerId,
  });

  CartState copyWith({
    List<CartItemModel>? items,
    String? customerId,
    bool clearCustomer = false,
  }) {
    return CartState(
      items: items ?? this.items,
      customerId: clearCustomer ? null : (customerId ?? this.customerId),
    );
  }

  double get totalDiscount => items.fold(0, (sum, item) => sum + item.discountAmount);
  double get totalTax => items.fold(0, (sum, item) => sum + item.taxAmount);
  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addProduct(ProductModel product, {int quantity = 1}) {
    final index = state.items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      final item = state.items[index];
      final newItems = List<CartItemModel>.from(state.items);
      newItems[index] = item.copyWith(quantity: item.quantity + quantity);
      state = state.copyWith(items: newItems);
    } else {
      state = state.copyWith(items: [
        ...state.items,
        CartItemModel(product: product, quantity: quantity),
      ]);
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    final index = state.items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      final newItems = List<CartItemModel>.from(state.items);
      newItems[index] = newItems[index].copyWith(quantity: quantity);
      state = state.copyWith(items: newItems);
    }
  }

  void removeProduct(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void setCustomer(String customerId) {
    state = state.copyWith(customerId: customerId);
  }

  void clearCustomer() {
    state = state.copyWith(clearCustomer: true);
  }

  void clearCart() {
    state = CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
