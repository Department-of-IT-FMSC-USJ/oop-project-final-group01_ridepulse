// ============================================================
// core/models/auth_models.dart
// ============================================================
class AuthResponse {
  final String accessToken;
  final String role;
  final String fullName;
  final String email;
  final int?   ownerId;
  final int?   staffId;

  AuthResponse({
    required this.accessToken,
    required this.role,
    required this.fullName,
    required this.email,
    this.ownerId,
    this.staffId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> j) => AuthResponse(
    accessToken: j['accessToken'] ?? '',
    role:        j['role']        ?? '',
    fullName:    j['fullName']    ?? '',
    email:       j['email']       ?? '',
    ownerId:     j['ownerId'],
    staffId:     j['staffId'],
  );
}
