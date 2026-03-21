package com.ridepulse.backend.dto;

// ============================================================
// ComplaintDetailDTO.java
// Full detail view — used by both Passenger and Authority
// OOP Encapsulation: authority_feedback is always included so
//     passenger can read the response without extra call
// ============================================================

import lombok.*;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class ComplaintDetailDTO {

    private Integer complaintId;

    // Passenger info (shown to authority, hidden for passenger's own view)
    private String  passengerName;
    private String  passengerPhone;

    // Bus / trip context
    private String  busNumber;
    private String  routeName;
    private Integer tripId;

    // Complaint content
    private String  category;
    private String  description;
    private String  photoUrl;
    private String  priority;

    // Lifecycle
    private String  status;       // submitted | under_review | resolved | rejected
    private String  submittedAt;

    // Authority resolution — null until authority acts
    private String  resolutionNote;      // internal note (authority only)
    private String  authorityFeedback;   // shown to passenger as response
    private String  assignedToName;      // which authority officer is handling
    private String  resolvedAt;
}
