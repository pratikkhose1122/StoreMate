// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductModel _$ProductModelFromJson(Map<String, dynamic> json) =>
    _ProductModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      categoryId: json['categoryId'] as String?,
      category: json['category'] == null
          ? null
          : CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      name: json['name'] as String,
      description: json['description'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      imageUrl: json['imageUrl'] as String?,
      brand: json['brand'] as String?,
      packageSize: json['packageSize'] as String?,
      purchasePrice: const DecimalConverter().fromJson(json['purchasePrice']),
      sellingPrice: const DecimalConverter().fromJson(json['sellingPrice']),
      quantity: const DecimalConverter().fromJson(json['quantity']),
      lowStockThreshold: const DecimalConverter().fromJson(
        json['lowStockThreshold'],
      ),
      unitType: json['unitType'] as String,
      status: json['status'] as String,
      taxPercentage: const DecimalConverter().fromJson(json['taxPercentage']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProductModelToJson(_ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shopId': instance.shopId,
      'categoryId': instance.categoryId,
      'category': instance.category,
      'name': instance.name,
      'description': instance.description,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'imageUrl': instance.imageUrl,
      'brand': instance.brand,
      'packageSize': instance.packageSize,
      'purchasePrice': const DecimalConverter().toJson(instance.purchasePrice),
      'sellingPrice': const DecimalConverter().toJson(instance.sellingPrice),
      'quantity': const DecimalConverter().toJson(instance.quantity),
      'lowStockThreshold': const DecimalConverter().toJson(
        instance.lowStockThreshold,
      ),
      'unitType': instance.unitType,
      'status': instance.status,
      'taxPercentage': const DecimalConverter().toJson(instance.taxPercentage),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
