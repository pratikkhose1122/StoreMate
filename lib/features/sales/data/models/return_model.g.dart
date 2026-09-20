// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReturnItemModel _$ReturnItemModelFromJson(Map<String, dynamic> json) =>
    _ReturnItemModel(
      id: json['id'] as String,
      returnId: json['returnId'] as String,
      saleItemId: json['saleItemId'] as String,
      productId: json['productId'] as String?,
      quantity: const DecimalConverter().fromJson(json['quantity']),
      unitPrice: const DecimalConverter().fromJson(json['unitPrice']),
      taxAmount: const DecimalConverter().fromJson(json['taxAmount']),
      discountAmount: const DecimalConverter().fromJson(json['discountAmount']),
      lineTotal: const DecimalConverter().fromJson(json['lineTotal']),
    );

Map<String, dynamic> _$ReturnItemModelToJson(
  _ReturnItemModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'returnId': instance.returnId,
  'saleItemId': instance.saleItemId,
  'productId': instance.productId,
  'quantity': const DecimalConverter().toJson(instance.quantity),
  'unitPrice': const DecimalConverter().toJson(instance.unitPrice),
  'taxAmount': const DecimalConverter().toJson(instance.taxAmount),
  'discountAmount': const DecimalConverter().toJson(instance.discountAmount),
  'lineTotal': const DecimalConverter().toJson(instance.lineTotal),
};

_ReturnModel _$ReturnModelFromJson(Map<String, dynamic> json) => _ReturnModel(
  id: json['id'] as String,
  saleId: json['saleId'] as String,
  shopId: json['shopId'] as String,
  customerId: json['customerId'] as String?,
  refundNumber: json['refundNumber'] as String,
  refundAmount: const DecimalConverter().fromJson(json['refundAmount']),
  refundMethod: json['refundMethod'] as String,
  reason: json['reason'] as String?,
  notes: json['notes'] as String?,
  createdBy: json['createdBy'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ReturnItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ReturnModelToJson(_ReturnModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'shopId': instance.shopId,
      'customerId': instance.customerId,
      'refundNumber': instance.refundNumber,
      'refundAmount': const DecimalConverter().toJson(instance.refundAmount),
      'refundMethod': instance.refundMethod,
      'reason': instance.reason,
      'notes': instance.notes,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'items': instance.items,
    };
