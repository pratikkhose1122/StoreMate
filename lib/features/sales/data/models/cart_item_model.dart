import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:storemate/features/product/data/models/product_model.dart';

part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

@freezed
abstract class CartItemModel with _$CartItemModel {
  const CartItemModel._();

  const factory CartItemModel({
    required ProductModel product,
    required int quantity,
    @Default(0) double discountAmount,
  }) = _CartItemModel;

  double get subtotal => (product.sellingPrice * quantity) - discountAmount;
  double get taxAmount => (subtotal * product.taxPercentage) / 100;
  double get total => subtotal + taxAmount;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
}
