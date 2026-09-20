import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:storemate/features/auth/data/models/user_model.dart';

class StaffRepository {
  final SupabaseClient _supabase;

  StaffRepository(this._supabase);

  Future<List<UserModel>> getStaff(String shopId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('shop_id', shopId);
      
      return (response as List).map((json) {
        return UserModel(
          id: json['id'] as String,
          mobileNumber: (json['mobile_number'] as String?) ?? '',
          role: (json['role'] as String?) ?? 'staff',
          shopId: json['shop_id'] as String?,
          lastLoginAt: json['last_login_at'] != null ? DateTime.parse(json['last_login_at'] as String) : null,
          createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
          isActive: json['is_active'] as bool? ?? true,
          isInvited: json['firebase_uid'] == null,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load staff: $e');
    }
  }

  Future<UserModel> inviteStaff({
    required String shopId,
    required String mobileNumber,
    required String role,
  }) async {
    try {
      final response = await _supabase.rpc('rpc_invite_staff', params: {
        'p_shop_id': shopId,
        'p_mobile_number': mobileNumber,
        'p_role': role,
      });
      
      // Fetch the created user
      final userResponse = await _supabase
          .from('users')
          .select()
          .eq('id', response)
          .single();
          
      return UserModel(
        id: userResponse['id'] as String,
        mobileNumber: (userResponse['mobile_number'] as String?) ?? '',
        role: (userResponse['role'] as String?) ?? 'staff',
        shopId: userResponse['shop_id'] as String?,
        lastLoginAt: userResponse['last_login_at'] != null ? DateTime.parse(userResponse['last_login_at'] as String) : null,
        createdAt: userResponse['created_at'] != null ? DateTime.parse(userResponse['created_at'] as String) : null,
        isActive: userResponse['is_active'] as bool? ?? true,
        isInvited: userResponse['firebase_uid'] == null,
      );
    } catch (e) {
      throw Exception('Failed to invite staff: $e');
    }
  }

  Future<void> updateStaff({
    required String id,
    String? role,
    bool? isActive,
  }) async {
    try {
      await _supabase.rpc('rpc_update_staff', params: {
        'p_target_user_id': id,
        'p_new_role': role,
        'p_is_active': isActive,
      });
    } catch (e) {
      throw Exception('Failed to update staff: $e');
    }
  }
}
