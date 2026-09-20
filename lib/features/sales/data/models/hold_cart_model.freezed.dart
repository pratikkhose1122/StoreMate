// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hold_cart_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HoldCartModel {

 String get id; String get name; DateTime get createdAt; CustomerModel? get customer; String get paymentMethod;@DecimalConverter() Decimal get discount;@DecimalConverter() Decimal get tax; String? get notes; List<CartItemModel> get cartItems;
/// Create a copy of HoldCartModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HoldCartModelCopyWith<HoldCartModel> get copyWith => _$HoldCartModelCopyWithImpl<HoldCartModel>(this as HoldCartModel, _$identity);

  /// Serializes this HoldCartModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HoldCartModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.cartItems, cartItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,customer,paymentMethod,discount,tax,notes,const DeepCollectionEquality().hash(cartItems));

@override
String toString() {
  return 'HoldCartModel(id: $id, name: $name, createdAt: $createdAt, customer: $customer, paymentMethod: $paymentMethod, discount: $discount, tax: $tax, notes: $notes, cartItems: $cartItems)';
}


}

/// @nodoc
abstract mixin class $HoldCartModelCopyWith<$Res>  {
  factory $HoldCartModelCopyWith(HoldCartModel value, $Res Function(HoldCartModel) _then) = _$HoldCartModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime createdAt, CustomerModel? customer, String paymentMethod,@DecimalConverter() Decimal discount,@DecimalConverter() Decimal tax, String? notes, List<CartItemModel> cartItems
});


$CustomerModelCopyWith<$Res>? get customer;

}
/// @nodoc
class _$HoldCartModelCopyWithImpl<$Res>
    implements $HoldCartModelCopyWith<$Res> {
  _$HoldCartModelCopyWithImpl(this._self, this._then);

  final HoldCartModel _self;
  final $Res Function(HoldCartModel) _then;

/// Create a copy of HoldCartModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? customer = freezed,Object? paymentMethod = null,Object? discount = null,Object? tax = null,Object? notes = freezed,Object? cartItems = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerModel?,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as Decimal,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as Decimal,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,cartItems: null == cartItems ? _self.cartItems : cartItems // ignore: cast_nullable_to_non_nullable
as List<CartItemModel>,
  ));
}
/// Create a copy of HoldCartModel
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


/// Adds pattern-matching-related methods to [HoldCartModel].
extension HoldCartModelPatterns on HoldCartModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HoldCartModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HoldCartModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HoldCartModel value)  $default,){
final _that = this;
switch (_that) {
case _HoldCartModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HoldCartModel value)?  $default,){
final _that = this;
switch (_that) {
case _HoldCartModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime createdAt,  CustomerModel? customer,  String paymentMethod, @DecimalConverter()  Decimal discount, @DecimalConverter()  Decimal tax,  String? notes,  List<CartItemModel> cartItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HoldCartModel() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.customer,_that.paymentMethod,_that.discount,_that.tax,_that.notes,_that.cartItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime createdAt,  CustomerModel? customer,  String paymentMethod, @DecimalConverter()  Decimal discount, @DecimalConverter()  Decimal tax,  String? notes,  List<CartItemModel> cartItems)  $default,) {final _that = this;
switch (_that) {
case _HoldCartModel():
return $default(_that.id,_that.name,_that.createdAt,_that.customer,_that.paymentMethod,_that.discount,_that.tax,_that.notes,_that.cartItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime createdAt,  CustomerModel? customer,  String paymentMethod, @DecimalConverter()  Decimal discount, @DecimalConverter()  Decimal tax,  String? notes,  List<CartItemModel> cartItems)?  $default,) {final _that = this;
switch (_that) {
case _HoldCartModel() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.customer,_that.paymentMethod,_that.discount,_that.tax,_that.notes,_that.cartItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HoldCartModel implements HoldCartModel {
  const _HoldCartModel({required this.id, required this.name, required this.createdAt, this.customer, required this.paymentMethod, @DecimalConverter() required this.discount, @DecimalConverter() required this.tax, this.notes, final  List<CartItemModel> cartItems = const []}): _cartItems = cartItems;
  factory _HoldCartModel.fromJson(Map<String, dynamic> json) => _$HoldCartModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  DateTime createdAt;
@override final  CustomerModel? customer;
@override final  String paymentMethod;
@override@DecimalConverter() final  Decimal discount;
@override@DecimalConverter() final  Decimal tax;
@override final  String? notes;
 final  List<CartItemModel> _cartItems;
@override@JsonKey() List<CartItemModel> get cartItems {
  if (_cartItems is EqualUnmodifiableListView) return _cartItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cartItems);
}


/// Create a copy of HoldCartModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HoldCartModelCopyWith<_HoldCartModel> get copyWith => __$HoldCartModelCopyWithImpl<_HoldCartModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HoldCartModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HoldCartModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._cartItems, _cartItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,customer,paymentMethod,discount,tax,notes,const DeepCollectionEquality().hash(_cartItems));

@override
String toString() {
  return 'HoldCartModel(id: $id, name: $name, createdAt: $createdAt, customer: $customer, paymentMethod: $paymentMethod, discount: $discount, tax: $tax, notes: $notes, cartItems: $cartItems)';
}


}

/// @nodoc
abstract mixin class _$HoldCartModelCopyWith<$Res> implements $HoldCartModelCopyWith<$Res> {
  factory _$HoldCartModelCopyWith(_HoldCartModel value, $Res Function(_HoldCartModel) _then) = __$HoldCartModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime createdAt, CustomerModel? customer, String paymentMethod,@DecimalConverter() Decimal discount,@DecimalConverter() Decimal tax, String? notes, List<CartItemModel> cartItems
});


@override $CustomerModelCopyWith<$Res>? get customer;

}
/// @nodoc
class __$HoldCartModelCopyWithImpl<$Res>
    implements _$HoldCartModelCopyWith<$Res> {
  __$HoldCartModelCopyWithImpl(this._self, this._then);

  final _HoldCartModel _self;
  final $Res Function(_HoldCartModel) _then;

/// Create a copy of HoldCartModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? customer = freezed,Object? paymentMethod = null,Object? discount = null,Object? tax = null,Object? notes = freezed,Object? cartItems = null,}) {
  return _then(_HoldCartModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerModel?,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as Decimal,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as Decimal,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,cartItems: null == cartItems ? _self._cartItems : cartItems // ignore: cast_nullable_to_non_nullable
as List<CartItemModel>,
  ));
}

/// Create a copy of HoldCartModel
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
