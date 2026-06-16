enum AppPermission {
  MANAGE_STAFF,
  MANAGE_SETTINGS,
  MANAGE_PRODUCTS,
  VIEW_REPORTS,
  MANAGE_CUSTOMERS,
  POS_CHECKOUT,
}

class PermissionUtils {
  static const Map<String, List<AppPermission>> _rolePermissions = {
    'owner': [
      AppPermission.MANAGE_STAFF,
      AppPermission.MANAGE_SETTINGS,
      AppPermission.MANAGE_PRODUCTS,
      AppPermission.VIEW_REPORTS,
      AppPermission.MANAGE_CUSTOMERS,
      AppPermission.POS_CHECKOUT,
    ],
    'manager': [
      AppPermission.MANAGE_PRODUCTS,
      AppPermission.VIEW_REPORTS,
      AppPermission.MANAGE_CUSTOMERS,
      AppPermission.POS_CHECKOUT,
    ],
    'cashier': [
      AppPermission.MANAGE_CUSTOMERS,
      AppPermission.POS_CHECKOUT,
    ],
  };

  static bool hasPermission(String? role, AppPermission permission) {
    if (role == null) return false;
    final permissions = _rolePermissions[role.toLowerCase()];
    if (permissions == null) return false;
    return permissions.contains(permission);
  }
}
