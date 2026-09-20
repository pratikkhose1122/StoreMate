import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:decimal/decimal.dart';
import 'package:storemate/core/utils/decimal_converter.dart';

part 'dashboard_summary_model.freezed.dart';
part 'dashboard_summary_model.g.dart';

@freezed
abstract class DashboardSummaryModel with _$DashboardSummaryModel {
  const factory DashboardSummaryModel({
    required int totalProducts,
    required int totalCategories,
    required int lowStockProducts,
    required int outOfStockProducts,
    @DecimalConverter() required Decimal inventoryValue,
    @DecimalConverter() required Decimal todaysSales,
    @DecimalConverter() required Decimal todaysProfit,
    @Default(0) int todaysTransactionCount,
    @Default([]) List<Map<String, dynamic>> recentMovements,
    @Default([]) List<Map<String, dynamic>> recentProducts,
    @Default([]) List<Map<String, dynamic>> lowStockProductsList,
  }) = _DashboardSummaryModel;

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryModelFromJson(json);
}
