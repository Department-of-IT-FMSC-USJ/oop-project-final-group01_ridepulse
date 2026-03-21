package com.ridepulse.backend.service.impl;


// ============================================================
// ComplaintServiceImpl.java
// OOP Encapsulation: all complaint logic is hidden here.
//     Polymorphism: makeDecision() resolves the new status
//     from the action string — callers never switch on status.
//     Abstraction: getStats() hides 7 separate count queries.
// ============================================================

import com.ridepulse.backend.dto.*;
import com.ridepulse.backend.entity.*;
import com.ridepulse.backend.repository.*;
import com.ridepulse.backend.service.ComplaintService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ComplaintServiceImpl implements ComplaintService {

    // Encapsulation: all dependencies are private and injected
    private final ComplaintRepository complaintRepo;
    private final UserRepository      userRepo;
    private final BusRepository       busRepo;
    private final BusTripRepository   tripRepo;

    private static final DateTimeFormatter FMT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    // ── Passenger operations ─────────────────────────────────

    /**
     * Passenger submits a new complaint.
     * OOP Encapsulation: complaint entity is built and saved here —
     * the controller just passes the request and gets back a DTO.
     */
    @Override
    @Transactional
    public ComplaintDetailDTO submitComplaint(
            SubmitComplaintRequest req, UUID passengerId) {

        User passenger = userRepo.findById(passengerId)
                .orElseThrow(() -> new RuntimeException("Passenger not found"));

        // Resolve optional associations
        Bus bus = req.getBusId() != null
                ? busRepo.findById(req.getBusId()).orElse(null)
                : null;

        BusTrip trip = req.getTripId() != null
                ? tripRepo.findById(req.getTripId()).orElse(null)
                : null;

        // Auto-assign priority based on category — Polymorphism
        String priority = resolvePriority(req.getCategory());

        Complaint complaint = Complaint.builder()
                .passenger(passenger)
                .bus(bus)
                .trip(trip)
                .category(req.getCategory())
                .description(req.getDescription())
                .photoUrl(req.getPhotoUrl())
                .priority(priority)
                .status("submitted")
                .submittedAt(LocalDateTime.now())
                .build();

        complaintRepo.save(complaint);
        return toDetailDTO(complaint, false);
    }

    /** Returns all complaints the passenger filed, with authority feedback. */
    @Override
    public List<ComplaintSummaryDTO> getMyComplaints(UUID passengerId) {
        return complaintRepo
                .findByPassenger_UserIdOrderBySubmittedAtDesc(passengerId)
                .stream()
                .map(c -> toSummaryDTO(c))
                .collect(Collectors.toList());
    }

    /**
     * Passenger views detail of their own complaint.
     * Security: validates the complaint belongs to this passenger.
     */
    @Override
    public ComplaintDetailDTO getComplaintDetail(
            Integer complaintId, UUID passengerId) {

        Complaint c = findComplaint(complaintId);

        // Security: passenger can only view their own complaints
        if (!c.getPassenger().getUserId().equals(passengerId)) {
            throw new RuntimeException("Access denied");
        }
        return toDetailDTO(c, false);  // false = hide resolutionNote from passenger
    }

    // ── Authority operations ─────────────────────────────────

    /**
     * Authority views all complaints, optionally filtered.
     * OOP Polymorphism: filter combination handled without caller needing
     * to know which query method is invoked.
     */
    @Override
    public List<ComplaintSummaryDTO> getAllComplaints(
            String status, String category) {

        List<Complaint> complaints;

        // Polymorphism: query selection driven by which filters are present
        if (status != null && category != null) {
            complaints = complaintRepo
                    .findByStatusAndCategoryOrderBySubmittedAtDesc(status, category);
        } else if (status != null) {
            complaints = complaintRepo.findByStatusOrderBySubmittedAtDesc(status);
        } else if (category != null) {
            complaints = complaintRepo.findByCategoryOrderBySubmittedAtDesc(category);
        } else {
            complaints = complaintRepo.findAllByOrderBySubmittedAtDesc();
        }

        return complaints.stream()
                .map(c -> toSummaryDTO(c))
                .collect(Collectors.toList());
    }

    /** Authority sees full detail including internal resolution note. */
    @Override
    public ComplaintDetailDTO getComplaintDetailForAuthority(Integer complaintId) {
        return toDetailDTO(findComplaint(complaintId), true); // true = show resolutionNote
    }

    /**
     * Authority makes a decision on a complaint.
     * OOP Polymorphism: action string resolves to the correct status transition.
     * The passenger's authorityFeedback is set here — they read it on their end.
     */
    @Override
    @Transactional
    public ComplaintDetailDTO makeDecision(
            AuthorityDecisionRequest req, UUID authorityUserId) {

        Complaint complaint = findComplaint(req.getComplaintId());

        User authority = userRepo.findById(authorityUserId)
                .orElseThrow(() -> new RuntimeException("Authority user not found"));

        // Polymorphism: action → status mapping (Encapsulation: callers don't set status directly)
        String newStatus = switch (req.getAction()) {
            case "resolve" -> "resolved";
            case "reject"  -> "rejected";
            case "review"  -> "under_review";
            default        -> throw new RuntimeException("Invalid action: " + req.getAction());
        };

        // Encapsulation: all mutation goes through the entity
        complaint.setStatus(newStatus);
        complaint.setResolutionNote(req.getResolutionNote());
        complaint.setAuthorityFeedback(req.getAuthorityFeedback()); // passenger reads this
        complaint.setAssignedTo(authority);

        if ("resolved".equals(newStatus) || "rejected".equals(newStatus)) {
            complaint.setResolvedAt(LocalDateTime.now());
        }

        complaintRepo.save(complaint);
        return toDetailDTO(complaint, true);
    }

    /**
     * Authority dashboard statistics.
     * OOP Abstraction: hides 9 separate count queries.
     */
    @Override
    public ComplaintStatsDTO getStats() {
        return ComplaintStatsDTO.builder()
                .totalComplaints(complaintRepo.count())
                .submitted(complaintRepo.countByStatus("submitted"))
                .underReview(complaintRepo.countByStatus("under_review"))
                .resolved(complaintRepo.countByStatus("resolved"))
                .rejected(complaintRepo.countByStatus("rejected"))
                .crowdingCount(complaintRepo.countByCategory("crowding"))
                .driverBehaviorCount(complaintRepo.countByCategory("driver_behavior"))
                .delayCount(complaintRepo.countByCategory("delay"))
                .cleanlinessCount(complaintRepo.countByCategory("cleanliness"))
                .safetyCount(complaintRepo.countByCategory("safety"))
                .otherCount(complaintRepo.countByCategory("other"))
                .build();
    }

    // ── Private helpers (Encapsulation: hidden from all callers) ─────────

    private Complaint findComplaint(Integer id) {
        return complaintRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Complaint not found: " + id));
    }

    /**
     * Polymorphism: safety complaints get high priority automatically,
     * driver_behavior gets medium, delay/crowding get low.
     */
    private String resolvePriority(String category) {
        return switch (category) {
            case "safety"           -> "high";
            case "driver_behavior"  -> "high";
            case "delay"            -> "medium";
            case "crowding"         -> "medium";
            default                 -> "low";
        };
    }

    private ComplaintSummaryDTO toSummaryDTO(Complaint c) {
        return ComplaintSummaryDTO.builder()
                .complaintId(c.getComplaintId())
                .passengerName(c.getPassenger().getFullName())
                .busNumber(c.getBus() != null ? c.getBus().getBusNumber() : "N/A")
                .category(c.getCategory())
                .description(c.getDescription())
                .photoUrl(c.getPhotoUrl())
                .priority(c.getPriority())
                .status(c.getStatus())
                .authorityFeedback(c.getAuthorityFeedback()) // null until authority acts
                .submittedAt(c.getSubmittedAt() != null ? c.getSubmittedAt().format(FMT) : null)
                .resolvedAt(c.getResolvedAt() != null ? c.getResolvedAt().format(FMT) : null)
                .build();
    }

    private ComplaintDetailDTO toDetailDTO(Complaint c, boolean includeResolutionNote) {
        return ComplaintDetailDTO.builder()
                .complaintId(c.getComplaintId())
                .passengerName(c.getPassenger().getFullName())
                .passengerPhone(c.getPassenger().getPhone())
                .busNumber(c.getBus() != null ? c.getBus().getBusNumber() : "N/A")
                .routeName(c.getBus() != null && c.getBus().getRoute() != null
                        ? c.getBus().getRoute().getRouteName() : "N/A")
                .tripId(c.getTrip() != null ? c.getTrip().getTripId() : null)
                .category(c.getCategory())
                .description(c.getDescription())
                .photoUrl(c.getPhotoUrl())
                .priority(c.getPriority())
                .status(c.getStatus())
                .submittedAt(c.getSubmittedAt() != null ? c.getSubmittedAt().format(FMT) : null)
                // Encapsulation: resolutionNote only shown to authority
                .resolutionNote(includeResolutionNote ? c.getResolutionNote() : null)
                .authorityFeedback(c.getAuthorityFeedback())
                .assignedToName(c.getAssignedTo() != null
                        ? c.getAssignedTo().getFullName() : "Unassigned")
                .resolvedAt(c.getResolvedAt() != null ? c.getResolvedAt().format(FMT) : null)
                .build();
    }
}
