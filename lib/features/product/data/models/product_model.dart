import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:storemate/features/category/data/models/category_model.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'category_id') String? categoryId,
    CategoryModel? category,
    required String name,
    String? description,
    String? sku,
    String? barcode,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'purchase_price') required double purchasePrice,
    @JsonKey(name: 'selling_price') required double sellingPrice,
    required int quantity,
    @JsonKey(name: 'low_stock_threshold') required int lowStockThreshold,
    @JsonKey(name: 'unit_type') required String unitType,
    required String status,
    @JsonKey(name: 'tax_percentage', defaultValue: 0) required double taxPercentage,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}
