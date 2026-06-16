import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_summary_model.freezed.dart';
part 'dashboard_summary_model.g.dart';

@freezed
abstract class DashboardSummaryModel with _$DashboardSummaryModel {
  const factory DashboardSummaryModel({
    required int totalProducts,
    required int totalCategories,
    required int lowStockProducts,
    required int outOfStockProducts,
    required double inventoryValue,
    @Default(0) double todaysSales,
    @Default(0) double todaysProfit,
    @Default([]) List<Map<String, dynamic>> recentMovements,
    @Default([]) List<Map<String, dynamic>> recentProducts,
    @Default([]) List<Map<String, dynamic>> lowStockProductsList,
  }) = _DashboardSummaryModel;

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryModelFromJson(json);
}
