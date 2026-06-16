// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SaleItemModel _$SaleItemModelFromJson(Map<String, dynamic> json) =>
    _SaleItemModel(
      id: json['id'] as String,
      saleId: json['saleId'] as String,
      productId: json['productId'] as String?,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      taxPercentage: (json['taxPercentage'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );

Map<String, dynamic> _$SaleItemModelToJson(_SaleItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'productId': instance.productId,
      'productName': instance.productName,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'taxPercentage': instance.taxPercentage,
      'subtotal': instance.subtotal,
    };

_PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) =>
    _PaymentModel(
      id: json['id'] as String,
      saleId: json['saleId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      transactionId: json['transactionId'] as String?,
    );

Map<String, dynamic> _$PaymentModelToJson(_PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'amount': instance.amount,
      'paymentMethod': instance.paymentMethod,
      'status': instance.status,
      'transactionId': instance.transactionId,
    };

_SaleModel _$SaleModelFromJson(Map<String, dynamic> json) => _SaleModel(
  id: json['id'] as String,
  shopId: json['shopId'] as String,
  customerId: json['customerId'] as String?,
  customer: json['customer'] == null
      ? null
      : CustomerModel.fromJson(json['customer'] as Map<String, dynamic>),
  invoiceNumber: json['invoiceNumber'] as String,
  status: json['status'] as String,
  totalAmount: (json['totalAmount'] as num).toDouble(),
  discountAmount: (json['discountAmount'] as num).toDouble(),
  taxAmount: (json['taxAmount'] as num).toDouble(),
  netAmount: (json['netAmount'] as num).toDouble(),
  amountPaid: (json['amountPaid'] as num).toDouble(),
  amountDue: (json['amountDue'] as num).toDouble(),
  shopNameSnapshot: json['shopNameSnapshot'] as String?,
  shopAddressSnapshot: json['shopAddressSnapshot'] as String?,
  shopPhoneSnapshot: json['shopPhoneSnapshot'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => SaleItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  payments:
      (json['payments'] as List<dynamic>?)
          ?.map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$SaleModelToJson(_SaleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shopId': instance.shopId,
      'customerId': instance.customerId,
      'customer': instance.customer,
      'invoiceNumber': instance.invoiceNumber,
      'status': instance.status,
      'totalAmount': instance.totalAmount,
      'discountAmount': instance.discountAmount,
      'taxAmount': instance.taxAmount,
      'netAmount': instance.netAmount,
      'amountPaid': instance.amountPaid,
      'amountDue': instance.amountDue,
      'shopNameSnapshot': instance.shopNameSnapshot,
      'shopAddressSnapshot': instance.shopAddressSnapshot,
      'shopPhoneSnapshot': instance.shopPhoneSnapshot,
      'items': instance.items,
      'payments': instance.payments,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
