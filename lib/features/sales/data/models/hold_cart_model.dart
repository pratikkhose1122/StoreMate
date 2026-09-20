import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:storemate/features/customer/data/models/customer_model.dart';
import 'package:storemate/features/sales/data/models/cart_item_model.dart';
import 'package:decimal/decimal.dart';
import 'package:storemate/core/utils/decimal_converter.dart';

part 'hold_cart_model.freezed.dart';
part 'hold_cart_model.g.dart';

@freezed
abstract class HoldCartModel with _$HoldCartModel {
  const factory HoldCartModel({
    required String id,
    required String name,
    required DateTime createdAt,
    CustomerModel? customer,
    required String paymentMethod,
    @DecimalConverter() required Decimal discount,
    @DecimalConverter() required Decimal tax,
    String? notes,
    @Default([]) List<CartItemModel> cartItems,
  }) = _HoldCartModel;

  factory HoldCartModel.fromJson(Map<String, dynamic> json) =>
      _$HoldCartModelFromJson(json);
}
