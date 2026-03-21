package com.ridepulse.backend.entity;

// ============================================================
// Complaint.java — updated with authority feedback fields
// OOP Encapsulation: complaint owns its full lifecycle state.
//     Polymorphism: status state machine drives how each role
//     interacts with the complaint.
// ============================================================

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "complaints")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Complaint {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "complaint_id")
    private Integer complaintId;

    // Passenger who filed the complaint
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "passenger_id", nullable = false)
    private User passenger;

    // Bus the complaint is about (nullable — general complaints allowed)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_id")
    private Bus bus;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trip_id")
    private BusTrip trip;

    // Polymorphism: category drives which authority dept handles it
    @Column(name = "category", nullable = false, length = 30)
    private String category; // crowding|driver_behavior|delay|cleanliness|safety|other

    @Column(name = "description", nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(name = "photo_url", columnDefinition = "TEXT")
    private String photoUrl;

    @Column(name = "priority", length = 10)
    private String priority = "medium"; // low | medium | high

    // Polymorphism: status drives the complaint lifecycle
    //   submitted → under_review → resolved | rejected
    @Column(name = "status", length = 20)
    private String status = "submitted";

    // Authority's internal corrective action note
    @Column(name = "resolution_note", columnDefinition = "TEXT")
    private String resolutionNote;

    // NEW: feedback visible to the passenger — what the authority decided
    @Column(name = "authority_feedback", columnDefinition = "TEXT")
    private String authorityFeedback;

    // NEW: which authority user is assigned to this complaint
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_to_id")
    private User assignedTo;

    @Column(name = "submitted_at", updatable = false)
    private LocalDateTime submittedAt = LocalDateTime.now();

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;
}
