import 'package:storemate/features/auth/data/models/user_model.dart';

class PermissionService {
  final UserModel? user;

  PermissionService(this.user);

  String get _role => (user?.role ?? '').toUpperCase();

  bool get isOwner => _role == 'OWNER';
  bool get isManager => _role == 'MANAGER';
  bool get isCashier => _role == 'CASHIER' || _role == 'STAFF';

  bool get canAccessDashboard => isOwner || isManager || isCashier;
  bool get canAccessScan => isOwner || isManager || isCashier;
  bool get canAccessStock => isOwner || isManager;
  bool get canAccessProducts => isOwner || isManager;
  bool get canAccessReports => isOwner || isManager;
  bool get canAccessSettings => isOwner;
  bool get canAccessStaff => isOwner;
  
  bool get canAccessPOS => true;
  bool get canAccessCustomers => true;
}
