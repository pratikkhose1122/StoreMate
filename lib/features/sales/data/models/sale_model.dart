import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:storemate/features/customer/data/models/customer_model.dart';

part 'sale_model.freezed.dart';
part 'sale_model.g.dart';

@freezed
abstract class SaleItemModel with _$SaleItemModel {
  const factory SaleItemModel({
    required String id,
    required String saleId,
    String? productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required double taxPercentage,
    required double subtotal,
  }) = _SaleItemModel;

  factory SaleItemModel.fromJson(Map<String, dynamic> json) =>
      _$SaleItemModelFromJson(json);
}

@freezed
abstract class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    required String id,
    required String saleId,
    required double amount,
    required String paymentMethod,
    required String status,
    String? transactionId,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);
}

@freezed
abstract class SaleModel with _$SaleModel {
  const factory SaleModel({
    required String id,
    required String shopId,
    String? customerId,
    CustomerModel? customer,
    required String invoiceNumber,
    required String status,
    required double totalAmount,
    required double discountAmount,
    required double taxAmount,
    required double netAmount,
    required double amountPaid,
    required double amountDue,
    String? shopNameSnapshot,
    String? shopAddressSnapshot,
    String? shopPhoneSnapshot,
    @Default([]) List<SaleItemModel> items,
    @Default([]) List<PaymentModel> payments,
    DateTime? createdAt,
  }) = _SaleModel;

  factory SaleModel.fromJson(Map<String, dynamic> json) =>
      _$SaleModelFromJson(json);
}
