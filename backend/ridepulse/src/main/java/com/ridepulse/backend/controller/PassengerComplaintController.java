package com.ridepulse.backend.controller;

// ============================================================
// PassengerComplaintController.java
// REST endpoints for passenger complaint operations.
// OOP Encapsulation: controller exposes clean HTTP API.
//     delegates all logic to ComplaintService.
// ============================================================

import com.ridepulse.backend.config.CustomUserDetails;
import com.ridepulse.backend.dto.*;
import com.ridepulse.backend.service.ComplaintService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Handles all complaint operations available to passengers.
 * OOP: Single Responsibility — only passenger complaint endpoints here.
 */
@RestController
@RequestMapping("/api/v1/complaints")
@RequiredArgsConstructor
public class PassengerComplaintController {

    private final ComplaintService complaintService;   // Abstraction: interface only

    /**
     * POST /api/v1/complaints
     * Passenger submits a new complaint.
     *
     * Body: { busId?, tripId?, category, description, photoUrl? }
     * Returns: full complaint detail with assigned priority and status="submitted"
     */
    @PostMapping
    @PreAuthorize("hasRole('passenger')")
    public ResponseEntity<ComplaintDetailDTO> submitComplaint(
            @Valid @RequestBody SubmitComplaintRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        ComplaintDetailDTO result = complaintService
                .submitComplaint(request, userDetails.getUserId());

        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

    /**
     * GET /api/v1/complaints/my
     * Passenger views all their complaints.
     * Each item includes authorityFeedback — null until authority responds.
     */
    @GetMapping("/my")
    @PreAuthorize("hasRole('passenger')")
    public ResponseEntity<List<ComplaintSummaryDTO>> getMyComplaints(
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        return ResponseEntity.ok(
                complaintService.getMyComplaints(userDetails.getUserId()));
    }

    /**
     * GET /api/v1/complaints/{complaintId}
     * Passenger views full detail of one complaint.
     * Includes authority_feedback once the authority has responded.
     */
    @GetMapping("/{complaintId}")
    @PreAuthorize("hasRole('passenger')")
    public ResponseEntity<ComplaintDetailDTO> getComplaintDetail(
            @PathVariable Integer complaintId,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        return ResponseEntity.ok(
                complaintService.getComplaintDetail(
                        complaintId, userDetails.getUserId()));
    }
}
