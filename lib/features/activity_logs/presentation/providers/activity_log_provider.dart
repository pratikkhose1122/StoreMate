import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/core/providers/core_providers.dart';
import '../../data/models/activity_log_model.dart';

class ActivityLogRepository {
  final DioClient _apiClient;

  ActivityLogRepository(this._apiClient);

  Future<List<ActivityLogModel>> getRecentActivity({int limit = 10}) async {
    try {
      final response = await _apiClient.get('/activity-logs/recent', queryParameters: {'limit': limit});
      final responseData = response.data;
      final data = (responseData is Map && responseData.containsKey('data')) ? responseData['data'] : responseData;
      return (data as List).map((json) => ActivityLogModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load activity logs');
    }
  }
}

final activityLogRepositoryProvider = Provider<ActivityLogRepository>((ref) {
  return ActivityLogRepository(ref.watch(dioClientProvider));
});

final recentActivityProvider = FutureProvider.autoDispose<List<ActivityLogModel>>((ref) async {
  return ref.watch(activityLogRepositoryProvider).getRecentActivity(limit: 5);
});
