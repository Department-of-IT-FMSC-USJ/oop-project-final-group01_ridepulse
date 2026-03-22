// ============================================================
// PASSENGER API ADDITIONS
// ADD these providers at the top of api_service.dart
// ADD these methods inside the ApiService class
// ADD imports for passenger models at top of api_service.dart:
//   import '../models/passenger_models.dart';
// ============================================================


// ── PROVIDERS (add after existing providers) ─────────────────

// All routes (browse screen)
final allRoutesProvider =
    FutureProvider.autoDispose<List<RouteSearchResult>>((ref) async {
  return ref.read(apiServiceProvider).getPassengerRoutes();
});

// Route search (updated when query changes)
final routeSearchProvider = FutureProvider.autoDispose
    .family<List<RouteSearchResult>, String>((ref, query) async {
  return ref.read(apiServiceProvider).searchRoutes(query);
});

// Active buses on a route
final activeBusesProvider = FutureProvider.autoDispose
    .family<List<ActiveBus>, int>((ref, routeId) async {
  return ref.read(apiServiceProvider).getActiveBusesOnRoute(routeId);
});

// Single bus live detail
final busLiveDetailProvider = FutureProvider.autoDispose
    .family<BusLiveDetail, int>((ref, busId) async {
  return ref.read(apiServiceProvider).getBusLiveDetail(busId);
});

// Crowd predictions for route on a date
final crowdPredictionProvider = FutureProvider.autoDispose
    .family<RoutePredictionSchedule, ({int routeId, String date})>(
        (ref, params) async {
  return ref.read(apiServiceProvider)
      .getCrowdPredictions(params.routeId, params.date);
});


// ── METHODS (add inside ApiService class) ─────────────────────

  // ── Passenger — Routes ─────────────────────────────────────
  Future<List<RouteSearchResult>> getPassengerRoutes() async {
    final data = await _get('/passenger/routes') as List;
    return data.map((e) => RouteSearchResult.fromJson(e)).toList();
  }

  Future<List<RouteSearchResult>> searchRoutes(String query) async {
    final path = query.trim().isEmpty
        ? '/passenger/routes'
        : '/passenger/routes/search?q=${Uri.encodeComponent(query)}';
    final data = await _get(path) as List;
    return data.map((e) => RouteSearchResult.fromJson(e)).toList();
  }

  // ── Passenger — Live Buses ─────────────────────────────────
  Future<List<ActiveBus>> getActiveBusesOnRoute(int routeId) async {
    final data = await _get('/passenger/routes/$routeId/buses') as List;
    return data.map((e) => ActiveBus.fromJson(e)).toList();
  }

  Future<BusLiveDetail> getBusLiveDetail(int busId) async {
    final data = await _get('/passenger/buses/$busId/live');
    return BusLiveDetail.fromJson(data);
  }

  // ── Passenger — Crowd Prediction ───────────────────────────
  Future<RoutePredictionSchedule> getCrowdPredictions(
      int routeId, String date) async {
    final data = await _get(
        '/passenger/routes/$routeId/predictions?date=$date');
    return RoutePredictionSchedule.fromJson(data);
  }
