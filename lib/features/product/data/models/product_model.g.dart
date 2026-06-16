// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductModel _$ProductModelFromJson(Map<String, dynamic> json) =>
    _ProductModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      categoryId: json['category_id'] as String?,
      category: json['category'] == null
          ? null
          : CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      name: json['name'] as String,
      description: json['description'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      imageUrl: json['image_url'] as String?,
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      sellingPrice: (json['selling_price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      lowStockThreshold: (json['low_stock_threshold'] as num).toInt(),
      unitType: json['unit_type'] as String,
      status: json['status'] as String,
      taxPercentage: (json['tax_percentage'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProductModelToJson(_ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_id': instance.shopId,
      'category_id': instance.categoryId,
      'category': instance.category,
      'name': instance.name,
      'description': instance.description,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'image_url': instance.imageUrl,
      'purchase_price': instance.purchasePrice,
      'selling_price': instance.sellingPrice,
      'quantity': instance.quantity,
      'low_stock_threshold': instance.lowStockThreshold,
      'unit_type': instance.unitType,
      'status': instance.status,
      'tax_percentage': instance.taxPercentage,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
