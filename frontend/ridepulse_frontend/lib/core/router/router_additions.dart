import '../../features/passenger/screens/passenger_home_screen.dart';
import '../../features/passenger/screens/passenger_search_screen.dart';
import '../../features/passenger/screens/passenger_route_detail_screen.dart';
import '../../features/passenger/screens/passenger_bus_live_screen.dart';
import '../../features/passenger/screens/passenger_crowd_prediction_screen.dart';
import '../../features/passenger/screens/passenger_complaint_list_screen.dart';
import '../../features/passenger/screens/passenger_complaint_submit_screen.dart';
import '../../features/passenger/screens/passenger_complaint_detail_screen.dart';


// ── REPLACE the existing passenger route block ────────────────
// Find:
//   GoRoute(path: '/passenger/home',  builder: ...),
//   GoRoute(path: '/passenger/complaints', ...),
//   GoRoute(path: '/passenger/complaints/submit', ...),
//   GoRoute(path: '/passenger/complaints/:id', ...),
//
// REPLACE WITH:

      // ── Passenger (Mobile) ─────────────────────────────────
      GoRoute(
        path: '/passenger/home',
        builder: (_, __) => const PassengerHomeScreen()),

      GoRoute(
        path: '/passenger/search',
        builder: (_, __) => const PassengerSearchScreen()),

      GoRoute(
        path: '/passenger/routes/:routeId',
        builder: (_, s) => PassengerRouteDetailScreen(
            routeId: int.parse(s.pathParameters['routeId']!))),

      GoRoute(
        path: '/passenger/buses/:busId/live',
        builder: (_, s) => PassengerBusLiveScreen(
            busId: int.parse(s.pathParameters['busId']!))),

      GoRoute(
        path: '/passenger/routes/:routeId/prediction',
        builder: (_, s) => PassengerCrowdPredictionScreen(
            routeId: int.parse(s.pathParameters['routeId']!))),

      // Complaint routes (existing — keep these)
      GoRoute(
        path: '/passenger/complaints',
        builder: (_, __) => const PassengerComplaintListScreen()),
      GoRoute(
        path: '/passenger/complaints/submit',
        builder: (_, __) => const PassengerComplaintSubmitScreen()),
      GoRoute(
        path: '/passenger/complaints/:id',
        builder: (_, s) => PassengerComplaintDetailScreen(
            complaintId: int.parse(s.pathParameters['id']!))),
