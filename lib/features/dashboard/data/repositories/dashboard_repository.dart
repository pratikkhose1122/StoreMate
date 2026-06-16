import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/constants/api_constants.dart';
import 'package:storemate/core/providers/core_providers.dart';
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/features/dashboard/data/models/dashboard_summary_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(dioClientProvider));
});

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummaryModel>((ref) async {
  return ref.read(dashboardRepositoryProvider).getSummary();
});

class DashboardRepository {
  final DioClient _dio;

  DashboardRepository(this._dio);

  Future<DashboardSummaryModel> getSummary() async {
    final response = await _dio.get(ApiConstants.dashboardSummary);
    return DashboardSummaryModel.fromJson(response.data['data']);
  }
}
