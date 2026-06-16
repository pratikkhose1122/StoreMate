export enum Role {
  OWNER = 'owner',
  MANAGER = 'manager',
  CASHIER = 'cashier',
}

export enum Permission {
  MANAGE_STAFF = 'MANAGE_STAFF',
  MANAGE_SETTINGS = 'MANAGE_SETTINGS',
  MANAGE_PRODUCTS = 'MANAGE_PRODUCTS',
  VIEW_REPORTS = 'VIEW_REPORTS',
  MANAGE_CUSTOMERS = 'MANAGE_CUSTOMERS',
  POS_CHECKOUT = 'POS_CHECKOUT',
}

export const RolePermissions: Record<Role, Permission[]> = {
  [Role.OWNER]: [
    Permission.MANAGE_STAFF,
    Permission.MANAGE_SETTINGS,
    Permission.MANAGE_PRODUCTS,
    Permission.VIEW_REPORTS,
    Permission.MANAGE_CUSTOMERS,
    Permission.POS_CHECKOUT,
  ],
  [Role.MANAGER]: [
    Permission.MANAGE_PRODUCTS,
    Permission.VIEW_REPORTS,
    Permission.MANAGE_CUSTOMERS,
    Permission.POS_CHECKOUT,
  ],
  [Role.CASHIER]: [
    Permission.MANAGE_CUSTOMERS,
    Permission.POS_CHECKOUT,
  ],
};
