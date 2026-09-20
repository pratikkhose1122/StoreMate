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
      quantity: const DecimalConverter().fromJson(json['quantity']),
      unitPrice: const DecimalConverter().fromJson(json['unitPrice']),
      taxPercentage: const DecimalConverter().fromJson(json['taxPercentage']),
      subtotal: const DecimalConverter().fromJson(json['subtotal']),
    );

Map<String, dynamic> _$SaleItemModelToJson(_SaleItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'productId': instance.productId,
      'productName': instance.productName,
      'quantity': const DecimalConverter().toJson(instance.quantity),
      'unitPrice': const DecimalConverter().toJson(instance.unitPrice),
      'taxPercentage': const DecimalConverter().toJson(instance.taxPercentage),
      'subtotal': const DecimalConverter().toJson(instance.subtotal),
    };

_PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) =>
    _PaymentModel(
      id: json['id'] as String,
      saleId: json['saleId'] as String,
      amount: const DecimalConverter().fromJson(json['amount']),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      transactionId: json['transactionId'] as String?,
    );

Map<String, dynamic> _$PaymentModelToJson(_PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'amount': const DecimalConverter().toJson(instance.amount),
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
  totalAmount: const DecimalConverter().fromJson(json['totalAmount']),
  discountAmount: const DecimalConverter().fromJson(json['discountAmount']),
  taxAmount: const DecimalConverter().fromJson(json['taxAmount']),
  netAmount: const DecimalConverter().fromJson(json['netAmount']),
  amountPaid: const DecimalConverter().fromJson(json['amountPaid']),
  amountDue: const DecimalConverter().fromJson(json['amountDue']),
  refundAmount: const DecimalConverter().fromJson(json['refundAmount']),
  lastRefundAt: json['lastRefundAt'] == null
      ? null
      : DateTime.parse(json['lastRefundAt'] as String),
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

Map<String, dynamic> _$SaleModelToJson(
  _SaleModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'shopId': instance.shopId,
  'customerId': instance.customerId,
  'customer': instance.customer,
  'invoiceNumber': instance.invoiceNumber,
  'status': instance.status,
  'totalAmount': const DecimalConverter().toJson(instance.totalAmount),
  'discountAmount': const DecimalConverter().toJson(instance.discountAmount),
  'taxAmount': const DecimalConverter().toJson(instance.taxAmount),
  'netAmount': const DecimalConverter().toJson(instance.netAmount),
  'amountPaid': const DecimalConverter().toJson(instance.amountPaid),
  'amountDue': const DecimalConverter().toJson(instance.amountDue),
  'refundAmount': _$JsonConverterToJson<dynamic, Decimal>(
    instance.refundAmount,
    const DecimalConverter().toJson,
  ),
  'lastRefundAt': instance.lastRefundAt?.toIso8601String(),
  'shopNameSnapshot': instance.shopNameSnapshot,
  'shopAddressSnapshot': instance.shopAddressSnapshot,
  'shopPhoneSnapshot': instance.shopPhoneSnapshot,
  'items': instance.items,
  'payments': instance.payments,
  'createdAt': instance.createdAt?.toIso8601String(),
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
