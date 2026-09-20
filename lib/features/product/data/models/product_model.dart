import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:storemate/features/category/data/models/category_model.dart';
import 'package:decimal/decimal.dart';
import 'package:storemate/core/utils/decimal_converter.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String shopId,
    String? categoryId,
    CategoryModel? category,
    required String name,
    String? description,
    String? sku,
    String? barcode,
    String? imageUrl,
    String? brand,
    String? packageSize,
    @DecimalConverter() required Decimal purchasePrice,
    @DecimalConverter() required Decimal sellingPrice,
    @DecimalConverter() required Decimal quantity,
    @DecimalConverter() required Decimal lowStockThreshold,
    required String unitType,
    required String status,
    @DecimalConverter() required Decimal taxPercentage,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

extension ProductModelExtension on ProductModel {
  String get productType => (barcode != null && barcode!.trim().isNotEmpty) ? 'Barcode Product' : 'Manual Product';
}
