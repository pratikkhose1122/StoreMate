// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductModel {

 String get id;@JsonKey(name: 'shop_id') String get shopId;@JsonKey(name: 'category_id') String? get categoryId; CategoryModel? get category; String get name; String? get description; String? get sku; String? get barcode;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'purchase_price') double get purchasePrice;@JsonKey(name: 'selling_price') double get sellingPrice; int get quantity;@JsonKey(name: 'low_stock_threshold') int get lowStockThreshold;@JsonKey(name: 'unit_type') String get unitType; String get status;@JsonKey(name: 'tax_percentage', defaultValue: 0) double get taxPercentage;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductModelCopyWith<ProductModel> get copyWith => _$ProductModelCopyWithImpl<ProductModel>(this as ProductModel, _$identity);

  /// Serializes this ProductModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.category, category) || other.category == category)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.sellingPrice, sellingPrice) || other.sellingPrice == sellingPrice)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.lowStockThreshold, lowStockThreshold) || other.lowStockThreshold == lowStockThreshold)&&(identical(other.unitType, unitType) || other.unitType == unitType)&&(identical(other.status, status) || other.status == status)&&(identical(other.taxPercentage, taxPercentage) || other.taxPercentage == taxPercentage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,categoryId,category,name,description,sku,barcode,imageUrl,purchasePrice,sellingPrice,quantity,lowStockThreshold,unitType,status,taxPercentage,createdAt,updatedAt);

@override
String toString() {
  return 'ProductModel(id: $id, shopId: $shopId, categoryId: $categoryId, category: $category, name: $name, description: $description, sku: $sku, barcode: $barcode, imageUrl: $imageUrl, purchasePrice: $purchasePrice, sellingPrice: $sellingPrice, quantity: $quantity, lowStockThreshold: $lowStockThreshold, unitType: $unitType, status: $status, taxPercentage: $taxPercentage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProductModelCopyWith<$Res>  {
  factory $ProductModelCopyWith(ProductModel value, $Res Function(ProductModel) _then) = _$ProductModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId,@JsonKey(name: 'category_id') String? categoryId, CategoryModel? category, String name, String? description, String? sku, String? barcode,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'purchase_price') double purchasePrice,@JsonKey(name: 'selling_price') double sellingPrice, int quantity,@JsonKey(name: 'low_stock_threshold') int lowStockThreshold,@JsonKey(name: 'unit_type') String unitType, String status,@JsonKey(name: 'tax_percentage', defaultValue: 0) double taxPercentage,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});


$CategoryModelCopyWith<$Res>? get category;

}
/// @nodoc
class _$ProductModelCopyWithImpl<$Res>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._self, this._then);

  final ProductModel _self;
  final $Res Function(ProductModel) _then;

/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? categoryId = freezed,Object? category = freezed,Object? name = null,Object? description = freezed,Object? sku = freezed,Object? barcode = freezed,Object? imageUrl = freezed,Object? purchasePrice = null,Object? sellingPrice = null,Object? quantity = null,Object? lowStockThreshold = null,Object? unitType = null,Object? status = null,Object? taxPercentage = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryModel?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as double,sellingPrice: null == sellingPrice ? _self.sellingPrice : sellingPrice // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,lowStockThreshold: null == lowStockThreshold ? _self.lowStockThreshold : lowStockThreshold // ignore: cast_nullable_to_non_nullable
as int,unitType: null == unitType ? _self.unitType : unitType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,taxPercentage: null == taxPercentage ? _self.taxPercentage : taxPercentage // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryModelCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryModelCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProductModel].
extension ProductModelPatterns on ProductModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductModel value)  $default,){
final _that = this;
switch (_that) {
case _ProductModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'category_id')  String? categoryId,  CategoryModel? category,  String name,  String? description,  String? sku,  String? barcode, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'purchase_price')  double purchasePrice, @JsonKey(name: 'selling_price')  double sellingPrice,  int quantity, @JsonKey(name: 'low_stock_threshold')  int lowStockThreshold, @JsonKey(name: 'unit_type')  String unitType,  String status, @JsonKey(name: 'tax_percentage', defaultValue: 0)  double taxPercentage, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that.id,_that.shopId,_that.categoryId,_that.category,_that.name,_that.description,_that.sku,_that.barcode,_that.imageUrl,_that.purchasePrice,_that.sellingPrice,_that.quantity,_that.lowStockThreshold,_that.unitType,_that.status,_that.taxPercentage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'category_id')  String? categoryId,  CategoryModel? category,  String name,  String? description,  String? sku,  String? barcode, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'purchase_price')  double purchasePrice, @JsonKey(name: 'selling_price')  double sellingPrice,  int quantity, @JsonKey(name: 'low_stock_threshold')  int lowStockThreshold, @JsonKey(name: 'unit_type')  String unitType,  String status, @JsonKey(name: 'tax_percentage', defaultValue: 0)  double taxPercentage, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProductModel():
return $default(_that.id,_that.shopId,_that.categoryId,_that.category,_that.name,_that.description,_that.sku,_that.barcode,_that.imageUrl,_that.purchasePrice,_that.sellingPrice,_that.quantity,_that.lowStockThreshold,_that.unitType,_that.status,_that.taxPercentage,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'category_id')  String? categoryId,  CategoryModel? category,  String name,  String? description,  String? sku,  String? barcode, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'purchase_price')  double purchasePrice, @JsonKey(name: 'selling_price')  double sellingPrice,  int quantity, @JsonKey(name: 'low_stock_threshold')  int lowStockThreshold, @JsonKey(name: 'unit_type')  String unitType,  String status, @JsonKey(name: 'tax_percentage', defaultValue: 0)  double taxPercentage, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that.id,_that.shopId,_that.categoryId,_that.category,_that.name,_that.description,_that.sku,_that.barcode,_that.imageUrl,_that.purchasePrice,_that.sellingPrice,_that.quantity,_that.lowStockThreshold,_that.unitType,_that.status,_that.taxPercentage,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductModel implements ProductModel {
  const _ProductModel({required this.id, @JsonKey(name: 'shop_id') required this.shopId, @JsonKey(name: 'category_id') this.categoryId, this.category, required this.name, this.description, this.sku, this.barcode, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'purchase_price') required this.purchasePrice, @JsonKey(name: 'selling_price') required this.sellingPrice, required this.quantity, @JsonKey(name: 'low_stock_threshold') required this.lowStockThreshold, @JsonKey(name: 'unit_type') required this.unitType, required this.status, @JsonKey(name: 'tax_percentage', defaultValue: 0) required this.taxPercentage, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'shop_id') final  String shopId;
@override@JsonKey(name: 'category_id') final  String? categoryId;
@override final  CategoryModel? category;
@override final  String name;
@override final  String? description;
@override final  String? sku;
@override final  String? barcode;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey(name: 'purchase_price') final  double purchasePrice;
@override@JsonKey(name: 'selling_price') final  double sellingPrice;
@override final  int quantity;
@override@JsonKey(name: 'low_stock_threshold') final  int lowStockThreshold;
@override@JsonKey(name: 'unit_type') final  String unitType;
@override final  String status;
@override@JsonKey(name: 'tax_percentage', defaultValue: 0) final  double taxPercentage;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductModelCopyWith<_ProductModel> get copyWith => __$ProductModelCopyWithImpl<_ProductModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.category, category) || other.category == category)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.sellingPrice, sellingPrice) || other.sellingPrice == sellingPrice)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.lowStockThreshold, lowStockThreshold) || other.lowStockThreshold == lowStockThreshold)&&(identical(other.unitType, unitType) || other.unitType == unitType)&&(identical(other.status, status) || other.status == status)&&(identical(other.taxPercentage, taxPercentage) || other.taxPercentage == taxPercentage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,categoryId,category,name,description,sku,barcode,imageUrl,purchasePrice,sellingPrice,quantity,lowStockThreshold,unitType,status,taxPercentage,createdAt,updatedAt);

@override
String toString() {
  return 'ProductModel(id: $id, shopId: $shopId, categoryId: $categoryId, category: $category, name: $name, description: $description, sku: $sku, barcode: $barcode, imageUrl: $imageUrl, purchasePrice: $purchasePrice, sellingPrice: $sellingPrice, quantity: $quantity, lowStockThreshold: $lowStockThreshold, unitType: $unitType, status: $status, taxPercentage: $taxPercentage, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductModelCopyWith<$Res> implements $ProductModelCopyWith<$Res> {
  factory _$ProductModelCopyWith(_ProductModel value, $Res Function(_ProductModel) _then) = __$ProductModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId,@JsonKey(name: 'category_id') String? categoryId, CategoryModel? category, String name, String? description, String? sku, String? barcode,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'purchase_price') double purchasePrice,@JsonKey(name: 'selling_price') double sellingPrice, int quantity,@JsonKey(name: 'low_stock_threshold') int lowStockThreshold,@JsonKey(name: 'unit_type') String unitType, String status,@JsonKey(name: 'tax_percentage', defaultValue: 0) double taxPercentage,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});


@override $CategoryModelCopyWith<$Res>? get category;

}
/// @nodoc
class __$ProductModelCopyWithImpl<$Res>
    implements _$ProductModelCopyWith<$Res> {
  __$ProductModelCopyWithImpl(this._self, this._then);

  final _ProductModel _self;
  final $Res Function(_ProductModel) _then;

/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? categoryId = freezed,Object? category = freezed,Object? name = null,Object? description = freezed,Object? sku = freezed,Object? barcode = freezed,Object? imageUrl = freezed,Object? purchasePrice = null,Object? sellingPrice = null,Object? quantity = null,Object? lowStockThreshold = null,Object? unitType = null,Object? status = null,Object? taxPercentage = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ProductModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryModel?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as double,sellingPrice: null == sellingPrice ? _self.sellingPrice : sellingPrice // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,lowStockThreshold: null == lowStockThreshold ? _self.lowStockThreshold : lowStockThreshold // ignore: cast_nullable_to_non_nullable
as int,unitType: null == unitType ? _self.unitType : unitType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,taxPercentage: null == taxPercentage ? _self.taxPercentage : taxPercentage // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryModelCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryModelCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}

// dart format on
