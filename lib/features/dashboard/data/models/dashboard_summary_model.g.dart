// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardSummaryModel _$DashboardSummaryModelFromJson(
  Map<String, dynamic> json,
) => _DashboardSummaryModel(
  totalProducts: (json['totalProducts'] as num).toInt(),
  totalCategories: (json['totalCategories'] as num).toInt(),
  lowStockProducts: (json['lowStockProducts'] as num).toInt(),
  outOfStockProducts: (json['outOfStockProducts'] as num).toInt(),
  inventoryValue: const DecimalConverter().fromJson(json['inventoryValue']),
  todaysSales: const DecimalConverter().fromJson(json['todaysSales']),
  todaysProfit: const DecimalConverter().fromJson(json['todaysProfit']),
  todaysTransactionCount:
      (json['todaysTransactionCount'] as num?)?.toInt() ?? 0,
  recentMovements:
      (json['recentMovements'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  recentProducts:
      (json['recentProducts'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  lowStockProductsList:
      (json['lowStockProductsList'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
);

Map<String, dynamic> _$DashboardSummaryModelToJson(
  _DashboardSummaryModel instance,
) => <String, dynamic>{
  'totalProducts': instance.totalProducts,
  'totalCategories': instance.totalCategories,
  'lowStockProducts': instance.lowStockProducts,
  'outOfStockProducts': instance.outOfStockProducts,
  'inventoryValue': const DecimalConverter().toJson(instance.inventoryValue),
  'todaysSales': const DecimalConverter().toJson(instance.todaysSales),
  'todaysProfit': const DecimalConverter().toJson(instance.todaysProfit),
  'todaysTransactionCount': instance.todaysTransactionCount,
  'recentMovements': instance.recentMovements,
  'recentProducts': instance.recentProducts,
  'lowStockProductsList': instance.lowStockProductsList,
};
