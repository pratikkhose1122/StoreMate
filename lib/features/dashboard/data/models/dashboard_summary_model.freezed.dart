// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardSummaryModel {

 int get totalProducts; int get totalCategories; int get lowStockProducts; int get outOfStockProducts; double get inventoryValue; double get todaysSales; double get todaysProfit; List<Map<String, dynamic>> get recentMovements; List<Map<String, dynamic>> get recentProducts; List<Map<String, dynamic>> get lowStockProductsList;
/// Create a copy of DashboardSummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSummaryModelCopyWith<DashboardSummaryModel> get copyWith => _$DashboardSummaryModelCopyWithImpl<DashboardSummaryModel>(this as DashboardSummaryModel, _$identity);

  /// Serializes this DashboardSummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSummaryModel&&(identical(other.totalProducts, totalProducts) || other.totalProducts == totalProducts)&&(identical(other.totalCategories, totalCategories) || other.totalCategories == totalCategories)&&(identical(other.lowStockProducts, lowStockProducts) || other.lowStockProducts == lowStockProducts)&&(identical(other.outOfStockProducts, outOfStockProducts) || other.outOfStockProducts == outOfStockProducts)&&(identical(other.inventoryValue, inventoryValue) || other.inventoryValue == inventoryValue)&&(identical(other.todaysSales, todaysSales) || other.todaysSales == todaysSales)&&(identical(other.todaysProfit, todaysProfit) || other.todaysProfit == todaysProfit)&&const DeepCollectionEquality().equals(other.recentMovements, recentMovements)&&const DeepCollectionEquality().equals(other.recentProducts, recentProducts)&&const DeepCollectionEquality().equals(other.lowStockProductsList, lowStockProductsList));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalProducts,totalCategories,lowStockProducts,outOfStockProducts,inventoryValue,todaysSales,todaysProfit,const DeepCollectionEquality().hash(recentMovements),const DeepCollectionEquality().hash(recentProducts),const DeepCollectionEquality().hash(lowStockProductsList));

@override
String toString() {
  return 'DashboardSummaryModel(totalProducts: $totalProducts, totalCategories: $totalCategories, lowStockProducts: $lowStockProducts, outOfStockProducts: $outOfStockProducts, inventoryValue: $inventoryValue, todaysSales: $todaysSales, todaysProfit: $todaysProfit, recentMovements: $recentMovements, recentProducts: $recentProducts, lowStockProductsList: $lowStockProductsList)';
}


}

/// @nodoc
abstract mixin class $DashboardSummaryModelCopyWith<$Res>  {
  factory $DashboardSummaryModelCopyWith(DashboardSummaryModel value, $Res Function(DashboardSummaryModel) _then) = _$DashboardSummaryModelCopyWithImpl;
@useResult
$Res call({
 int totalProducts, int totalCategories, int lowStockProducts, int outOfStockProducts, double inventoryValue, double todaysSales, double todaysProfit, List<Map<String, dynamic>> recentMovements, List<Map<String, dynamic>> recentProducts, List<Map<String, dynamic>> lowStockProductsList
});




}
/// @nodoc
class _$DashboardSummaryModelCopyWithImpl<$Res>
    implements $DashboardSummaryModelCopyWith<$Res> {
  _$DashboardSummaryModelCopyWithImpl(this._self, this._then);

  final DashboardSummaryModel _self;
  final $Res Function(DashboardSummaryModel) _then;

/// Create a copy of DashboardSummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalProducts = null,Object? totalCategories = null,Object? lowStockProducts = null,Object? outOfStockProducts = null,Object? inventoryValue = null,Object? todaysSales = null,Object? todaysProfit = null,Object? recentMovements = null,Object? recentProducts = null,Object? lowStockProductsList = null,}) {
  return _then(_self.copyWith(
totalProducts: null == totalProducts ? _self.totalProducts : totalProducts // ignore: cast_nullable_to_non_nullable
as int,totalCategories: null == totalCategories ? _self.totalCategories : totalCategories // ignore: cast_nullable_to_non_nullable
as int,lowStockProducts: null == lowStockProducts ? _self.lowStockProducts : lowStockProducts // ignore: cast_nullable_to_non_nullable
as int,outOfStockProducts: null == outOfStockProducts ? _self.outOfStockProducts : outOfStockProducts // ignore: cast_nullable_to_non_nullable
as int,inventoryValue: null == inventoryValue ? _self.inventoryValue : inventoryValue // ignore: cast_nullable_to_non_nullable
as double,todaysSales: null == todaysSales ? _self.todaysSales : todaysSales // ignore: cast_nullable_to_non_nullable
as double,todaysProfit: null == todaysProfit ? _self.todaysProfit : todaysProfit // ignore: cast_nullable_to_non_nullable
as double,recentMovements: null == recentMovements ? _self.recentMovements : recentMovements // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,recentProducts: null == recentProducts ? _self.recentProducts : recentProducts // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,lowStockProductsList: null == lowStockProductsList ? _self.lowStockProductsList : lowStockProductsList // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardSummaryModel].
extension DashboardSummaryModelPatterns on DashboardSummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardSummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardSummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardSummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _DashboardSummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardSummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardSummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalProducts,  int totalCategories,  int lowStockProducts,  int outOfStockProducts,  double inventoryValue,  double todaysSales,  double todaysProfit,  List<Map<String, dynamic>> recentMovements,  List<Map<String, dynamic>> recentProducts,  List<Map<String, dynamic>> lowStockProductsList)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSummaryModel() when $default != null:
return $default(_that.totalProducts,_that.totalCategories,_that.lowStockProducts,_that.outOfStockProducts,_that.inventoryValue,_that.todaysSales,_that.todaysProfit,_that.recentMovements,_that.recentProducts,_that.lowStockProductsList);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalProducts,  int totalCategories,  int lowStockProducts,  int outOfStockProducts,  double inventoryValue,  double todaysSales,  double todaysProfit,  List<Map<String, dynamic>> recentMovements,  List<Map<String, dynamic>> recentProducts,  List<Map<String, dynamic>> lowStockProductsList)  $default,) {final _that = this;
switch (_that) {
case _DashboardSummaryModel():
return $default(_that.totalProducts,_that.totalCategories,_that.lowStockProducts,_that.outOfStockProducts,_that.inventoryValue,_that.todaysSales,_that.todaysProfit,_that.recentMovements,_that.recentProducts,_that.lowStockProductsList);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalProducts,  int totalCategories,  int lowStockProducts,  int outOfStockProducts,  double inventoryValue,  double todaysSales,  double todaysProfit,  List<Map<String, dynamic>> recentMovements,  List<Map<String, dynamic>> recentProducts,  List<Map<String, dynamic>> lowStockProductsList)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSummaryModel() when $default != null:
return $default(_that.totalProducts,_that.totalCategories,_that.lowStockProducts,_that.outOfStockProducts,_that.inventoryValue,_that.todaysSales,_that.todaysProfit,_that.recentMovements,_that.recentProducts,_that.lowStockProductsList);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardSummaryModel implements DashboardSummaryModel {
  const _DashboardSummaryModel({required this.totalProducts, required this.totalCategories, required this.lowStockProducts, required this.outOfStockProducts, required this.inventoryValue, this.todaysSales = 0, this.todaysProfit = 0, final  List<Map<String, dynamic>> recentMovements = const [], final  List<Map<String, dynamic>> recentProducts = const [], final  List<Map<String, dynamic>> lowStockProductsList = const []}): _recentMovements = recentMovements,_recentProducts = recentProducts,_lowStockProductsList = lowStockProductsList;
  factory _DashboardSummaryModel.fromJson(Map<String, dynamic> json) => _$DashboardSummaryModelFromJson(json);

@override final  int totalProducts;
@override final  int totalCategories;
@override final  int lowStockProducts;
@override final  int outOfStockProducts;
@override final  double inventoryValue;
@override@JsonKey() final  double todaysSales;
@override@JsonKey() final  double todaysProfit;
 final  List<Map<String, dynamic>> _recentMovements;
@override@JsonKey() List<Map<String, dynamic>> get recentMovements {
  if (_recentMovements is EqualUnmodifiableListView) return _recentMovements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentMovements);
}

 final  List<Map<String, dynamic>> _recentProducts;
@override@JsonKey() List<Map<String, dynamic>> get recentProducts {
  if (_recentProducts is EqualUnmodifiableListView) return _recentProducts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentProducts);
}

 final  List<Map<String, dynamic>> _lowStockProductsList;
@override@JsonKey() List<Map<String, dynamic>> get lowStockProductsList {
  if (_lowStockProductsList is EqualUnmodifiableListView) return _lowStockProductsList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lowStockProductsList);
}


/// Create a copy of DashboardSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardSummaryModelCopyWith<_DashboardSummaryModel> get copyWith => __$DashboardSummaryModelCopyWithImpl<_DashboardSummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardSummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSummaryModel&&(identical(other.totalProducts, totalProducts) || other.totalProducts == totalProducts)&&(identical(other.totalCategories, totalCategories) || other.totalCategories == totalCategories)&&(identical(other.lowStockProducts, lowStockProducts) || other.lowStockProducts == lowStockProducts)&&(identical(other.outOfStockProducts, outOfStockProducts) || other.outOfStockProducts == outOfStockProducts)&&(identical(other.inventoryValue, inventoryValue) || other.inventoryValue == inventoryValue)&&(identical(other.todaysSales, todaysSales) || other.todaysSales == todaysSales)&&(identical(other.todaysProfit, todaysProfit) || other.todaysProfit == todaysProfit)&&const DeepCollectionEquality().equals(other._recentMovements, _recentMovements)&&const DeepCollectionEquality().equals(other._recentProducts, _recentProducts)&&const DeepCollectionEquality().equals(other._lowStockProductsList, _lowStockProductsList));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalProducts,totalCategories,lowStockProducts,outOfStockProducts,inventoryValue,todaysSales,todaysProfit,const DeepCollectionEquality().hash(_recentMovements),const DeepCollectionEquality().hash(_recentProducts),const DeepCollectionEquality().hash(_lowStockProductsList));

@override
String toString() {
  return 'DashboardSummaryModel(totalProducts: $totalProducts, totalCategories: $totalCategories, lowStockProducts: $lowStockProducts, outOfStockProducts: $outOfStockProducts, inventoryValue: $inventoryValue, todaysSales: $todaysSales, todaysProfit: $todaysProfit, recentMovements: $recentMovements, recentProducts: $recentProducts, lowStockProductsList: $lowStockProductsList)';
}


}

/// @nodoc
abstract mixin class _$DashboardSummaryModelCopyWith<$Res> implements $DashboardSummaryModelCopyWith<$Res> {
  factory _$DashboardSummaryModelCopyWith(_DashboardSummaryModel value, $Res Function(_DashboardSummaryModel) _then) = __$DashboardSummaryModelCopyWithImpl;
@override @useResult
$Res call({
 int totalProducts, int totalCategories, int lowStockProducts, int outOfStockProducts, double inventoryValue, double todaysSales, double todaysProfit, List<Map<String, dynamic>> recentMovements, List<Map<String, dynamic>> recentProducts, List<Map<String, dynamic>> lowStockProductsList
});




}
/// @nodoc
class __$DashboardSummaryModelCopyWithImpl<$Res>
    implements _$DashboardSummaryModelCopyWith<$Res> {
  __$DashboardSummaryModelCopyWithImpl(this._self, this._then);

  final _DashboardSummaryModel _self;
  final $Res Function(_DashboardSummaryModel) _then;

/// Create a copy of DashboardSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalProducts = null,Object? totalCategories = null,Object? lowStockProducts = null,Object? outOfStockProducts = null,Object? inventoryValue = null,Object? todaysSales = null,Object? todaysProfit = null,Object? recentMovements = null,Object? recentProducts = null,Object? lowStockProductsList = null,}) {
  return _then(_DashboardSummaryModel(
totalProducts: null == totalProducts ? _self.totalProducts : totalProducts // ignore: cast_nullable_to_non_nullable
as int,totalCategories: null == totalCategories ? _self.totalCategories : totalCategories // ignore: cast_nullable_to_non_nullable
as int,lowStockProducts: null == lowStockProducts ? _self.lowStockProducts : lowStockProducts // ignore: cast_nullable_to_non_nullable
as int,outOfStockProducts: null == outOfStockProducts ? _self.outOfStockProducts : outOfStockProducts // ignore: cast_nullable_to_non_nullable
as int,inventoryValue: null == inventoryValue ? _self.inventoryValue : inventoryValue // ignore: cast_nullable_to_non_nullable
as double,todaysSales: null == todaysSales ? _self.todaysSales : todaysSales // ignore: cast_nullable_to_non_nullable
as double,todaysProfit: null == todaysProfit ? _self.todaysProfit : todaysProfit // ignore: cast_nullable_to_non_nullable
as double,recentMovements: null == recentMovements ? _self._recentMovements : recentMovements // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,recentProducts: null == recentProducts ? _self._recentProducts : recentProducts // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,lowStockProductsList: null == lowStockProductsList ? _self._lowStockProductsList : lowStockProductsList // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}


}

// dart format on
