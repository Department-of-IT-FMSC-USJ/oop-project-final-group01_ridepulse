// ============================================================
// core/services/auth_service.dart
// FIXED: Safe JSON handling + debug logs
// ============================================================
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

const String _base = 'http://localhost:8080/api/v1';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  Map<String, String> get _headers => {
        'Content-Type': 'application/json'
      };

  Future<Map<String, String>> get _authHeaders async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ───────────────── LOGIN ─────────────────
  Future<AuthResponse> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_base/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    _debug(res, "LOGIN");
    _check(res);

    if (res.body.trim().isEmpty) {
      throw Exception("Empty response from login API");
    }

    return AuthResponse.fromJson(jsonDecode(res.body));
  }

  // ───────────────── PASSENGER ─────────────────
  Future<AuthResponse> registerPassenger({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/auth/register/passenger'),
      headers: _headers,
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password
      }),
    );

    _debug(res, "REGISTER PASSENGER");
    _check(res);

    if (res.body.trim().isEmpty) {
      throw Exception("Invalid response from server");
    }

    return AuthResponse.fromJson(jsonDecode(res.body));
  }

  // ───────────────── BUS OWNER ─────────────────
  Future<AuthResponse> registerBusOwner({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String businessName,
    required String nicNumber,
    String? address,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/auth/register/bus-owner'),
      headers: _headers,
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'businessName': businessName,
        'nicNumber': nicNumber,
        'address': address,
      }),
    );

    _debug(res, "REGISTER BUS OWNER");
    _check(res);

    if (res.body.trim().isEmpty) {
      throw Exception("Invalid response from server");
    }

    return AuthResponse.fromJson(jsonDecode(res.body));
  }

  // ───────────────── AUTHORITY ─────────────────
  Future<AuthResponse> registerAuthority({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String designation,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/auth/register/authority'),
      headers: _headers,
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'designation': designation,
      }),
    );

    _debug(res, "REGISTER AUTHORITY");
    _check(res);

    if (res.body.trim().isEmpty) {
      throw Exception("Invalid response from server");
    }

    return AuthResponse.fromJson(jsonDecode(res.body));
  }

  // ───────────────── STAFF (FIXED 🔥) ─────────────────
  Future<void> registerStaff({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String staffType,
    required String employeeId,
    String? licenseNumber,
    double? baseSalary,
    int? busId,
  }) async {
    final headers = await _authHeaders;

    final res = await http.post(
      Uri.parse('$_base/auth/register/staff'),
      headers: headers,
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'staffType': staffType,
        'employeeId': employeeId,
        'licenseNumber': licenseNumber,
        'baseSalary': baseSalary,
        'busId': busId,
      }),
    );

    _debug(res, "REGISTER STAFF");
    _check(res);

    // ✅ IMPORTANT: DO NOT decode (backend returns empty)
    return;
  }

  // ───────────────── SESSION ─────────────────
  Future<void> saveSession(AuthResponse r) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', r.accessToken);
    await prefs.setString('role', r.role);
    await prefs.setString('full_name', r.fullName);
    await prefs.setString('email', r.email);
    if (r.ownerId != null) await prefs.setInt('owner_id', r.ownerId!);
    if (r.staffId != null) await prefs.setInt('staff_id', r.staffId!);
  }

  Future<void> clearSession() async =>
      (await SharedPreferences.getInstance()).clear();

  Future<AuthResponse?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) return null;

    return AuthResponse(
      accessToken: token,
      role: prefs.getString('role') ?? '',
      fullName: prefs.getString('full_name') ?? '',
      email: prefs.getString('email') ?? '',
      ownerId: prefs.getInt('owner_id'),
      staffId: prefs.getInt('staff_id'),
    );
  }

  // ───────────────── ERROR HANDLING ─────────────────
  void _check(http.Response res) {
    if (res.statusCode >= 400) {
      if (res.body.trim().isNotEmpty) {
        try {
          final body = jsonDecode(res.body);
          throw Exception(body['message'] ?? 'Error ${res.statusCode}');
        } catch (_) {
          throw Exception('Error ${res.statusCode}');
        }
      } else {
        throw Exception('Error ${res.statusCode}');
      }
    }
  }

  // ───────────────── DEBUG LOGGER ─────────────────
  void _debug(http.Response res, String tag) {
    print("[$tag] STATUS → ${res.statusCode}");
    print("[$tag] BODY → ${res.body}");
  }
}
