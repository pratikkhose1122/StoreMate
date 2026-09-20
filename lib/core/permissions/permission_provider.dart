import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';
import 'package:storemate/core/permissions/permission_service.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  final user = ref.watch(authProvider).user;
  return PermissionService(user);
});
