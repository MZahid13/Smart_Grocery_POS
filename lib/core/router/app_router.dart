import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/dashboard_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/billing/billing_screen.dart';
import '../../features/billing/barcode_scanner_screen.dart';
import '../../features/customers/customers_screen.dart';
import '../../features/suppliers/suppliers_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/widgets/home_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    routes: [
      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/scan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BarcodeScannerScreen(),
      ),
      GoRoute(
        path: '/customers',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CustomersScreen(),
      ),
      GoRoute(
        path: '/suppliers',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SuppliersScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/billing',
                builder: (context, state) => const BillingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
