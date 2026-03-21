package com.ridepulse.backend.service;

// ============================================================
// ComplaintService.java — interface
// OOP Abstraction: defines the complaint contract for all roles.
//     Controllers depend only on this interface.
// ============================================================

import com.ridepulse.backend.dto.*;
import java.util.List;
import java.util.UUID;

public interface ComplaintService {

    // ── Passenger operations ─────────────────────────────────

    /** Passenger submits a new complaint */
    ComplaintDetailDTO submitComplaint(SubmitComplaintRequest request, UUID passengerId);

    /** Passenger views all their own complaints, with authority feedback */
    List<ComplaintSummaryDTO> getMyComplaints(UUID passengerId);

    /** Passenger views full detail of one complaint — includes feedback */
    ComplaintDetailDTO getComplaintDetail(Integer complaintId, UUID passengerId);

    // ── Authority operations ─────────────────────────────────

    /**
     * Authority views all complaints.
     * Polymorphism: both status and category are optional filters.
     * Pass null to skip that filter.
     */
    List<ComplaintSummaryDTO> getAllComplaints(String status, String category);

    /** Authority views full detail of any complaint */
    ComplaintDetailDTO getComplaintDetailForAuthority(Integer complaintId);

    /**
     * Authority makes a decision: resolve / reject / mark under_review.
     * Writes resolutionNote (internal) + authorityFeedback (shown to passenger).
     */
    ComplaintDetailDTO makeDecision(AuthorityDecisionRequest request, UUID authorityUserId);

    /** Authority dashboard stats */
    ComplaintStatsDTO getStats();
}
