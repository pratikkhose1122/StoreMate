import 'package:dio/dio.dart';
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/features/auth/data/models/user_model.dart';

class StaffRepository {
  final DioClient _apiClient;

  StaffRepository(this._apiClient);

  Future<List<UserModel>> getStaff() async {
    try {
      final response = await _apiClient.get('/staff');
      final data = response.data as List;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load staff');
    }
  }

  Future<UserModel> inviteStaff({
    required String name,
    required String mobileNumber,
    required String role,
  }) async {
    try {
      final response = await _apiClient.post(
        '/staff',
        data: {
          'name': name,
          'mobileNumber': mobileNumber,
          'role': role,
        },
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to invite staff');
    }
  }

  Future<UserModel> updateStaff({
    required String id,
    String? role,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (role != null) data['role'] = role;
      if (isActive != null) data['isActive'] = isActive;

      final response = await _apiClient.put(
        '/staff/$id',
        data: data,
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update staff');
    }
  }
}
