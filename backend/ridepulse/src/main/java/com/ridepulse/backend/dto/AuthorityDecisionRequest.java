package com.ridepulse.backend.dto;

// ============================================================
// AuthorityDecisionRequest.java
// Used by: Authority when resolving or rejecting a complaint
// OOP Polymorphism: action field drives the status transition
// ============================================================

import jakarta.validation.constraints.*;
import lombok.*;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class AuthorityDecisionRequest {

    @NotNull(message = "Complaint ID is required")
    private Integer complaintId;

    // Polymorphism: action determines status transition
    // "resolve"  → status = "resolved"
    // "reject"   → status = "rejected"
    // "review"   → status = "under_review"
    @NotBlank(message = "Action is required")
    @Pattern(
            regexp = "resolve|reject|review",
            message = "Action must be resolve, reject, or review"
    )
    private String action;

    // Corrective action taken — internal note (not shown to passenger)
    @NotBlank(message = "Resolution note is required")
    private String resolutionNote;

    // Feedback visible to the passenger — what was decided and what happens next
    @NotBlank(message = "Passenger feedback is required")
    private String authorityFeedback;
}
