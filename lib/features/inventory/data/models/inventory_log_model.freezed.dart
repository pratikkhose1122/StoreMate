// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventoryLogModel {

 String get id;@JsonKey(name: 'shop_id') String get shopId;@JsonKey(name: 'product_id') String get productId;@JsonKey(name: 'action_type') String get actionType;@JsonKey(name: 'quantity_before') int get quantityBefore;@JsonKey(name: 'quantity_change') int get quantityChange;@JsonKey(name: 'quantity_after') int get quantityAfter; String? get notes;@JsonKey(name: 'created_by') String get createdBy;@JsonKey(name: 'created_by_name') String? get createdByName;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of InventoryLogModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryLogModelCopyWith<InventoryLogModel> get copyWith => _$InventoryLogModelCopyWithImpl<InventoryLogModel>(this as InventoryLogModel, _$identity);

  /// Serializes this InventoryLogModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryLogModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.quantityBefore, quantityBefore) || other.quantityBefore == quantityBefore)&&(identical(other.quantityChange, quantityChange) || other.quantityChange == quantityChange)&&(identical(other.quantityAfter, quantityAfter) || other.quantityAfter == quantityAfter)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,productId,actionType,quantityBefore,quantityChange,quantityAfter,notes,createdBy,createdByName,createdAt);

@override
String toString() {
  return 'InventoryLogModel(id: $id, shopId: $shopId, productId: $productId, actionType: $actionType, quantityBefore: $quantityBefore, quantityChange: $quantityChange, quantityAfter: $quantityAfter, notes: $notes, createdBy: $createdBy, createdByName: $createdByName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $InventoryLogModelCopyWith<$Res>  {
  factory $InventoryLogModelCopyWith(InventoryLogModel value, $Res Function(InventoryLogModel) _then) = _$InventoryLogModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'action_type') String actionType,@JsonKey(name: 'quantity_before') int quantityBefore,@JsonKey(name: 'quantity_change') int quantityChange,@JsonKey(name: 'quantity_after') int quantityAfter, String? notes,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'created_by_name') String? createdByName,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$InventoryLogModelCopyWithImpl<$Res>
    implements $InventoryLogModelCopyWith<$Res> {
  _$InventoryLogModelCopyWithImpl(this._self, this._then);

  final InventoryLogModel _self;
  final $Res Function(InventoryLogModel) _then;

/// Create a copy of InventoryLogModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? productId = null,Object? actionType = null,Object? quantityBefore = null,Object? quantityChange = null,Object? quantityAfter = null,Object? notes = freezed,Object? createdBy = null,Object? createdByName = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as String,quantityBefore: null == quantityBefore ? _self.quantityBefore : quantityBefore // ignore: cast_nullable_to_non_nullable
as int,quantityChange: null == quantityChange ? _self.quantityChange : quantityChange // ignore: cast_nullable_to_non_nullable
as int,quantityAfter: null == quantityAfter ? _self.quantityAfter : quantityAfter // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryLogModel].
extension InventoryLogModelPatterns on InventoryLogModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryLogModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryLogModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryLogModel value)  $default,){
final _that = this;
switch (_that) {
case _InventoryLogModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryLogModel value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryLogModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'action_type')  String actionType, @JsonKey(name: 'quantity_before')  int quantityBefore, @JsonKey(name: 'quantity_change')  int quantityChange, @JsonKey(name: 'quantity_after')  int quantityAfter,  String? notes, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'created_by_name')  String? createdByName, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryLogModel() when $default != null:
return $default(_that.id,_that.shopId,_that.productId,_that.actionType,_that.quantityBefore,_that.quantityChange,_that.quantityAfter,_that.notes,_that.createdBy,_that.createdByName,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'action_type')  String actionType, @JsonKey(name: 'quantity_before')  int quantityBefore, @JsonKey(name: 'quantity_change')  int quantityChange, @JsonKey(name: 'quantity_after')  int quantityAfter,  String? notes, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'created_by_name')  String? createdByName, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _InventoryLogModel():
return $default(_that.id,_that.shopId,_that.productId,_that.actionType,_that.quantityBefore,_that.quantityChange,_that.quantityAfter,_that.notes,_that.createdBy,_that.createdByName,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'action_type')  String actionType, @JsonKey(name: 'quantity_before')  int quantityBefore, @JsonKey(name: 'quantity_change')  int quantityChange, @JsonKey(name: 'quantity_after')  int quantityAfter,  String? notes, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'created_by_name')  String? createdByName, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InventoryLogModel() when $default != null:
return $default(_that.id,_that.shopId,_that.productId,_that.actionType,_that.quantityBefore,_that.quantityChange,_that.quantityAfter,_that.notes,_that.createdBy,_that.createdByName,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventoryLogModel implements InventoryLogModel {
  const _InventoryLogModel({required this.id, @JsonKey(name: 'shop_id') required this.shopId, @JsonKey(name: 'product_id') required this.productId, @JsonKey(name: 'action_type') required this.actionType, @JsonKey(name: 'quantity_before') required this.quantityBefore, @JsonKey(name: 'quantity_change') required this.quantityChange, @JsonKey(name: 'quantity_after') required this.quantityAfter, this.notes, @JsonKey(name: 'created_by') required this.createdBy, @JsonKey(name: 'created_by_name') this.createdByName, @JsonKey(name: 'created_at') required this.createdAt});
  factory _InventoryLogModel.fromJson(Map<String, dynamic> json) => _$InventoryLogModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'shop_id') final  String shopId;
@override@JsonKey(name: 'product_id') final  String productId;
@override@JsonKey(name: 'action_type') final  String actionType;
@override@JsonKey(name: 'quantity_before') final  int quantityBefore;
@override@JsonKey(name: 'quantity_change') final  int quantityChange;
@override@JsonKey(name: 'quantity_after') final  int quantityAfter;
@override final  String? notes;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override@JsonKey(name: 'created_by_name') final  String? createdByName;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of InventoryLogModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryLogModelCopyWith<_InventoryLogModel> get copyWith => __$InventoryLogModelCopyWithImpl<_InventoryLogModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventoryLogModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryLogModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.quantityBefore, quantityBefore) || other.quantityBefore == quantityBefore)&&(identical(other.quantityChange, quantityChange) || other.quantityChange == quantityChange)&&(identical(other.quantityAfter, quantityAfter) || other.quantityAfter == quantityAfter)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,productId,actionType,quantityBefore,quantityChange,quantityAfter,notes,createdBy,createdByName,createdAt);

@override
String toString() {
  return 'InventoryLogModel(id: $id, shopId: $shopId, productId: $productId, actionType: $actionType, quantityBefore: $quantityBefore, quantityChange: $quantityChange, quantityAfter: $quantityAfter, notes: $notes, createdBy: $createdBy, createdByName: $createdByName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InventoryLogModelCopyWith<$Res> implements $InventoryLogModelCopyWith<$Res> {
  factory _$InventoryLogModelCopyWith(_InventoryLogModel value, $Res Function(_InventoryLogModel) _then) = __$InventoryLogModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'action_type') String actionType,@JsonKey(name: 'quantity_before') int quantityBefore,@JsonKey(name: 'quantity_change') int quantityChange,@JsonKey(name: 'quantity_after') int quantityAfter, String? notes,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'created_by_name') String? createdByName,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$InventoryLogModelCopyWithImpl<$Res>
    implements _$InventoryLogModelCopyWith<$Res> {
  __$InventoryLogModelCopyWithImpl(this._self, this._then);

  final _InventoryLogModel _self;
  final $Res Function(_InventoryLogModel) _then;

/// Create a copy of InventoryLogModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? productId = null,Object? actionType = null,Object? quantityBefore = null,Object? quantityChange = null,Object? quantityAfter = null,Object? notes = freezed,Object? createdBy = null,Object? createdByName = freezed,Object? createdAt = null,}) {
  return _then(_InventoryLogModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as String,quantityBefore: null == quantityBefore ? _self.quantityBefore : quantityBefore // ignore: cast_nullable_to_non_nullable
as int,quantityChange: null == quantityChange ? _self.quantityChange : quantityChange // ignore: cast_nullable_to_non_nullable
as int,quantityAfter: null == quantityAfter ? _self.quantityAfter : quantityAfter // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
