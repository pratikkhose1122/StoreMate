// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryLogModel _$InventoryLogModelFromJson(Map<String, dynamic> json) =>
    _InventoryLogModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      productId: json['product_id'] as String,
      actionType: json['action_type'] as String,
      quantityBefore: (json['quantity_before'] as num).toInt(),
      quantityChange: (json['quantity_change'] as num).toInt(),
      quantityAfter: (json['quantity_after'] as num).toInt(),
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String,
      createdByName: json['created_by_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$InventoryLogModelToJson(_InventoryLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_id': instance.shopId,
      'product_id': instance.productId,
      'action_type': instance.actionType,
      'quantity_before': instance.quantityBefore,
      'quantity_change': instance.quantityChange,
      'quantity_after': instance.quantityAfter,
      'notes': instance.notes,
      'created_by': instance.createdBy,
      'created_by_name': instance.createdByName,
      'created_at': instance.createdAt.toIso8601String(),
    };
