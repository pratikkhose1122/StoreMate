// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    _CartItemModel(
      product: json['product'] == null
          ? null
          : ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      isManual: json['isManual'] as bool? ?? false,
      manualName: json['manualName'] as String?,
      manualPrice: const NullableDecimalConverter().fromJson(
        json['manualPrice'],
      ),
      manualTaxPercentage: const NullableDecimalConverter().fromJson(
        json['manualTaxPercentage'],
      ),
      quantity: const DecimalConverter().fromJson(json['quantity']),
      discountAmount: const NullableDecimalConverter().fromJson(
        json['discountAmount'],
      ),
    );

Map<String, dynamic> _$CartItemModelToJson(
  _CartItemModel instance,
) => <String, dynamic>{
  'product': instance.product,
  'isManual': instance.isManual,
  'manualName': instance.manualName,
  'manualPrice': const NullableDecimalConverter().toJson(instance.manualPrice),
  'manualTaxPercentage': const NullableDecimalConverter().toJson(
    instance.manualTaxPercentage,
  ),
  'quantity': const DecimalConverter().toJson(instance.quantity),
  'discountAmount': const NullableDecimalConverter().toJson(
    instance.discountAmount,
  ),
};
