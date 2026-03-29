// ============================================================
// core/services/api_service.dart
// OOP Encapsulation: all authenticated API calls + Riverpod providers
// ============================================================
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bus_models.dart';
import '../models/complaint_models.dart';

import '../models/authority_models.dart';


const String _base = 'http://localhost:8080/api/v1';

final authorityDashboardStatsProvider =
    FutureProvider.autoDispose<AuthorityDashboardStats>((ref) async {
  return ref.read(apiServiceProvider).getAuthorityDashboardStats();
});

final authorityBusesProvider =
    FutureProvider.autoDispose<List<AuthorityBus>>((ref) async {
  return ref.read(apiServiceProvider).getAuthorityBuses();
});

final authorityDriversProvider =
    FutureProvider.autoDispose<List<AuthorityStaff>>((ref) async {
  return ref.read(apiServiceProvider).getAuthorityDrivers();
});

final authorityConductorsProvider =
    FutureProvider.autoDispose<List<AuthorityStaff>>((ref) async {
  return ref.read(apiServiceProvider).getAuthorityConductors();
});

final authorityOwnersProvider =
    FutureProvider.autoDispose<List<AuthorityOwner>>((ref) async {
  return ref.read(apiServiceProvider).getAuthorityOwners();
});

final authorityFaresProvider =
    FutureProvider.autoDispose<List<FareConfig>>((ref) async {
  return ref.read(apiServiceProvider).getAuthorityFares();
});



// ── ApiService class ─────────────────────────────────────────

class ApiService {
  Future<Map<String, String>> get _headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _get(String path) async {
    final res = await http.get(Uri.parse('$_base$path'),
        headers: await _headers);
    _check(res);
    return jsonDecode(res.body);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('$_base$path'),
        headers: await _headers, body: jsonEncode(body));
    _check(res);
    return jsonDecode(res.body);
  }

  Future<dynamic> _patch(String path, Map<String, dynamic> body) async {
    final res = await http.patch(Uri.parse('$_base$path'),
        headers: await _headers, body: jsonEncode(body));
    _check(res);
    return jsonDecode(res.body);
  }

  Future<dynamic> _delete(String path) async {
    final res = await http.delete(Uri.parse('$_base$path'),
        headers: await _headers);
    _check(res);
    return jsonDecode(res.body);
  }

  void _check(http.Response res) {
    if (res.statusCode >= 400) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Error ${res.statusCode}');
    }
  }

  // ── Routes ────────────────────────────────────────────────
  Future<List<RouteModel>> getRoutes() async {
    final data = await _get('/routes') as List;
    return data.map((e) => RouteModel.fromJson(e)).toList();
  }

  // ── Bus Owner — Buses ─────────────────────────────────────
  Future<List<BusModel>> getBuses() async {
    final data = await _get('/bus-owner/buses') as List;
    return data.map((e) => BusModel.fromJson(e)).toList();
  }

  Future<BusModel> addBus({
    required String busNumber,
    required String registrationNumber,
    required int routeId,
    required int capacity,
    String? model,
  }) async {
    final data = await _post('/bus-owner/buses', {
      'busNumber': busNumber,
      'registrationNumber': registrationNumber,
      'routeId': routeId,
      'capacity': capacity,
      'model': model,
    });
    return BusModel.fromJson(data);
  }

  Future<void> deleteBus(int busId) async {
    await _delete('/bus-owner/buses/$busId');
  }

  Future<BusModel> updateBusRoute(int busId, int routeId) async {
    final data = await _patch(
        '/bus-owner/buses/route', {'busId': busId, 'routeId': routeId});
    return BusModel.fromJson(data);
  }

  // ── Bus Owner — Staff ─────────────────────────────────────
  Future<List<StaffModel>> getStaff({String? staffType}) async {
    final data = await _get('/bus-owner/staff') as List;
    final all = data.map((e) => StaffModel.fromJson(e)).toList();
    if (staffType == null) return all;
    return all.where((s) => s.staffType == staffType).toList();
  }

  Future<void> toggleStaffStatus(int staffId, bool isActive) async {
    await _patch('/bus-owner/staff/toggle-status',
        {'staffId': staffId, 'isActive': isActive});
  }

  Future<void> updateSalary(int staffId, double salary) async {
    await _patch('/bus-owner/staff/salary',
        {'staffId': staffId, 'baseSalary': salary});
  }

  Future<void> assignStaffToBus(int staffId, int busId) async {
    await _post('/bus-owner/staff/assign', {
      'staffId': staffId,
      'busId': busId,
      'assignedDate': DateTime.now().toIso8601String().split('T')[0],
    });
  }

  // ── Bus Owner — Revenue ───────────────────────────────────
  Future<List<MonthlyRevenueModel>> getMonthlyRevenue(
      {required int month, required int year}) async {
    final data =
        await _get('/bus-owner/revenue/monthly?month=$month&year=$year') as List;
    return data.map((e) => MonthlyRevenueModel.fromJson(e)).toList();
  }

  Future<void> recordFuelExpense(
      {required int busId,
      required String date,
      required double amount}) async {
    await _post('/bus-owner/revenue/fuel',
        {'busId': busId, 'expenseDate': date, 'fuelAmount': amount});
  }

  Future<void> setMaintenanceConfig(int busId, double amount) async {
    await _patch('/bus-owner/revenue/maintenance-config',
        {'busId': busId, 'monthlyAmount': amount});
  }

  Future<List<StaffModel>> getWelfareSummary(
      {required int month, required int year}) async {
    final data = await _get(
        '/bus-owner/revenue/welfare?month=$month&year=$year') as List;
    return data.map((e) => StaffModel.fromJson(e)).toList();
  }

  // ── Bus Owner — Dashboard / Map ───────────────────────────
  Future<List<BusLocationModel>> getLiveBusLocations() async {
    final data =
        await _get('/bus-owner/dashboard/live-locations') as List;
    return data.map((e) => BusLocationModel.fromJson(e)).toList();
  }

  Future<List<ComplaintSummary>> getBusOwnerComplaints(
      {String status = 'all'}) async {
    final data =
        await _get('/bus-owner/dashboard/complaints?status=$status') as List;
    return data.map((e) => ComplaintSummary.fromJson(e)).toList();
  }

  // ── Passenger — Complaints ────────────────────────────────
  Future<ComplaintDetail> submitComplaint({
    int? busId,
    int? tripId,
    required String category,
    required String description,
    String? photoUrl,
  }) async {
    final data = await _post('/complaints', {
      'busId': busId,
      'tripId': tripId,
      'category': category,
      'description': description,
      'photoUrl': photoUrl,
    });
    return ComplaintDetail.fromJson(data);
  }

  Future<List<ComplaintSummary>> getMyComplaints() async {
    final data = await _get('/complaints/my') as List;
    return data.map((e) => ComplaintSummary.fromJson(e)).toList();
  }

  Future<ComplaintDetail> getComplaintDetail(int id) async {
    final data = await _get('/complaints/$id');
    return ComplaintDetail.fromJson(data);
  }

  // ── Authority — Complaints ────────────────────────────────
  Future<List<ComplaintSummary>> getAuthorityComplaints(
      {String? status, String? category}) async {
    var path = '/authority/complaints';
    final params = <String>[];
    if (status   != null) params.add('status=$status');
    if (category != null) params.add('category=$category');
    if (params.isNotEmpty) path += '?${params.join('&')}';
    final data = await _get(path) as List;
    return data.map((e) => ComplaintSummary.fromJson(e)).toList();
  }

  Future<ComplaintStats> getComplaintStats() async {
    final data = await _get('/authority/complaints/stats');
    return ComplaintStats.fromJson(data);
  }

  Future<ComplaintDetail> makeComplaintDecision({
    required int complaintId,
    required String action,
    required String resolutionNote,
    required String authorityFeedback,
  }) async {
    final data = await _patch('/authority/complaints/decision', {
      'complaintId':      complaintId,
      'action':           action,
      'resolutionNote':   resolutionNote,
      'authorityFeedback': authorityFeedback,
    });
    return ComplaintDetail.fromJson(data);
  }
}

// ── Authority — Dashboard ──────────────────────────────────
  Future<AuthorityDashboardStats> getAuthorityDashboardStats() async {
    final data = await _get('/authority/dashboard/stats');
    return AuthorityDashboardStats.fromJson(data);
  }

  // ── Authority — Buses ──────────────────────────────────────
  Future<List<AuthorityBus>> getAuthorityBuses() async {
    final data = await _get('/authority/buses') as List;
    return data.map((e) => AuthorityBus.fromJson(e)).toList();
  }

  // ── Authority — Staff ──────────────────────────────────────
  Future<List<AuthorityStaff>> getAuthorityDrivers() async {
    final data = await _get('/authority/staff/drivers') as List;
    return data.map((e) => AuthorityStaff.fromJson(e)).toList();
  }

  Future<List<AuthorityStaff>> getAuthorityConductors() async {
    final data = await _get('/authority/staff/conductors') as List;
    return data.map((e) => AuthorityStaff.fromJson(e)).toList();
  }

  // ── Authority — Owners ─────────────────────────────────────
  Future<List<AuthorityOwner>> getAuthorityOwners() async {
    final data = await _get('/authority/owners') as List;
    return data.map((e) => AuthorityOwner.fromJson(e)).toList();
  }

  // ── Authority — Fares ──────────────────────────────────────
  Future<List<FareConfig>> getAuthorityFares() async {
    final data = await _get('/authority/fares') as List;
    return data.map((e) => FareConfig.fromJson(e)).toList();
  }

  Future<FareConfig> getAuthorityFare(int routeId) async {
    final data = await _get('/authority/fares/$routeId');
    return FareConfig.fromJson(data);
  }

  Future<FareConfig> updateFare(int routeId, double baseFare) async {
    final data = await _patch('/authority/fares',
        {'routeId': routeId, 'baseFare': baseFare});
    return FareConfig.fromJson(data);
  }

