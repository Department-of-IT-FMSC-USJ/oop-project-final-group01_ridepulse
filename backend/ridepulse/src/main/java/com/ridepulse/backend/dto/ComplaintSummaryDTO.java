package com.ridepulse.backend.dto;

// ============================================================
// ComplaintSummaryDTO.java  — updated with authorityFeedback
// Used by: list views across all three roles
// OOP Encapsulation: passenger sees their feedback, authority
//     sees all fields, bus owner sees their bus's complaints
// ============================================================

import lombok.*;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class ComplaintSummaryDTO {
    private Integer complaintId;
    private String  passengerName;
    private String  busNumber;
    private String  category;
    private String  description;
    private String  photoUrl;
    private String  priority;
    private String  status;
    private String  authorityFeedback;  // NEW: passenger sees this as response
    private String  submittedAt;
    private String  resolvedAt;
}
