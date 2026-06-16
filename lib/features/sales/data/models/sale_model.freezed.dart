// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SaleItemModel {

 String get id; String get saleId; String? get productId; String get productName; int get quantity; double get unitPrice; double get taxPercentage; double get subtotal;
/// Create a copy of SaleItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleItemModelCopyWith<SaleItemModel> get copyWith => _$SaleItemModelCopyWithImpl<SaleItemModel>(this as SaleItemModel, _$identity);

  /// Serializes this SaleItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.taxPercentage, taxPercentage) || other.taxPercentage == taxPercentage)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleId,productId,productName,quantity,unitPrice,taxPercentage,subtotal);

@override
String toString() {
  return 'SaleItemModel(id: $id, saleId: $saleId, productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, taxPercentage: $taxPercentage, subtotal: $subtotal)';
}


}

/// @nodoc
abstract mixin class $SaleItemModelCopyWith<$Res>  {
  factory $SaleItemModelCopyWith(SaleItemModel value, $Res Function(SaleItemModel) _then) = _$SaleItemModelCopyWithImpl;
@useResult
$Res call({
 String id, String saleId, String? productId, String productName, int quantity, double unitPrice, double taxPercentage, double subtotal
});




}
/// @nodoc
class _$SaleItemModelCopyWithImpl<$Res>
    implements $SaleItemModelCopyWith<$Res> {
  _$SaleItemModelCopyWithImpl(this._self, this._then);

  final SaleItemModel _self;
  final $Res Function(SaleItemModel) _then;

/// Create a copy of SaleItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? saleId = null,Object? productId = freezed,Object? productName = null,Object? quantity = null,Object? unitPrice = null,Object? taxPercentage = null,Object? subtotal = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,taxPercentage: null == taxPercentage ? _self.taxPercentage : taxPercentage // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SaleItemModel].
extension SaleItemModelPatterns on SaleItemModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleItemModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleItemModel value)  $default,){
final _that = this;
switch (_that) {
case _SaleItemModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _SaleItemModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String saleId,  String? productId,  String productName,  int quantity,  double unitPrice,  double taxPercentage,  double subtotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleItemModel() when $default != null:
return $default(_that.id,_that.saleId,_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.taxPercentage,_that.subtotal);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String saleId,  String? productId,  String productName,  int quantity,  double unitPrice,  double taxPercentage,  double subtotal)  $default,) {final _that = this;
switch (_that) {
case _SaleItemModel():
return $default(_that.id,_that.saleId,_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.taxPercentage,_that.subtotal);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String saleId,  String? productId,  String productName,  int quantity,  double unitPrice,  double taxPercentage,  double subtotal)?  $default,) {final _that = this;
switch (_that) {
case _SaleItemModel() when $default != null:
return $default(_that.id,_that.saleId,_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.taxPercentage,_that.subtotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SaleItemModel implements SaleItemModel {
  const _SaleItemModel({required this.id, required this.saleId, this.productId, required this.productName, required this.quantity, required this.unitPrice, required this.taxPercentage, required this.subtotal});
  factory _SaleItemModel.fromJson(Map<String, dynamic> json) => _$SaleItemModelFromJson(json);

@override final  String id;
@override final  String saleId;
@override final  String? productId;
@override final  String productName;
@override final  int quantity;
@override final  double unitPrice;
@override final  double taxPercentage;
@override final  double subtotal;

/// Create a copy of SaleItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleItemModelCopyWith<_SaleItemModel> get copyWith => __$SaleItemModelCopyWithImpl<_SaleItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SaleItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.taxPercentage, taxPercentage) || other.taxPercentage == taxPercentage)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleId,productId,productName,quantity,unitPrice,taxPercentage,subtotal);

@override
String toString() {
  return 'SaleItemModel(id: $id, saleId: $saleId, productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, taxPercentage: $taxPercentage, subtotal: $subtotal)';
}


}

/// @nodoc
abstract mixin class _$SaleItemModelCopyWith<$Res> implements $SaleItemModelCopyWith<$Res> {
  factory _$SaleItemModelCopyWith(_SaleItemModel value, $Res Function(_SaleItemModel) _then) = __$SaleItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String saleId, String? productId, String productName, int quantity, double unitPrice, double taxPercentage, double subtotal
});




}
/// @nodoc
class __$SaleItemModelCopyWithImpl<$Res>
    implements _$SaleItemModelCopyWith<$Res> {
  __$SaleItemModelCopyWithImpl(this._self, this._then);

  final _SaleItemModel _self;
  final $Res Function(_SaleItemModel) _then;

/// Create a copy of SaleItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? saleId = null,Object? productId = freezed,Object? productName = null,Object? quantity = null,Object? unitPrice = null,Object? taxPercentage = null,Object? subtotal = null,}) {
  return _then(_SaleItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,taxPercentage: null == taxPercentage ? _self.taxPercentage : taxPercentage // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PaymentModel {

 String get id; String get saleId; double get amount; String get paymentMethod; String get status; String? get transactionId;
/// Create a copy of PaymentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentModelCopyWith<PaymentModel> get copyWith => _$PaymentModelCopyWithImpl<PaymentModel>(this as PaymentModel, _$identity);

  /// Serializes this PaymentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.status, status) || other.status == status)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleId,amount,paymentMethod,status,transactionId);

@override
String toString() {
  return 'PaymentModel(id: $id, saleId: $saleId, amount: $amount, paymentMethod: $paymentMethod, status: $status, transactionId: $transactionId)';
}


}

/// @nodoc
abstract mixin class $PaymentModelCopyWith<$Res>  {
  factory $PaymentModelCopyWith(PaymentModel value, $Res Function(PaymentModel) _then) = _$PaymentModelCopyWithImpl;
@useResult
$Res call({
 String id, String saleId, double amount, String paymentMethod, String status, String? transactionId
});




}
/// @nodoc
class _$PaymentModelCopyWithImpl<$Res>
    implements $PaymentModelCopyWith<$Res> {
  _$PaymentModelCopyWithImpl(this._self, this._then);

  final PaymentModel _self;
  final $Res Function(PaymentModel) _then;

/// Create a copy of PaymentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? saleId = null,Object? amount = null,Object? paymentMethod = null,Object? status = null,Object? transactionId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentModel].
extension PaymentModelPatterns on PaymentModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentModel value)  $default,){
final _that = this;
switch (_that) {
case _PaymentModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentModel value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String saleId,  double amount,  String paymentMethod,  String status,  String? transactionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentModel() when $default != null:
return $default(_that.id,_that.saleId,_that.amount,_that.paymentMethod,_that.status,_that.transactionId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String saleId,  double amount,  String paymentMethod,  String status,  String? transactionId)  $default,) {final _that = this;
switch (_that) {
case _PaymentModel():
return $default(_that.id,_that.saleId,_that.amount,_that.paymentMethod,_that.status,_that.transactionId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String saleId,  double amount,  String paymentMethod,  String status,  String? transactionId)?  $default,) {final _that = this;
switch (_that) {
case _PaymentModel() when $default != null:
return $default(_that.id,_that.saleId,_that.amount,_that.paymentMethod,_that.status,_that.transactionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentModel implements PaymentModel {
  const _PaymentModel({required this.id, required this.saleId, required this.amount, required this.paymentMethod, required this.status, this.transactionId});
  factory _PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);

@override final  String id;
@override final  String saleId;
@override final  double amount;
@override final  String paymentMethod;
@override final  String status;
@override final  String? transactionId;

/// Create a copy of PaymentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentModelCopyWith<_PaymentModel> get copyWith => __$PaymentModelCopyWithImpl<_PaymentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.status, status) || other.status == status)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleId,amount,paymentMethod,status,transactionId);

@override
String toString() {
  return 'PaymentModel(id: $id, saleId: $saleId, amount: $amount, paymentMethod: $paymentMethod, status: $status, transactionId: $transactionId)';
}


}

/// @nodoc
abstract mixin class _$PaymentModelCopyWith<$Res> implements $PaymentModelCopyWith<$Res> {
  factory _$PaymentModelCopyWith(_PaymentModel value, $Res Function(_PaymentModel) _then) = __$PaymentModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String saleId, double amount, String paymentMethod, String status, String? transactionId
});




}
/// @nodoc
class __$PaymentModelCopyWithImpl<$Res>
    implements _$PaymentModelCopyWith<$Res> {
  __$PaymentModelCopyWithImpl(this._self, this._then);

  final _PaymentModel _self;
  final $Res Function(_PaymentModel) _then;

/// Create a copy of PaymentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? saleId = null,Object? amount = null,Object? paymentMethod = null,Object? status = null,Object? transactionId = freezed,}) {
  return _then(_PaymentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SaleModel {

 String get id; String get shopId; String? get customerId; CustomerModel? get customer; String get invoiceNumber; String get status; double get totalAmount; double get discountAmount; double get taxAmount; double get netAmount; double get amountPaid; double get amountDue; String? get shopNameSnapshot; String? get shopAddressSnapshot; String? get shopPhoneSnapshot; List<SaleItemModel> get items; List<PaymentModel> get payments; DateTime? get createdAt;
/// Create a copy of SaleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleModelCopyWith<SaleModel> get copyWith => _$SaleModelCopyWithImpl<SaleModel>(this as SaleModel, _$identity);

  /// Serializes this SaleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.netAmount, netAmount) || other.netAmount == netAmount)&&(identical(other.amountPaid, amountPaid) || other.amountPaid == amountPaid)&&(identical(other.amountDue, amountDue) || other.amountDue == amountDue)&&(identical(other.shopNameSnapshot, shopNameSnapshot) || other.shopNameSnapshot == shopNameSnapshot)&&(identical(other.shopAddressSnapshot, shopAddressSnapshot) || other.shopAddressSnapshot == shopAddressSnapshot)&&(identical(other.shopPhoneSnapshot, shopPhoneSnapshot) || other.shopPhoneSnapshot == shopPhoneSnapshot)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.payments, payments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,customerId,customer,invoiceNumber,status,totalAmount,discountAmount,taxAmount,netAmount,amountPaid,amountDue,shopNameSnapshot,shopAddressSnapshot,shopPhoneSnapshot,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(payments),createdAt);

@override
String toString() {
  return 'SaleModel(id: $id, shopId: $shopId, customerId: $customerId, customer: $customer, invoiceNumber: $invoiceNumber, status: $status, totalAmount: $totalAmount, discountAmount: $discountAmount, taxAmount: $taxAmount, netAmount: $netAmount, amountPaid: $amountPaid, amountDue: $amountDue, shopNameSnapshot: $shopNameSnapshot, shopAddressSnapshot: $shopAddressSnapshot, shopPhoneSnapshot: $shopPhoneSnapshot, items: $items, payments: $payments, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SaleModelCopyWith<$Res>  {
  factory $SaleModelCopyWith(SaleModel value, $Res Function(SaleModel) _then) = _$SaleModelCopyWithImpl;
@useResult
$Res call({
 String id, String shopId, String? customerId, CustomerModel? customer, String invoiceNumber, String status, double totalAmount, double discountAmount, double taxAmount, double netAmount, double amountPaid, double amountDue, String? shopNameSnapshot, String? shopAddressSnapshot, String? shopPhoneSnapshot, List<SaleItemModel> items, List<PaymentModel> payments, DateTime? createdAt
});


$CustomerModelCopyWith<$Res>? get customer;

}
/// @nodoc
class _$SaleModelCopyWithImpl<$Res>
    implements $SaleModelCopyWith<$Res> {
  _$SaleModelCopyWithImpl(this._self, this._then);

  final SaleModel _self;
  final $Res Function(SaleModel) _then;

/// Create a copy of SaleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? customerId = freezed,Object? customer = freezed,Object? invoiceNumber = null,Object? status = null,Object? totalAmount = null,Object? discountAmount = null,Object? taxAmount = null,Object? netAmount = null,Object? amountPaid = null,Object? amountDue = null,Object? shopNameSnapshot = freezed,Object? shopAddressSnapshot = freezed,Object? shopPhoneSnapshot = freezed,Object? items = null,Object? payments = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerModel?,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,netAmount: null == netAmount ? _self.netAmount : netAmount // ignore: cast_nullable_to_non_nullable
as double,amountPaid: null == amountPaid ? _self.amountPaid : amountPaid // ignore: cast_nullable_to_non_nullable
as double,amountDue: null == amountDue ? _self.amountDue : amountDue // ignore: cast_nullable_to_non_nullable
as double,shopNameSnapshot: freezed == shopNameSnapshot ? _self.shopNameSnapshot : shopNameSnapshot // ignore: cast_nullable_to_non_nullable
as String?,shopAddressSnapshot: freezed == shopAddressSnapshot ? _self.shopAddressSnapshot : shopAddressSnapshot // ignore: cast_nullable_to_non_nullable
as String?,shopPhoneSnapshot: freezed == shopPhoneSnapshot ? _self.shopPhoneSnapshot : shopPhoneSnapshot // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SaleItemModel>,payments: null == payments ? _self.payments : payments // ignore: cast_nullable_to_non_nullable
as List<PaymentModel>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SaleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerModelCopyWith<$Res>? get customer {
    if (_self.customer == null) {
    return null;
  }

  return $CustomerModelCopyWith<$Res>(_self.customer!, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}


/// Adds pattern-matching-related methods to [SaleModel].
extension SaleModelPatterns on SaleModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleModel value)  $default,){
final _that = this;
switch (_that) {
case _SaleModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleModel value)?  $default,){
final _that = this;
switch (_that) {
case _SaleModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String shopId,  String? customerId,  CustomerModel? customer,  String invoiceNumber,  String status,  double totalAmount,  double discountAmount,  double taxAmount,  double netAmount,  double amountPaid,  double amountDue,  String? shopNameSnapshot,  String? shopAddressSnapshot,  String? shopPhoneSnapshot,  List<SaleItemModel> items,  List<PaymentModel> payments,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleModel() when $default != null:
return $default(_that.id,_that.shopId,_that.customerId,_that.customer,_that.invoiceNumber,_that.status,_that.totalAmount,_that.discountAmount,_that.taxAmount,_that.netAmount,_that.amountPaid,_that.amountDue,_that.shopNameSnapshot,_that.shopAddressSnapshot,_that.shopPhoneSnapshot,_that.items,_that.payments,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String shopId,  String? customerId,  CustomerModel? customer,  String invoiceNumber,  String status,  double totalAmount,  double discountAmount,  double taxAmount,  double netAmount,  double amountPaid,  double amountDue,  String? shopNameSnapshot,  String? shopAddressSnapshot,  String? shopPhoneSnapshot,  List<SaleItemModel> items,  List<PaymentModel> payments,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _SaleModel():
return $default(_that.id,_that.shopId,_that.customerId,_that.customer,_that.invoiceNumber,_that.status,_that.totalAmount,_that.discountAmount,_that.taxAmount,_that.netAmount,_that.amountPaid,_that.amountDue,_that.shopNameSnapshot,_that.shopAddressSnapshot,_that.shopPhoneSnapshot,_that.items,_that.payments,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String shopId,  String? customerId,  CustomerModel? customer,  String invoiceNumber,  String status,  double totalAmount,  double discountAmount,  double taxAmount,  double netAmount,  double amountPaid,  double amountDue,  String? shopNameSnapshot,  String? shopAddressSnapshot,  String? shopPhoneSnapshot,  List<SaleItemModel> items,  List<PaymentModel> payments,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SaleModel() when $default != null:
return $default(_that.id,_that.shopId,_that.customerId,_that.customer,_that.invoiceNumber,_that.status,_that.totalAmount,_that.discountAmount,_that.taxAmount,_that.netAmount,_that.amountPaid,_that.amountDue,_that.shopNameSnapshot,_that.shopAddressSnapshot,_that.shopPhoneSnapshot,_that.items,_that.payments,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SaleModel implements SaleModel {
  const _SaleModel({required this.id, required this.shopId, this.customerId, this.customer, required this.invoiceNumber, required this.status, required this.totalAmount, required this.discountAmount, required this.taxAmount, required this.netAmount, required this.amountPaid, required this.amountDue, this.shopNameSnapshot, this.shopAddressSnapshot, this.shopPhoneSnapshot, final  List<SaleItemModel> items = const [], final  List<PaymentModel> payments = const [], this.createdAt}): _items = items,_payments = payments;
  factory _SaleModel.fromJson(Map<String, dynamic> json) => _$SaleModelFromJson(json);

@override final  String id;
@override final  String shopId;
@override final  String? customerId;
@override final  CustomerModel? customer;
@override final  String invoiceNumber;
@override final  String status;
@override final  double totalAmount;
@override final  double discountAmount;
@override final  double taxAmount;
@override final  double netAmount;
@override final  double amountPaid;
@override final  double amountDue;
@override final  String? shopNameSnapshot;
@override final  String? shopAddressSnapshot;
@override final  String? shopPhoneSnapshot;
 final  List<SaleItemModel> _items;
@override@JsonKey() List<SaleItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<PaymentModel> _payments;
@override@JsonKey() List<PaymentModel> get payments {
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payments);
}

@override final  DateTime? createdAt;

/// Create a copy of SaleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleModelCopyWith<_SaleModel> get copyWith => __$SaleModelCopyWithImpl<_SaleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SaleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.netAmount, netAmount) || other.netAmount == netAmount)&&(identical(other.amountPaid, amountPaid) || other.amountPaid == amountPaid)&&(identical(other.amountDue, amountDue) || other.amountDue == amountDue)&&(identical(other.shopNameSnapshot, shopNameSnapshot) || other.shopNameSnapshot == shopNameSnapshot)&&(identical(other.shopAddressSnapshot, shopAddressSnapshot) || other.shopAddressSnapshot == shopAddressSnapshot)&&(identical(other.shopPhoneSnapshot, shopPhoneSnapshot) || other.shopPhoneSnapshot == shopPhoneSnapshot)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._payments, _payments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,customerId,customer,invoiceNumber,status,totalAmount,discountAmount,taxAmount,netAmount,amountPaid,amountDue,shopNameSnapshot,shopAddressSnapshot,shopPhoneSnapshot,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_payments),createdAt);

@override
String toString() {
  return 'SaleModel(id: $id, shopId: $shopId, customerId: $customerId, customer: $customer, invoiceNumber: $invoiceNumber, status: $status, totalAmount: $totalAmount, discountAmount: $discountAmount, taxAmount: $taxAmount, netAmount: $netAmount, amountPaid: $amountPaid, amountDue: $amountDue, shopNameSnapshot: $shopNameSnapshot, shopAddressSnapshot: $shopAddressSnapshot, shopPhoneSnapshot: $shopPhoneSnapshot, items: $items, payments: $payments, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SaleModelCopyWith<$Res> implements $SaleModelCopyWith<$Res> {
  factory _$SaleModelCopyWith(_SaleModel value, $Res Function(_SaleModel) _then) = __$SaleModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String shopId, String? customerId, CustomerModel? customer, String invoiceNumber, String status, double totalAmount, double discountAmount, double taxAmount, double netAmount, double amountPaid, double amountDue, String? shopNameSnapshot, String? shopAddressSnapshot, String? shopPhoneSnapshot, List<SaleItemModel> items, List<PaymentModel> payments, DateTime? createdAt
});


@override $CustomerModelCopyWith<$Res>? get customer;

}
/// @nodoc
class __$SaleModelCopyWithImpl<$Res>
    implements _$SaleModelCopyWith<$Res> {
  __$SaleModelCopyWithImpl(this._self, this._then);

  final _SaleModel _self;
  final $Res Function(_SaleModel) _then;

/// Create a copy of SaleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? customerId = freezed,Object? customer = freezed,Object? invoiceNumber = null,Object? status = null,Object? totalAmount = null,Object? discountAmount = null,Object? taxAmount = null,Object? netAmount = null,Object? amountPaid = null,Object? amountDue = null,Object? shopNameSnapshot = freezed,Object? shopAddressSnapshot = freezed,Object? shopPhoneSnapshot = freezed,Object? items = null,Object? payments = null,Object? createdAt = freezed,}) {
  return _then(_SaleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerModel?,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,netAmount: null == netAmount ? _self.netAmount : netAmount // ignore: cast_nullable_to_non_nullable
as double,amountPaid: null == amountPaid ? _self.amountPaid : amountPaid // ignore: cast_nullable_to_non_nullable
as double,amountDue: null == amountDue ? _self.amountDue : amountDue // ignore: cast_nullable_to_non_nullable
as double,shopNameSnapshot: freezed == shopNameSnapshot ? _self.shopNameSnapshot : shopNameSnapshot // ignore: cast_nullable_to_non_nullable
as String?,shopAddressSnapshot: freezed == shopAddressSnapshot ? _self.shopAddressSnapshot : shopAddressSnapshot // ignore: cast_nullable_to_non_nullable
as String?,shopPhoneSnapshot: freezed == shopPhoneSnapshot ? _self.shopPhoneSnapshot : shopPhoneSnapshot // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SaleItemModel>,payments: null == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<PaymentModel>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SaleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerModelCopyWith<$Res>? get customer {
    if (_self.customer == null) {
    return null;
  }

  return $CustomerModelCopyWith<$Res>(_self.customer!, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}

// dart format on
