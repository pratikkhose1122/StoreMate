// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CartItemModel {

 ProductModel? get product;// Null if manual
 bool get isManual; String? get manualName;@NullableDecimalConverter() Decimal? get manualPrice;@NullableDecimalConverter() Decimal? get manualTaxPercentage;@DecimalConverter() Decimal get quantity;@NullableDecimalConverter() Decimal? get discountAmount;
/// Create a copy of CartItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartItemModelCopyWith<CartItemModel> get copyWith => _$CartItemModelCopyWithImpl<CartItemModel>(this as CartItemModel, _$identity);

  /// Serializes this CartItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartItemModel&&(identical(other.product, product) || other.product == product)&&(identical(other.isManual, isManual) || other.isManual == isManual)&&(identical(other.manualName, manualName) || other.manualName == manualName)&&(identical(other.manualPrice, manualPrice) || other.manualPrice == manualPrice)&&(identical(other.manualTaxPercentage, manualTaxPercentage) || other.manualTaxPercentage == manualTaxPercentage)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,product,isManual,manualName,manualPrice,manualTaxPercentage,quantity,discountAmount);

@override
String toString() {
  return 'CartItemModel(product: $product, isManual: $isManual, manualName: $manualName, manualPrice: $manualPrice, manualTaxPercentage: $manualTaxPercentage, quantity: $quantity, discountAmount: $discountAmount)';
}


}

/// @nodoc
abstract mixin class $CartItemModelCopyWith<$Res>  {
  factory $CartItemModelCopyWith(CartItemModel value, $Res Function(CartItemModel) _then) = _$CartItemModelCopyWithImpl;
@useResult
$Res call({
 ProductModel? product, bool isManual, String? manualName,@NullableDecimalConverter() Decimal? manualPrice,@NullableDecimalConverter() Decimal? manualTaxPercentage,@DecimalConverter() Decimal quantity,@NullableDecimalConverter() Decimal? discountAmount
});


$ProductModelCopyWith<$Res>? get product;

}
/// @nodoc
class _$CartItemModelCopyWithImpl<$Res>
    implements $CartItemModelCopyWith<$Res> {
  _$CartItemModelCopyWithImpl(this._self, this._then);

  final CartItemModel _self;
  final $Res Function(CartItemModel) _then;

/// Create a copy of CartItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? product = freezed,Object? isManual = null,Object? manualName = freezed,Object? manualPrice = freezed,Object? manualTaxPercentage = freezed,Object? quantity = null,Object? discountAmount = freezed,}) {
  return _then(_self.copyWith(
product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductModel?,isManual: null == isManual ? _self.isManual : isManual // ignore: cast_nullable_to_non_nullable
as bool,manualName: freezed == manualName ? _self.manualName : manualName // ignore: cast_nullable_to_non_nullable
as String?,manualPrice: freezed == manualPrice ? _self.manualPrice : manualPrice // ignore: cast_nullable_to_non_nullable
as Decimal?,manualTaxPercentage: freezed == manualTaxPercentage ? _self.manualTaxPercentage : manualTaxPercentage // ignore: cast_nullable_to_non_nullable
as Decimal?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}
/// Create a copy of CartItemModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductModelCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $ProductModelCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [CartItemModel].
extension CartItemModelPatterns on CartItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartItemModel value)  $default,){
final _that = this;
switch (_that) {
case _CartItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _CartItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProductModel? product,  bool isManual,  String? manualName, @NullableDecimalConverter()  Decimal? manualPrice, @NullableDecimalConverter()  Decimal? manualTaxPercentage, @DecimalConverter()  Decimal quantity, @NullableDecimalConverter()  Decimal? discountAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartItemModel() when $default != null:
return $default(_that.product,_that.isManual,_that.manualName,_that.manualPrice,_that.manualTaxPercentage,_that.quantity,_that.discountAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProductModel? product,  bool isManual,  String? manualName, @NullableDecimalConverter()  Decimal? manualPrice, @NullableDecimalConverter()  Decimal? manualTaxPercentage, @DecimalConverter()  Decimal quantity, @NullableDecimalConverter()  Decimal? discountAmount)  $default,) {final _that = this;
switch (_that) {
case _CartItemModel():
return $default(_that.product,_that.isManual,_that.manualName,_that.manualPrice,_that.manualTaxPercentage,_that.quantity,_that.discountAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProductModel? product,  bool isManual,  String? manualName, @NullableDecimalConverter()  Decimal? manualPrice, @NullableDecimalConverter()  Decimal? manualTaxPercentage, @DecimalConverter()  Decimal quantity, @NullableDecimalConverter()  Decimal? discountAmount)?  $default,) {final _that = this;
switch (_that) {
case _CartItemModel() when $default != null:
return $default(_that.product,_that.isManual,_that.manualName,_that.manualPrice,_that.manualTaxPercentage,_that.quantity,_that.discountAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartItemModel extends CartItemModel {
  const _CartItemModel({this.product, this.isManual = false, this.manualName, @NullableDecimalConverter() this.manualPrice, @NullableDecimalConverter() this.manualTaxPercentage, @DecimalConverter() required this.quantity, @NullableDecimalConverter() this.discountAmount}): super._();
  factory _CartItemModel.fromJson(Map<String, dynamic> json) => _$CartItemModelFromJson(json);

@override final  ProductModel? product;
// Null if manual
@override@JsonKey() final  bool isManual;
@override final  String? manualName;
@override@NullableDecimalConverter() final  Decimal? manualPrice;
@override@NullableDecimalConverter() final  Decimal? manualTaxPercentage;
@override@DecimalConverter() final  Decimal quantity;
@override@NullableDecimalConverter() final  Decimal? discountAmount;

/// Create a copy of CartItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartItemModelCopyWith<_CartItemModel> get copyWith => __$CartItemModelCopyWithImpl<_CartItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItemModel&&(identical(other.product, product) || other.product == product)&&(identical(other.isManual, isManual) || other.isManual == isManual)&&(identical(other.manualName, manualName) || other.manualName == manualName)&&(identical(other.manualPrice, manualPrice) || other.manualPrice == manualPrice)&&(identical(other.manualTaxPercentage, manualTaxPercentage) || other.manualTaxPercentage == manualTaxPercentage)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,product,isManual,manualName,manualPrice,manualTaxPercentage,quantity,discountAmount);

@override
String toString() {
  return 'CartItemModel(product: $product, isManual: $isManual, manualName: $manualName, manualPrice: $manualPrice, manualTaxPercentage: $manualTaxPercentage, quantity: $quantity, discountAmount: $discountAmount)';
}


}

/// @nodoc
abstract mixin class _$CartItemModelCopyWith<$Res> implements $CartItemModelCopyWith<$Res> {
  factory _$CartItemModelCopyWith(_CartItemModel value, $Res Function(_CartItemModel) _then) = __$CartItemModelCopyWithImpl;
@override @useResult
$Res call({
 ProductModel? product, bool isManual, String? manualName,@NullableDecimalConverter() Decimal? manualPrice,@NullableDecimalConverter() Decimal? manualTaxPercentage,@DecimalConverter() Decimal quantity,@NullableDecimalConverter() Decimal? discountAmount
});


@override $ProductModelCopyWith<$Res>? get product;

}
/// @nodoc
class __$CartItemModelCopyWithImpl<$Res>
    implements _$CartItemModelCopyWith<$Res> {
  __$CartItemModelCopyWithImpl(this._self, this._then);

  final _CartItemModel _self;
  final $Res Function(_CartItemModel) _then;

/// Create a copy of CartItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? product = freezed,Object? isManual = null,Object? manualName = freezed,Object? manualPrice = freezed,Object? manualTaxPercentage = freezed,Object? quantity = null,Object? discountAmount = freezed,}) {
  return _then(_CartItemModel(
product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductModel?,isManual: null == isManual ? _self.isManual : isManual // ignore: cast_nullable_to_non_nullable
as bool,manualName: freezed == manualName ? _self.manualName : manualName // ignore: cast_nullable_to_non_nullable
as String?,manualPrice: freezed == manualPrice ? _self.manualPrice : manualPrice // ignore: cast_nullable_to_non_nullable
as Decimal?,manualTaxPercentage: freezed == manualTaxPercentage ? _self.manualTaxPercentage : manualTaxPercentage // ignore: cast_nullable_to_non_nullable
as Decimal?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Decimal,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as Decimal?,
  ));
}

/// Create a copy of CartItemModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductModelCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $ProductModelCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}

// dart format on
