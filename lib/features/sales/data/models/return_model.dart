import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:decimal/decimal.dart';
import 'package:storemate/core/utils/decimal_converter.dart';

part 'return_model.freezed.dart';
part 'return_model.g.dart';

@freezed
abstract class ReturnItemModel with _$ReturnItemModel {
  const factory ReturnItemModel({
    required String id,
    required String returnId,
    required String saleItemId,
    String? productId,
    @DecimalConverter() required Decimal quantity,
    @DecimalConverter() required Decimal unitPrice,
    @DecimalConverter() required Decimal taxAmount,
    @DecimalConverter() required Decimal discountAmount,
    @DecimalConverter() required Decimal lineTotal,
  }) = _ReturnItemModel;

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) =>
      _$ReturnItemModelFromJson(json);
}

@freezed
abstract class ReturnModel with _$ReturnModel {
  const factory ReturnModel({
    required String id,
    required String saleId,
    required String shopId,
    String? customerId,
    required String refundNumber,
    @DecimalConverter() required Decimal refundAmount,
    required String refundMethod,
    String? reason,
    String? notes,
    required String createdBy,
    DateTime? createdAt,
    @Default([]) List<ReturnItemModel> items,
  }) = _ReturnModel;

  factory ReturnModel.fromJson(Map<String, dynamic> json) =>
      _$ReturnModelFromJson(json);
}
