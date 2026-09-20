enum AppPermission {
  manageStaff,
  manageSettings,
  manageProducts,
  viewReports,
  manageCustomers,
  posCheckout,
}

class PermissionUtils {
  static const Map<String, List<AppPermission>> _rolePermissions = {
    'owner': [
      AppPermission.manageStaff,
      AppPermission.manageSettings,
      AppPermission.manageProducts,
      AppPermission.viewReports,
      AppPermission.manageCustomers,
      AppPermission.posCheckout,
    ],
    'manager': [
      AppPermission.manageProducts,
      AppPermission.viewReports,
      AppPermission.manageCustomers,
      AppPermission.posCheckout,
    ],
    'cashier': [
      AppPermission.manageCustomers,
      AppPermission.posCheckout,
    ],
  };

  static bool hasPermission(String? role, AppPermission permission) {
    if (role == null) return false;
    final permissions = _rolePermissions[role.toLowerCase()];
    if (permissions == null) return false;
    return permissions.contains(permission);
  }
}
