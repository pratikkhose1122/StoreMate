// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'return_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReturnItemModel {

 String get id; String get returnId; String get saleItemId; String? get productId;@DecimalConverter() Decimal get quantity;@DecimalConverter() Decimal get unitPrice;@DecimalConverter() Decimal get taxAmount;@DecimalConverter() Decimal get discountAmount;@DecimalConverter() Decimal get lineTotal;
/// Create a copy of ReturnItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReturnItemModelCopyWith<ReturnItemModel> get copyWith => _$ReturnItemModelCopyWithImpl<ReturnItemModel>(this as ReturnItemModel, _$identity);

  /// Serializes this ReturnItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReturnItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.returnId, returnId) || other.returnId == returnId)&&(identical(other.saleItemId, saleItemId) || other.saleItemId == saleItemId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,returnId,saleItemId,productId,quantity,unitPrice,taxAmount,discountAmount,lineTotal);

@override
String toString() {
  return 'ReturnItemModel(id: $id, returnId: $returnId, saleItemId: $saleItemId, productId: $productId, quantity: $quantity, unitPrice: $unitPrice, taxAmount: $taxAmount, discountAmount: $discountAmount, lineTotal: $lineTotal)';
}


}

/// @nodoc
abstract mixin class $ReturnItemModelCopyWith<$Res>  {
  factory $ReturnItemModelCopyWith(ReturnItemModel value, $Res Function(ReturnItemModel) _then) = _$ReturnItemModelCopyWithImpl;
@useResult
$Res call({
 String id, String returnId, String saleItemId, String? productId,@DecimalConverter() Decimal quantity,@DecimalConverter() Decimal unitPrice,@DecimalConverter() Decimal taxAmount,@DecimalConverter() Decimal discountAmount,@DecimalConverter() Decimal lineTotal
});




}
/// @nodoc
class _$ReturnItemModelCopyWithImpl<$Res>
    implements $ReturnItemModelCopyWith<$Res> {
  _$ReturnItemModelCopyWithImpl(this._self, this._then);

  final ReturnItemModel _self;
  final $Res Function(ReturnItemModel) _then;

/// Create a copy of ReturnItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? returnId = null,Object? saleItemId = null,Object? productId = freezed,Object? quantity = null,Object? unitPrice = null,Object? taxAmount = null,Object? discountAmount = null,Object? lineTotal = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,returnId: null == returnId ? _self.returnId : returnId // ignore: cast_nullable_to_non_nullable
as String,saleItemId: null == saleItemId ? _self.saleItemId : saleItemId // ignore: cast_nullable_to_non_nullable
as String,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Decimal,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as Decimal,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as Decimal,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}

}


/// Adds pattern-matching-related methods to [ReturnItemModel].
extension ReturnItemModelPatterns on ReturnItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReturnItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReturnItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReturnItemModel value)  $default,){
final _that = this;
switch (_that) {
case _ReturnItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReturnItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReturnItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String returnId,  String saleItemId,  String? productId, @DecimalConverter()  Decimal quantity, @DecimalConverter()  Decimal unitPrice, @DecimalConverter()  Decimal taxAmount, @DecimalConverter()  Decimal discountAmount, @DecimalConverter()  Decimal lineTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReturnItemModel() when $default != null:
return $default(_that.id,_that.returnId,_that.saleItemId,_that.productId,_that.quantity,_that.unitPrice,_that.taxAmount,_that.discountAmount,_that.lineTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String returnId,  String saleItemId,  String? productId, @DecimalConverter()  Decimal quantity, @DecimalConverter()  Decimal unitPrice, @DecimalConverter()  Decimal taxAmount, @DecimalConverter()  Decimal discountAmount, @DecimalConverter()  Decimal lineTotal)  $default,) {final _that = this;
switch (_that) {
case _ReturnItemModel():
return $default(_that.id,_that.returnId,_that.saleItemId,_that.productId,_that.quantity,_that.unitPrice,_that.taxAmount,_that.discountAmount,_that.lineTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String returnId,  String saleItemId,  String? productId, @DecimalConverter()  Decimal quantity, @DecimalConverter()  Decimal unitPrice, @DecimalConverter()  Decimal taxAmount, @DecimalConverter()  Decimal discountAmount, @DecimalConverter()  Decimal lineTotal)?  $default,) {final _that = this;
switch (_that) {
case _ReturnItemModel() when $default != null:
return $default(_that.id,_that.returnId,_that.saleItemId,_that.productId,_that.quantity,_that.unitPrice,_that.taxAmount,_that.discountAmount,_that.lineTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReturnItemModel implements ReturnItemModel {
  const _ReturnItemModel({required this.id, required this.returnId, required this.saleItemId, this.productId, @DecimalConverter() required this.quantity, @DecimalConverter() required this.unitPrice, @DecimalConverter() required this.taxAmount, @DecimalConverter() required this.discountAmount, @DecimalConverter() required this.lineTotal});
  factory _ReturnItemModel.fromJson(Map<String, dynamic> json) => _$ReturnItemModelFromJson(json);

@override final  String id;
@override final  String returnId;
@override final  String saleItemId;
@override final  String? productId;
@override@DecimalConverter() final  Decimal quantity;
@override@DecimalConverter() final  Decimal unitPrice;
@override@DecimalConverter() final  Decimal taxAmount;
@override@DecimalConverter() final  Decimal discountAmount;
@override@DecimalConverter() final  Decimal lineTotal;

/// Create a copy of ReturnItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReturnItemModelCopyWith<_ReturnItemModel> get copyWith => __$ReturnItemModelCopyWithImpl<_ReturnItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReturnItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReturnItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.returnId, returnId) || other.returnId == returnId)&&(identical(other.saleItemId, saleItemId) || other.saleItemId == saleItemId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,returnId,saleItemId,productId,quantity,unitPrice,taxAmount,discountAmount,lineTotal);

@override
String toString() {
  return 'ReturnItemModel(id: $id, returnId: $returnId, saleItemId: $saleItemId, productId: $productId, quantity: $quantity, unitPrice: $unitPrice, taxAmount: $taxAmount, discountAmount: $discountAmount, lineTotal: $lineTotal)';
}


}

/// @nodoc
abstract mixin class _$ReturnItemModelCopyWith<$Res> implements $ReturnItemModelCopyWith<$Res> {
  factory _$ReturnItemModelCopyWith(_ReturnItemModel value, $Res Function(_ReturnItemModel) _then) = __$ReturnItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String returnId, String saleItemId, String? productId,@DecimalConverter() Decimal quantity,@DecimalConverter() Decimal unitPrice,@DecimalConverter() Decimal taxAmount,@DecimalConverter() Decimal discountAmount,@DecimalConverter() Decimal lineTotal
});




}
/// @nodoc
class __$ReturnItemModelCopyWithImpl<$Res>
    implements _$ReturnItemModelCopyWith<$Res> {
  __$ReturnItemModelCopyWithImpl(this._self, this._then);

  final _ReturnItemModel _self;
  final $Res Function(_ReturnItemModel) _then;

/// Create a copy of ReturnItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? returnId = null,Object? saleItemId = null,Object? productId = freezed,Object? quantity = null,Object? unitPrice = null,Object? taxAmount = null,Object? discountAmount = null,Object? lineTotal = null,}) {
  return _then(_ReturnItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,returnId: null == returnId ? _self.returnId : returnId // ignore: cast_nullable_to_non_nullable
as String,saleItemId: null == saleItemId ? _self.saleItemId : saleItemId // ignore: cast_nullable_to_non_nullable
as String,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Decimal,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as Decimal,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as Decimal,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as Decimal,
  ));
}


}


/// @nodoc
mixin _$ReturnModel {

 String get id; String get saleId; String get shopId; String? get customerId; String get refundNumber;@DecimalConverter() Decimal get refundAmount; String get refundMethod; String? get reason; String? get notes; String get createdBy; DateTime? get createdAt; List<ReturnItemModel> get items;
/// Create a copy of ReturnModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReturnModelCopyWith<ReturnModel> get copyWith => _$ReturnModelCopyWithImpl<ReturnModel>(this as ReturnModel, _$identity);

  /// Serializes this ReturnModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReturnModel&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.refundNumber, refundNumber) || other.refundNumber == refundNumber)&&(identical(other.refundAmount, refundAmount) || other.refundAmount == refundAmount)&&(identical(other.refundMethod, refundMethod) || other.refundMethod == refundMethod)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleId,shopId,customerId,refundNumber,refundAmount,refundMethod,reason,notes,createdBy,createdAt,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ReturnModel(id: $id, saleId: $saleId, shopId: $shopId, customerId: $customerId, refundNumber: $refundNumber, refundAmount: $refundAmount, refundMethod: $refundMethod, reason: $reason, notes: $notes, createdBy: $createdBy, createdAt: $createdAt, items: $items)';
}


}

/// @nodoc
abstract mixin class $ReturnModelCopyWith<$Res>  {
  factory $ReturnModelCopyWith(ReturnModel value, $Res Function(ReturnModel) _then) = _$ReturnModelCopyWithImpl;
@useResult
$Res call({
 String id, String saleId, String shopId, String? customerId, String refundNumber,@DecimalConverter() Decimal refundAmount, String refundMethod, String? reason, String? notes, String createdBy, DateTime? createdAt, List<ReturnItemModel> items
});




}
/// @nodoc
class _$ReturnModelCopyWithImpl<$Res>
    implements $ReturnModelCopyWith<$Res> {
  _$ReturnModelCopyWithImpl(this._self, this._then);

  final ReturnModel _self;
  final $Res Function(ReturnModel) _then;

/// Create a copy of ReturnModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? saleId = null,Object? shopId = null,Object? customerId = freezed,Object? refundNumber = null,Object? refundAmount = null,Object? refundMethod = null,Object? reason = freezed,Object? notes = freezed,Object? createdBy = null,Object? createdAt = freezed,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,refundNumber: null == refundNumber ? _self.refundNumber : refundNumber // ignore: cast_nullable_to_non_nullable
as String,refundAmount: null == refundAmount ? _self.refundAmount : refundAmount // ignore: cast_nullable_to_non_nullable
as Decimal,refundMethod: null == refundMethod ? _self.refundMethod : refundMethod // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ReturnItemModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReturnModel].
extension ReturnModelPatterns on ReturnModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReturnModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReturnModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReturnModel value)  $default,){
final _that = this;
switch (_that) {
case _ReturnModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReturnModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReturnModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String saleId,  String shopId,  String? customerId,  String refundNumber, @DecimalConverter()  Decimal refundAmount,  String refundMethod,  String? reason,  String? notes,  String createdBy,  DateTime? createdAt,  List<ReturnItemModel> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReturnModel() when $default != null:
return $default(_that.id,_that.saleId,_that.shopId,_that.customerId,_that.refundNumber,_that.refundAmount,_that.refundMethod,_that.reason,_that.notes,_that.createdBy,_that.createdAt,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String saleId,  String shopId,  String? customerId,  String refundNumber, @DecimalConverter()  Decimal refundAmount,  String refundMethod,  String? reason,  String? notes,  String createdBy,  DateTime? createdAt,  List<ReturnItemModel> items)  $default,) {final _that = this;
switch (_that) {
case _ReturnModel():
return $default(_that.id,_that.saleId,_that.shopId,_that.customerId,_that.refundNumber,_that.refundAmount,_that.refundMethod,_that.reason,_that.notes,_that.createdBy,_that.createdAt,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String saleId,  String shopId,  String? customerId,  String refundNumber, @DecimalConverter()  Decimal refundAmount,  String refundMethod,  String? reason,  String? notes,  String createdBy,  DateTime? createdAt,  List<ReturnItemModel> items)?  $default,) {final _that = this;
switch (_that) {
case _ReturnModel() when $default != null:
return $default(_that.id,_that.saleId,_that.shopId,_that.customerId,_that.refundNumber,_that.refundAmount,_that.refundMethod,_that.reason,_that.notes,_that.createdBy,_that.createdAt,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReturnModel implements ReturnModel {
  const _ReturnModel({required this.id, required this.saleId, required this.shopId, this.customerId, required this.refundNumber, @DecimalConverter() required this.refundAmount, required this.refundMethod, this.reason, this.notes, required this.createdBy, this.createdAt, final  List<ReturnItemModel> items = const []}): _items = items;
  factory _ReturnModel.fromJson(Map<String, dynamic> json) => _$ReturnModelFromJson(json);

@override final  String id;
@override final  String saleId;
@override final  String shopId;
@override final  String? customerId;
@override final  String refundNumber;
@override@DecimalConverter() final  Decimal refundAmount;
@override final  String refundMethod;
@override final  String? reason;
@override final  String? notes;
@override final  String createdBy;
@override final  DateTime? createdAt;
 final  List<ReturnItemModel> _items;
@override@JsonKey() List<ReturnItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ReturnModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReturnModelCopyWith<_ReturnModel> get copyWith => __$ReturnModelCopyWithImpl<_ReturnModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReturnModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReturnModel&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.refundNumber, refundNumber) || other.refundNumber == refundNumber)&&(identical(other.refundAmount, refundAmount) || other.refundAmount == refundAmount)&&(identical(other.refundMethod, refundMethod) || other.refundMethod == refundMethod)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleId,shopId,customerId,refundNumber,refundAmount,refundMethod,reason,notes,createdBy,createdAt,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ReturnModel(id: $id, saleId: $saleId, shopId: $shopId, customerId: $customerId, refundNumber: $refundNumber, refundAmount: $refundAmount, refundMethod: $refundMethod, reason: $reason, notes: $notes, createdBy: $createdBy, createdAt: $createdAt, items: $items)';
}


}

/// @nodoc
abstract mixin class _$ReturnModelCopyWith<$Res> implements $ReturnModelCopyWith<$Res> {
  factory _$ReturnModelCopyWith(_ReturnModel value, $Res Function(_ReturnModel) _then) = __$ReturnModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String saleId, String shopId, String? customerId, String refundNumber,@DecimalConverter() Decimal refundAmount, String refundMethod, String? reason, String? notes, String createdBy, DateTime? createdAt, List<ReturnItemModel> items
});




}
/// @nodoc
class __$ReturnModelCopyWithImpl<$Res>
    implements _$ReturnModelCopyWith<$Res> {
  __$ReturnModelCopyWithImpl(this._self, this._then);

  final _ReturnModel _self;
  final $Res Function(_ReturnModel) _then;

/// Create a copy of ReturnModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? saleId = null,Object? shopId = null,Object? customerId = freezed,Object? refundNumber = null,Object? refundAmount = null,Object? refundMethod = null,Object? reason = freezed,Object? notes = freezed,Object? createdBy = null,Object? createdAt = freezed,Object? items = null,}) {
  return _then(_ReturnModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,refundNumber: null == refundNumber ? _self.refundNumber : refundNumber // ignore: cast_nullable_to_non_nullable
as String,refundAmount: null == refundAmount ? _self.refundAmount : refundAmount // ignore: cast_nullable_to_non_nullable
as Decimal,refundMethod: null == refundMethod ? _self.refundMethod : refundMethod // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ReturnItemModel>,
  ));
}


}

// dart format on
