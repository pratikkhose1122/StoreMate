// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hold_cart_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HoldCartModel _$HoldCartModelFromJson(Map<String, dynamic> json) =>
    _HoldCartModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      customer: json['customer'] == null
          ? null
          : CustomerModel.fromJson(json['customer'] as Map<String, dynamic>),
      paymentMethod: json['paymentMethod'] as String,
      discount: const DecimalConverter().fromJson(json['discount']),
      tax: const DecimalConverter().fromJson(json['tax']),
      notes: json['notes'] as String?,
      cartItems:
          (json['cartItems'] as List<dynamic>?)
              ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HoldCartModelToJson(_HoldCartModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'customer': instance.customer,
      'paymentMethod': instance.paymentMethod,
      'discount': const DecimalConverter().toJson(instance.discount),
      'tax': const DecimalConverter().toJson(instance.tax),
      'notes': instance.notes,
      'cartItems': instance.cartItems,
    };
