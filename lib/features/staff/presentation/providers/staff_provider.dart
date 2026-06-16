import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/providers/core_providers.dart';
import 'package:storemate/features/auth/data/models/user_model.dart';
import '../../data/repositories/staff_repository.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  final apiClient = ref.watch(dioClientProvider);
  return StaffRepository(apiClient);
});

final staffListProvider = FutureProvider.autoDispose<List<UserModel>>((ref) async {
  final repository = ref.watch(staffRepositoryProvider);
  return repository.getStaff();
});

class StaffNotifier extends StateNotifier<AsyncValue<void>> {
  final StaffRepository _repository;
  final Ref _ref;

  StaffNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> inviteStaff({
    required String name,
    required String mobileNumber,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.inviteStaff(name: name, mobileNumber: mobileNumber, role: role);
      state = const AsyncValue.data(null);
      _ref.invalidate(staffListProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStaff({
    required String id,
    String? role,
    bool? isActive,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateStaff(id: id, role: role, isActive: isActive);
      state = const AsyncValue.data(null);
      _ref.invalidate(staffListProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final staffNotifierProvider = StateNotifierProvider<StaffNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(staffRepositoryProvider);
  return StaffNotifier(repository, ref);
});
