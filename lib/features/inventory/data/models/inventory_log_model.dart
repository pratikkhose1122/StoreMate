import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_log_model.freezed.dart';
part 'inventory_log_model.g.dart';

@freezed
abstract class InventoryLogModel with _$InventoryLogModel {
  const factory InventoryLogModel({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'action_type') required String actionType,
    @JsonKey(name: 'quantity_before') required int quantityBefore,
    @JsonKey(name: 'quantity_change') required int quantityChange,
    @JsonKey(name: 'quantity_after') required int quantityAfter,
    String? notes,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_by_name') String? createdByName,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _InventoryLogModel;

  factory InventoryLogModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryLogModelFromJson(json);
}
