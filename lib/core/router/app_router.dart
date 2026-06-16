import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/features/auth/domain/auth_state.dart';
import 'package:storemate/features/auth/data/models/user_model.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';
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
import 'package:storemate/features/sales/presentation/screens/pos_screen.dart';
import 'package:storemate/features/sales/presentation/screens/cart_screen.dart';
import 'package:storemate/features/sales/presentation/screens/checkout_screen.dart';
import 'package:storemate/features/sales/presentation/screens/sales_history_screen.dart';
import 'package:storemate/features/sales/presentation/screens/invoice_details_screen.dart';
import 'package:storemate/features/reports/presentation/screens/reports_screen.dart';
import 'package:storemate/features/settings/presentation/screens/settings_screen.dart';
import 'package:storemate/features/settings/presentation/screens/backup_screen.dart';
import 'package:storemate/features/staff/presentation/screens/staff_list_screen.dart';
import 'package:storemate/features/staff/presentation/screens/add_edit_staff_screen.dart';
/// GoRouter configuration with auth-based redirects.
///
/// Navigation flow:
///   /splash → checks auth → /login or /dashboard or /register-shop
///   /login → enter phone → /otp
///   /otp → verify OTP → /register-shop (new user) or /dashboard (existing)
///   /register-shop → submit → /dashboard
///   /dashboard → main app
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final currentPath = state.matchedLocation;
      final status = authState.status;

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
        if (currentPath == '/login' ||
            currentPath == '/otp' ||
            currentPath == '/register-shop') {
          return '/dashboard';
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
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
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
              if (extra != null && extra is Map && extra.containsKey('barcode')) {
                barcode = extra['barcode'] as String;
              }
              return ProductFormScreen(initialBarcode: barcode);
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
            path: 'scanner',
            name: 'scanner',
            builder: (context, state) => const BarcodeScannerScreen(),
          ),
          GoRoute(
            path: 'import',
            name: 'products-import',
            builder: (context, state) => const BulkImportScreen(),
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
        path: '/pos',
        name: 'pos',
        builder: (context, state) => const POSScreen(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/sales',
        name: 'sales-history',
        builder: (context, state) => const SalesHistoryScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'invoice-details',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return InvoiceDetailsScreen(saleId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
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
