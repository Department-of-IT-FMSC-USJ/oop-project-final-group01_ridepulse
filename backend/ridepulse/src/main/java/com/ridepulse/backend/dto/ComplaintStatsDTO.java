package com.ridepulse.backend.dto;

// ============================================================
// ComplaintStatsDTO.java
// Used by: Authority dashboard summary card
// OOP Abstraction: hides the multiple count queries behind one object
// ============================================================

import lombok.*;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class ComplaintStatsDTO {
    private long totalComplaints;
    private long submitted;
    private long underReview;
    private long resolved;
    private long rejected;

    // Breakdown by category — useful for authority to see patterns
    private long crowdingCount;
    private long driverBehaviorCount;
    private long delayCount;
    private long cleanlinessCount;
    private long safetyCount;
    private long otherCount;
}
