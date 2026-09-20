import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/features/auth/domain/auth_state.dart';
import 'package:storemate/features/auth/data/models/user_model.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';
import 'package:storemate/core/permissions/permission_service.dart';
import 'package:storemate/features/auth/presentation/screens/splash_screen.dart';
import 'package:storemate/features/auth/presentation/screens/login_screen.dart';
import 'package:storemate/features/auth/presentation/screens/otp_screen.dart';
import 'package:storemate/features/shop/presentation/screens/shop_registration_screen.dart';
import 'package:storemate/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:storemate/features/category/data/models/category_model.dart';
import 'package:storemate/features/category/presentation/screens/category_list_screen.dart';
import 'package:storemate/features/category/presentation/screens/category_form_screen.dart';
import 'package:storemate/features/product/data/models/product_model.dart';
import 'package:storemate/features/product/presentation/screens/product_list_screen.dart';
import 'package:storemate/features/product/presentation/screens/product_form_screen.dart';
import 'package:storemate/features/product/presentation/screens/product_details_screen.dart';
import 'package:storemate/features/product/presentation/screens/barcode_scanner_screen.dart';
import 'package:storemate/features/product/presentation/screens/bulk_import_screen.dart';
import 'package:storemate/features/inventory/presentation/screens/stock_in_screen.dart';
import 'package:storemate/features/customer/presentation/screens/customer_list_screen.dart';
import 'package:storemate/features/customer/presentation/screens/customer_form_screen.dart';
import 'package:storemate/features/sales/presentation/screens/invoice_list_screen.dart';
import 'package:storemate/features/sales/presentation/screens/pos_screen.dart';
import 'package:storemate/features/sales/presentation/screens/sale_success_screen.dart';
import 'package:storemate/features/sales/presentation/screens/sales_history_screen.dart';
import 'package:storemate/features/sales/presentation/screens/invoice_details_screen.dart';
import 'package:storemate/features/sales/presentation/screens/refund_screen.dart';
import 'package:storemate/features/reports/presentation/screens/reports_screen.dart';
import 'package:storemate/features/settings/presentation/screens/settings_screen.dart';
import 'package:storemate/features/settings/presentation/screens/backup_screen.dart';
import 'package:storemate/features/settings/presentation/screens/printer_settings_screen.dart';
import 'package:storemate/features/staff/presentation/screens/staff_list_screen.dart';
import 'package:storemate/features/staff/presentation/screens/add_edit_staff_screen.dart';
import 'package:storemate/core/layout/main_layout.dart';

/// GoRouter configuration with auth-based redirects.
///
/// Navigation flow:
///   /splash → checks auth → /login or /dashboard or /register-shop
///   /login → enter phone → /otp
///   /otp → verify OTP → /register-shop (new user) or /dashboard (existing)
///   /register-shop → submit → /dashboard
///   /dashboard → main app
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final currentPath = state.matchedLocation;
      final status = ref.read(authProvider).status;

      // Allow splash screen to always load (handles its own redirect)
      if (currentPath == '/splash') return null;

      // If unauthenticated, redirect to login (except if already on login/otp)
      if (status == AuthStatus.unauthenticated) {
        if (currentPath == '/login' || currentPath == '/otp') return null;
        return '/login';
      }

      // If authenticated but needs onboarding, redirect to shop registration
      if (status == AuthStatus.onboardingRequired) {
        if (currentPath == '/register-shop') return null;
        return '/register-shop';
      }

      // If authenticated with shop, redirect away from auth screens
      if (status == AuthStatus.authenticated) {
        final permissions = PermissionService(ref.read(authProvider).user);

        if (currentPath == '/login' ||
            currentPath == '/otp' ||
            currentPath == '/register-shop') {
          return permissions.canAccessDashboard ? '/dashboard' : '/invoices';
        }

        // Route guards based on permissions
        if (currentPath == '/dashboard' && !permissions.canAccessDashboard) {
          return '/invoices';
        }
        if (currentPath.startsWith('/scan') && !permissions.canAccessScan) {
          return '/invoices';
        }
        if ((currentPath.startsWith('/products') || currentPath.startsWith('/stock-in')) && !permissions.canAccessStock) {
          return '/invoices';
        }
        if (currentPath.startsWith('/reports') && !permissions.canAccessReports) {
          return '/invoices';
        }
        if (currentPath.startsWith('/staff') && !permissions.canAccessStaff) {
          return '/invoices';
        }
        if (currentPath.startsWith('/settings') && !permissions.canAccessSettings) {
          return '/invoices';
        }

        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return OtpScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: '/register-shop',
        name: 'register-shop',
        builder: (context, state) => const ShopRegistrationScreen(),
      ),
      // StatefulShellRoute for bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Branch 1: Scan
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scan',
                name: 'scanner',
                builder: (context, state) => const BarcodeScannerScreen(),
              ),
            ],
          ),
          // Branch 2: Stock
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                name: 'products',
                builder: (context, state) => const ProductListScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'products-add',
                    builder: (context, state) {
                      final extra = state.extra;
                      String? barcode;
                      Map<String, dynamic>? prefillData;
                      if (extra != null && extra is Map) {
                        if (extra.containsKey('barcode')) {
                          barcode = extra['barcode'] as String?;
                        }
                        if (extra.containsKey('prefill') && extra['prefill'] is Map) {
                          prefillData = Map<String, dynamic>.from(extra['prefill'] as Map);
                        }
                      }
                      return ProductFormScreen(
                        initialBarcode: barcode,
                        prefillData: prefillData,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'edit',
                    name: 'products-edit',
                    builder: (context, state) {
                      final product = state.extra as ProductModel;
                      return ProductFormScreen(product: product);
                    },
                  ),
                  GoRoute(
                    path: 'details',
                    name: 'products-details',
                    builder: (context, state) {
                      final product = state.extra as ProductModel;
                      return ProductDetailsScreen(product: product);
                    },
                  ),
                  GoRoute(
                    path: 'import',
                    name: 'products-import',
                    builder: (context, state) => const BulkImportScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Branch 3: Invoices
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/invoices',
                name: 'invoices',
                builder: (context, state) => const InvoiceListScreen(),
              ),
            ],
          ),
          // Branch 4: Reports
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                name: 'reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          // Branch 5: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'printer',
                    name: 'settings-printer',
                    builder: (context, state) => const PrinterSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Other top-level routes preserved exactly as they were
      GoRoute(
        path: '/pos',
        name: 'pos',
        builder: (context, state) => const POSScreen(),
        routes: [
          GoRoute(
            path: 'scan',
            name: 'pos-scan',
            builder: (context, state) => const BarcodeScannerScreen(returnToPos: true),
          ),
        ],
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoryListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'categories-add',
            builder: (context, state) => const CategoryFormScreen(),
          ),
          GoRoute(
            path: 'edit',
            name: 'categories-edit',
            builder: (context, state) {
              final category = state.extra as CategoryModel;
              return CategoryFormScreen(category: category);
            },
          ),
        ]
      ),
      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) => const CustomerListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'customer-create',
            builder: (context, state) => const CustomerFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'customer-edit',
            builder: (context, state) {
              final customer = state.extra as dynamic;
              return CustomerFormScreen(customer: customer);
            },
          ),
        ]
      ),
      GoRoute(
        path: '/stock-in',
        name: 'stock-in',
        builder: (context, state) => const StockInScreen(),
      ),
      GoRoute(
        path: '/sales',
        name: 'sales',
        builder: (context, state) => const SalesHistoryScreen(),
        routes: [
          GoRoute(
            path: 'success/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return SaleSuccessScreen(saleId: id);
            },
          ),
          GoRoute(
            path: ':id',
            name: 'invoice-details',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return InvoiceDetailsScreen(saleId: id);
            },
            routes: [
              GoRoute(
                path: 'refund',
                name: 'sales-refund',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return RefundScreen(saleId: id);
                },
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/backups',
        name: 'backups',
        builder: (context, state) => const BackupScreen(),
      ),
      GoRoute(
        path: '/staff',
        name: 'staff-list',
        builder: (context, state) => const StaffListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'staff-add',
            builder: (context, state) => const AddEditStaffScreen(),
          ),
          GoRoute(
            path: 'edit',
            name: 'staff-edit',
            builder: (context, state) {
              final staff = state.extra as UserModel;
              return AddEditStaffScreen(staff: staff);
            },
          ),
        ],
      ),
    ],
  );
});
