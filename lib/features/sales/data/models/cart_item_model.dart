import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:storemate/features/product/data/models/product_model.dart';
import 'package:decimal/decimal.dart';
import 'package:storemate/core/utils/decimal_converter.dart';

part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

@freezed
abstract class CartItemModel with _$CartItemModel {
  const CartItemModel._();

  const factory CartItemModel({
    ProductModel? product, // Null if manual
    @Default(false) bool isManual,
    String? manualName,
    @NullableDecimalConverter() Decimal? manualPrice,
    @NullableDecimalConverter() Decimal? manualTaxPercentage,
    @DecimalConverter() required Decimal quantity,
    @NullableDecimalConverter() Decimal? discountAmount,
  }) = _CartItemModel;

  Decimal get effectivePrice => isManual ? (manualPrice ?? Decimal.zero) : (product?.sellingPrice ?? Decimal.zero);
  Decimal get effectiveTax => isManual ? (manualTaxPercentage ?? Decimal.zero) : (product?.taxPercentage ?? Decimal.zero);
  String get effectiveName => isManual ? (manualName ?? 'Manual Item') : (product?.name ?? 'Product');

  Decimal get subtotal => (effectivePrice * quantity) - (discountAmount ?? Decimal.zero);
  Decimal get taxAmount => ((subtotal * effectiveTax) / Decimal.fromInt(100)).toDecimal(scaleOnInfinitePrecision: 2);
  Decimal get total => subtotal + taxAmount;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
}
