import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/product/data/models/product_model.dart';
import 'package:storemate/features/sales/data/models/cart_item_model.dart';
import 'package:decimal/decimal.dart';

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

  Decimal get totalDiscount => items.fold(Decimal.zero, (sum, item) => sum + (item.discountAmount ?? Decimal.zero));
  Decimal get totalTax => items.fold(Decimal.zero, (sum, item) => sum + item.taxAmount);
  Decimal get totalAmount => items.fold(Decimal.zero, (sum, item) => sum + item.total);
  Decimal get totalItems => items.fold(Decimal.zero, (sum, item) => sum + item.quantity);
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addProduct(ProductModel product, {Decimal? quantity}) {
    final qty = quantity ?? Decimal.one;
    final index = state.items.indexWhere((i) => !i.isManual && i.product?.id == product.id);
    if (index >= 0) {
      final item = state.items[index];
      final newItems = List<CartItemModel>.from(state.items);
      newItems[index] = item.copyWith(quantity: item.quantity + qty);
      state = state.copyWith(items: newItems);
    } else {
      state = state.copyWith(items: [
        ...state.items,
        CartItemModel(product: product, quantity: qty, isManual: false),
      ]);
    }
  }

  void addManualItem({required String name, required Decimal price, required Decimal quantity, Decimal? taxPercentage}) {
    final tax = taxPercentage ?? Decimal.zero;
    state = state.copyWith(items: [
      ...state.items,
      CartItemModel(
        product: null,
        isManual: true,
        manualName: name,
        manualPrice: price,
        manualTaxPercentage: tax,
        quantity: quantity,
      ),
    ]);
  }

  void updateQuantity(int index, Decimal quantity) {
    if (quantity <= Decimal.zero) {
      removeProduct(index);
      return;
    }
    if (index >= 0 && index < state.items.length) {
      final newItems = List<CartItemModel>.from(state.items);
      newItems[index] = newItems[index].copyWith(quantity: quantity);
      state = state.copyWith(items: newItems);
    }
  }

  void removeProduct(int index) {
    if (index >= 0 && index < state.items.length) {
      final newItems = List<CartItemModel>.from(state.items);
      newItems.removeAt(index);
      state = state.copyWith(items: newItems);
    }
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
