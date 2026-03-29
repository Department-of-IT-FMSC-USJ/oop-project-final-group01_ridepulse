// ============================================================
// core/models/driver_models.dart
// Driver reuses RosterModel, TripModel, ConductorWelfareModel
//     from conductor_models.dart.
// Driver-specific: EmergencyAlertModel, DriverDashboardModel
// ============================================================
import 'conductor_models.dart';

class EmergencyAlertModel {
  final int     alertId;
  final String  busNumber;
  final String  routeName;
  final String  alertType;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String  status;
  final String  createdAt;

  EmergencyAlertModel({
    required this.alertId,    required this.busNumber,
    required this.routeName,  required this.alertType,
    this.description,         this.latitude,
    this.longitude,           required this.status,
    required this.createdAt,
  });

  factory EmergencyAlertModel.fromJson(Map<String, dynamic> j) =>
      EmergencyAlertModel(
    alertId:     j["alertId"],
    busNumber:   j["busNumber"]   ?? "",
    routeName:   j["routeName"]   ?? "",
    alertType:   j["alertType"]   ?? "",
    description: j["description"],
    latitude:    (j["latitude"]   as num?)?.toDouble(),
    longitude:   (j["longitude"]  as num?)?.toDouble(),
    status:      j["status"]      ?? "active",
    createdAt:   j["createdAt"]   ?? "",
  );

  // Polymorphism: status drives UI colour/label
  bool get isActive     => status == "active";
  bool get isResolved   => status == "resolved";
  bool get isAcknowledged => status == "acknowledged";
}


class DriverDashboardModel {
  final String         driverName;
  final String         employeeId;
  final String?        licenseNumber;
  final String?        licenseExpiry;
  final int            staffId;
  final RosterModel?   todayRoster;
  final TripModel?     activeTrip;
  final int            dutyDaysThisMonth;
  final double         welfareThisMonth;
  final double         totalWelfareBalance;
  final EmergencyAlertModel? activeAlert;

  DriverDashboardModel({
    required this.driverName,       required this.employeeId,
    this.licenseNumber,             this.licenseExpiry,
    required this.staffId,          this.todayRoster,
    this.activeTrip,                required this.dutyDaysThisMonth,
    required this.welfareThisMonth, required this.totalWelfareBalance,
    this.activeAlert,
  });

  factory DriverDashboardModel.fromJson(Map<String, dynamic> j) =>
      DriverDashboardModel(
    driverName:         j["driverName"]         ?? "",
    employeeId:         j["employeeId"]         ?? "",
    licenseNumber:      j["licenseNumber"],
    licenseExpiry:      j["licenseExpiry"],
    staffId:            j["staffId"],
    todayRoster: j["todayRoster"] != null
        ? RosterModel.fromJson(j["todayRoster"]) : null,
    activeTrip:  j["activeTrip"] != null
        ? TripModel.fromJson(j["activeTrip"]) : null,
    dutyDaysThisMonth:  (j["dutyDaysThisMonth"]  as num?)?.toInt()    ?? 0,
    welfareThisMonth:   (j["welfareThisMonth"]   as num?)?.toDouble() ?? 0,
    totalWelfareBalance:(j["totalWelfareBalance"] as num?)?.toDouble() ?? 0,
    activeAlert: j["activeAlert"] != null
        ? EmergencyAlertModel.fromJson(j["activeAlert"]) : null,
  );
}
