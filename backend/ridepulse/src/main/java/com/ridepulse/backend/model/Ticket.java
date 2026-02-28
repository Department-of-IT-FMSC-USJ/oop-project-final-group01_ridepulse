package com.ridepulse.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Ticket Entity - Demonstrates complex relationships and business logic
 */
@Entity
@Table(name = "tickets")
@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class Ticket extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ticket_id")
    private Long ticketId;

    @Column(name = "ticket_number", unique = true, nullable = false)
    private String ticketNumber;

    @Column(name = "qr_code", unique = true, nullable = false)
    private String qrCode;

    /**
     * ASSOCIATION: Ticket references Passenger (Many-to-One)
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "passenger_id")
    private User passenger;

    /**
     * ASSOCIATION: Ticket references Conductor
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "conductor_id")
    private Staff conductor;

    /**
     * ASSOCIATION: Ticket references Route
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "route_id")
    private Route route;

    /**
     * ASSOCIATION: Ticket references Bus
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_id")
    private Bus bus;

    @Column(name = "fare_amount", nullable = false)
    private BigDecimal fareAmount;

    @Column(name = "issue_timestamp")
    private LocalDateTime issueTimestamp;

    @Column(name = "is_validated")
    private Boolean isValidated = false;

    @Column(name = "validation_timestamp")
    private LocalDateTime validationTimestamp;

    @Enumerated(EnumType.STRING)
    @Column(name = "ticket_status")
    private TicketStatus status;

    /**
     * Business method - Encapsulation of validation logic
     */
    public boolean validateTicket() {
        if (!isValidated) {
            this.isValidated = true;
            this.validationTimestamp = LocalDateTime.now();
            this.status = TicketStatus.USED;
            return true;
        }
        return false;
    }

    /**
     * Business method - Calculate fare based on distance
     */
    public BigDecimal calculateFare() {
        // Encapsulated fare calculation logic
        return this.route.getBaseFare();
    }
}

/**
 * Enum for Ticket Status
 */
enum TicketStatus {
    ACTIVE,
    USED,
    EXPIRED,
    REFUNDED
}