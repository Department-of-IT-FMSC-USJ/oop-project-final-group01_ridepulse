package com.ridepulse.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

/**
 * Complaint Entity
 */
@Entity
@Table(name = "complaints")
@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class Complaint extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "complaint_id")
    private Integer complaintId;

    @Column(name = "ticket_number", unique = true)
    private String ticketNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "passenger_id")
    private Staff passenger;

    @Column(nullable = false)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "complaint_category")
    private ComplaintCategory category;

    @Enumerated(EnumType.STRING)
    private ComplaintStatus status = ComplaintStatus.SUBMITTED;

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt;

    /**
     * Business method - Change complaint status
     */
    public void changeStatus(ComplaintStatus newStatus) {
        this.status = newStatus;
        // Additional status change logic
    }
}

enum ComplaintCategory {
    CROWDING,
    DRIVER_BEHAVIOR,
    DELAY,
    CLEANLINESS,
    SAFETY,
    OTHER
}

enum ComplaintStatus {
    SUBMITTED,
    UNDER_REVIEW,
    RESOLVED,
    CLOSED,
    REJECTED
}