// ============================================================
// core/models/complaint_models.dart
// ============================================================

class ComplaintSummary {
  final int     complaintId;
  final String  passengerName;
  final String  busNumber;
  final String  category;
  final String  description;
  final String? photoUrl;
  final String  priority;
  final String  status;
  final String? authorityFeedback;
  final String  submittedAt;
  final String? resolvedAt;

  ComplaintSummary({
    required this.complaintId,
    required this.passengerName,
    required this.busNumber,
    required this.category,
    required this.description,
    this.photoUrl,
    required this.priority,
    required this.status,
    this.authorityFeedback,
    required this.submittedAt,
    this.resolvedAt,
  });

  factory ComplaintSummary.fromJson(Map<String, dynamic> j) => ComplaintSummary(
    complaintId:       j['complaintId'],
    passengerName:     j['passengerName']     ?? '',
    busNumber:         j['busNumber']         ?? 'N/A',
    category:          j['category']          ?? '',
    description:       j['description']       ?? '',
    photoUrl:          j['photoUrl'],
    priority:          j['priority']          ?? 'medium',
    status:            j['status']            ?? 'submitted',
    authorityFeedback: j['authorityFeedback'],
    submittedAt:       j['submittedAt']       ?? '',
    resolvedAt:        j['resolvedAt'],
  );

  // Encapsulation: display helpers live on the model
  bool get isResolved  => status == 'resolved';
  bool get isRejected  => status == 'rejected';
  bool get hasFeedback => authorityFeedback != null && authorityFeedback!.isNotEmpty;
}

class ComplaintDetail {
  final int     complaintId;
  final String  passengerName;
  final String? passengerPhone;
  final String  busNumber;
  final String  routeName;
  final String  category;
  final String  description;
  final String? photoUrl;
  final String  priority;
  final String  status;
  final String? resolutionNote;
  final String? authorityFeedback;
  final String  assignedToName;
  final String  submittedAt;
  final String? resolvedAt;

  ComplaintDetail({
    required this.complaintId,
    required this.passengerName,
    this.passengerPhone,
    required this.busNumber,
    required this.routeName,
    required this.category,
    required this.description,
    this.photoUrl,
    required this.priority,
    required this.status,
    this.resolutionNote,
    this.authorityFeedback,
    required this.assignedToName,
    required this.submittedAt,
    this.resolvedAt,
  });

  factory ComplaintDetail.fromJson(Map<String, dynamic> j) => ComplaintDetail(
    complaintId:       j['complaintId'],
    passengerName:     j['passengerName']     ?? '',
    passengerPhone:    j['passengerPhone'],
    busNumber:         j['busNumber']         ?? 'N/A',
    routeName:         j['routeName']         ?? 'N/A',
    category:          j['category']          ?? '',
    description:       j['description']       ?? '',
    photoUrl:          j['photoUrl'],
    priority:          j['priority']          ?? 'medium',
    status:            j['status']            ?? 'submitted',
    resolutionNote:    j['resolutionNote'],
    authorityFeedback: j['authorityFeedback'],
    assignedToName:    j['assignedToName']     ?? 'Unassigned',
    submittedAt:       j['submittedAt']        ?? '',
    resolvedAt:        j['resolvedAt'],
  );
}

class ComplaintStats {
  final int totalComplaints;
  final int submitted;
  final int underReview;
  final int resolved;
  final int rejected;
  final int crowdingCount;
  final int driverBehaviorCount;
  final int delayCount;
  final int cleanlinessCount;
  final int safetyCount;
  final int otherCount;

  ComplaintStats({
    required this.totalComplaints,
    required this.submitted,
    required this.underReview,
    required this.resolved,
    required this.rejected,
    required this.crowdingCount,
    required this.driverBehaviorCount,
    required this.delayCount,
    required this.cleanlinessCount,
    required this.safetyCount,
    required this.otherCount,
  });

  factory ComplaintStats.fromJson(Map<String, dynamic> j) => ComplaintStats(
    totalComplaints:     (j['totalComplaints']     as num?)?.toInt() ?? 0,
    submitted:           (j['submitted']           as num?)?.toInt() ?? 0,
    underReview:         (j['underReview']         as num?)?.toInt() ?? 0,
    resolved:            (j['resolved']            as num?)?.toInt() ?? 0,
    rejected:            (j['rejected']            as num?)?.toInt() ?? 0,
    crowdingCount:       (j['crowdingCount']       as num?)?.toInt() ?? 0,
    driverBehaviorCount: (j['driverBehaviorCount'] as num?)?.toInt() ?? 0,
    delayCount:          (j['delayCount']          as num?)?.toInt() ?? 0,
    cleanlinessCount:    (j['cleanlinessCount']    as num?)?.toInt() ?? 0,
    safetyCount:         (j['safetyCount']         as num?)?.toInt() ?? 0,
    otherCount:          (j['otherCount']          as num?)?.toInt() ?? 0,
  );
}
