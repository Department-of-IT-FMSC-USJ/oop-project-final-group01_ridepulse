// ============================================================
// core/router/app_router.dart
// GoRouter with role-based auth guards
// OOP Polymorphism: redirect logic branches per user role
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../layouts/bus_owner_shell.dart';
import '../layouts/authority_shell.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/passenger/screens/passenger_home_screen.dart';
import '../../features/passenger/screens/passenger_complaint_list_screen.dart';
import '../../features/passenger/screens/passenger_complaint_submit_screen.dart';
import '../../features/passenger/screens/passenger_complaint_detail_screen.dart';
import '../../features/driver/screens/driver_home_screen.dart';
import '../../features/conductor/screens/conductor_home_screen.dart';
import '../../features/bus_owner/screens/dashboard_screen.dart';
import '../../features/bus_owner/screens/bus_management_screen.dart';
import '../../features/bus_owner/screens/staff_list_screen.dart';
import '../../features/bus_owner/screens/register_staff_screen.dart';
import '../../features/bus_owner/screens/staff_profile_screen.dart';
import '../../features/bus_owner/screens/revenue_screen.dart';
import '../../features/bus_owner/screens/welfare_screen.dart';
import '../../features/bus_owner/screens/live_map_screen.dart';
import '../../features/bus_owner/screens/bus_owner_complaints_screen.dart';
import '../../features/authority/screens/authority_dashboard_screen.dart';
import '../../features/authority/screens/authority_complaint_list_screen.dart';
import '../../features/authority/screens/authority_complaint_detail_screen.dart';
import '../../features/authority/screens/authority_prediction_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final auth     = ref.read(authProvider);
      final loggedIn = auth.isLoggedIn;
      final role     = auth.role ?? '';
      final loc      = state.matchedLocation;

      // Public paths — no redirect needed
      const publicPaths = [
        '/login', '/register/passenger',
        '/register/bus-owner', '/register/authority',
      ];
      final isPublic = publicPaths.any((p) => loc.startsWith(p));

      // Not logged in → go to login
      if (!loggedIn && !isPublic) return '/login';

      // Already logged in on a public page → go to role home
      if (loggedIn && isPublic) {
        // Polymorphism: role maps to home screen
        return switch (role) {
          'bus_owner'  => '/bus-owner/dashboard',
          'driver'     => '/driver/home',
          'conductor'  => '/conductor/home',
          'passenger'  => '/passenger/home',
          'authority'  => '/authority/dashboard',
          _            => '/login',
        };
      }

      // Role guards — prevent cross-role access
      if (loc.startsWith('/bus-owner') && role != 'bus_owner')  return '/login';
      if (loc.startsWith('/authority') && role != 'authority')  return '/login';
      if (loc.startsWith('/driver')    && role != 'driver')     return '/login';
      if (loc.startsWith('/conductor') && role != 'conductor')  return '/login';
      if (loc.startsWith('/passenger') && role != 'passenger')  return '/login';

      return null;
    },

    routes: [
      // ── Public ─────────────────────────────────────────────
      GoRoute(path: '/login',
          builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register/passenger',
          builder: (_, __) =>
              const RegisterScreen(type: 'passenger')),
      GoRoute(path: '/register/bus-owner',
          builder: (_, __) =>
              const RegisterScreen(type: 'bus_owner')),
      GoRoute(path: '/register/authority',
          builder: (_, __) =>
              const RegisterScreen(type: 'authority')),

      // ── Passenger (Mobile) ──────────────────────────────────
      GoRoute(path: '/passenger/home',
          builder: (_, __) => const PassengerHomeScreen()),
      GoRoute(path: '/passenger/complaints',
          builder: (_, __) => const PassengerComplaintListScreen()),
      GoRoute(path: '/passenger/complaints/submit',
          builder: (_, __) => const PassengerComplaintSubmitScreen()),
      GoRoute(
        path: '/passenger/complaints/:id',
        builder: (_, state) => PassengerComplaintDetailScreen(
            complaintId: int.parse(state.pathParameters['id']!)),
      ),

      // ── Driver (Mobile) ────────────────────────────────────
      GoRoute(path: '/driver/home',
          builder: (_, __) => const DriverHomeScreen()),

      // ── Conductor (Mobile) ─────────────────────────────────
      GoRoute(
          path: '/conductor/home',
          builder: (_, __) => const ConductorHomeScreen()),
      GoRoute(
          path: '/conductor/trip',
          builder: (_, __) => const ConductorTripScreen()),
      GoRoute(
          path: '/conductor/ticket/issue',
          builder: (_, __) => const ConductorIssueTicketScreen()),
      GoRoute(
          path: '/conductor/roster',
          builder: (_, __) => const ConductorRosterScreen()),
      GoRoute(
          path: '/conductor/welfare',
          builder: (_, __) => const ConductorWelfareScreen()),


      // ── Bus Owner (Web — sidebar shell) ────────────────────
      ShellRoute(
        builder: (_, __, child) => BusOwnerShell(child: child),
        routes: [
          GoRoute(path: '/bus-owner/dashboard',
              builder: (_, __) => const BusOwnerDashboardScreen()),
          GoRoute(path: '/bus-owner/buses',
              builder: (_, __) => const BusManagementScreen()),
          GoRoute(path: '/bus-owner/staff',
              builder: (_, __) => const StaffListScreen()),
          GoRoute(path: '/bus-owner/staff/register',
              builder: (_, __) => const RegisterStaffScreen()),
          GoRoute(
            path: '/bus-owner/staff/:id',
            builder: (_, s) => StaffProfileScreen(
                staffId: int.parse(s.pathParameters['id']!)),
          ),
          GoRoute(path: '/bus-owner/revenue',
              builder: (_, __) => const RevenueScreen()),
          GoRoute(path: '/bus-owner/welfare',
              builder: (_, __) => const WelfareScreen()),
          GoRoute(path: '/bus-owner/live-map',
              builder: (_, __) => const LiveMapScreen()),
          GoRoute(path: '/bus-owner/complaints',
              builder: (_, __) => const BusOwnerComplaintsScreen()),
        ],
      ),

      // ── Authority (Web — sidebar shell) ────────────────────
      ShellRoute(
        builder: (_, __, child) => AuthorityShell(child: child),
        routes: [
          GoRoute(path: '/authority/dashboard',
              builder: (_, __) => const AuthorityDashboardScreen()),
          GoRoute(path: '/authority/complaints',
              builder: (_, __) => const AuthorityComplaintListScreen()),
          GoRoute(
            path: '/authority/complaints/:id',
            builder: (_, s) => AuthorityComplaintDetailScreen(
                complaintId: int.parse(s.pathParameters['id']!)),
          GoRoute(
            path: '/authority/predictions',
            builder: (_, __) => const AuthorityPredictionScreen()),
          ),
        ],
      ),
    ],

    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}
