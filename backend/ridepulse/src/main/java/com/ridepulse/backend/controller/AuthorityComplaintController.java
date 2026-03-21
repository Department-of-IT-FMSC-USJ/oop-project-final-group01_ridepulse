package com.ridepulse.backend.controller;

// ============================================================
// AuthorityComplaintController.java
// REST endpoints for transport authority complaint management.
// OOP Encapsulation: hides ComplaintService internals.
//     Polymorphism: @PreAuthorize restricts to authority role only.
// ============================================================

import com.ridepulse.backend.config.CustomUserDetails;
import com.ridepulse.backend.dto.*;
import com.ridepulse.backend.service.ComplaintService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Handles all complaint operations available to transport authority.
 * OOP: Single Responsibility — only authority complaint endpoints here.
 */
@RestController
@RequestMapping("/api/v1/authority/complaints")
@RequiredArgsConstructor
public class AuthorityComplaintController {

    private final ComplaintService complaintService;   // Abstraction: interface only

    /**
     * GET /api/v1/authority/complaints
     * Authority views all complaints — optionally filtered.
     *
     * Query params:
     *   ?status=submitted|under_review|resolved|rejected  (optional)
     *   ?category=crowding|driver_behavior|delay|cleanliness|safety|other  (optional)
     *
     * Polymorphism: any combination of filters works — null means no filter.
     */
    @GetMapping
    @PreAuthorize("hasRole('authority')")
    public ResponseEntity<List<ComplaintSummaryDTO>> getAllComplaints(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String category) {

        return ResponseEntity.ok(
                complaintService.getAllComplaints(status, category));
    }

    /**
     * GET /api/v1/authority/complaints/stats
     * Authority dashboard — complaint counts by status and category.
     * OOP Abstraction: hides 9 count queries behind one call.
     */
    @GetMapping("/stats")
    @PreAuthorize("hasRole('authority')")
    public ResponseEntity<ComplaintStatsDTO> getStats() {
        return ResponseEntity.ok(complaintService.getStats());
    }

    /**
     * GET /api/v1/authority/complaints/{complaintId}
     * Full detail of a specific complaint — includes internal resolution note.
     */
    @GetMapping("/{complaintId}")
    @PreAuthorize("hasRole('authority')")
    public ResponseEntity<ComplaintDetailDTO> getDetail(
            @PathVariable Integer complaintId) {

        return ResponseEntity.ok(
                complaintService.getComplaintDetailForAuthority(complaintId));
    }

    /**
     * PATCH /api/v1/authority/complaints/decision
     * Authority makes a corrective decision on a complaint.
     *
     * Body: {
     *   complaintId: 5,
     *   action: "resolve",            // resolve | reject | review
     *   resolutionNote: "...",        // internal note
     *   authorityFeedback: "..."      // passenger-visible response
     * }
     *
     * OOP Polymorphism: action drives status transition internally.
     */
    @PatchMapping("/decision")
    @PreAuthorize("hasRole('authority')")
    public ResponseEntity<ComplaintDetailDTO> makeDecision(
            @Valid @RequestBody AuthorityDecisionRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        return ResponseEntity.ok(
                complaintService.makeDecision(request, userDetails.getUserId()));
    }
}
