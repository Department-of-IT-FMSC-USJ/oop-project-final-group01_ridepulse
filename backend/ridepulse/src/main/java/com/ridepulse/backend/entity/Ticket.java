package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.*;
import java.util.List;
import java.util.UUID;
@Entity
@Table(name = "tickets")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Ticket {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ticket_id")
    private Long ticketId;

    // Human-readable reference e.g. "TKT-20250115-00123"
    @Column(name = "ticket_number", unique = true, nullable = false, length = 50)
    private String ticketNumber;

    // QR payload — Base64 UUID string; scanned by conductor app
    @Column(name = "qr_code", unique = true, nullable = false, columnDefinition = "TEXT")
    private String qrCode;

    // Association: ticket belongs to a specific trip
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trip_id")
    private BusTrip trip;

    // Nullable: passenger may be anonymous (cash ticket)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "passenger_id")
    private User passenger;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "conductor_id")
    private Staff conductor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "route_id", nullable = false)
    private Route route;

    // Boarding and alighting stops for fare calculation
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "boarding_stop_id")
    private RouteStop boardingStop;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "alighting_stop_id")
    private RouteStop alightingStop;

    @Column(name = "fare_amount", nullable = false, precision = 8, scale = 2)
    private BigDecimal fareAmount;

    // Polymorphism: payment method affects revenue split (cash vs digital)
    @Column(name = "payment_method", length = 20)
    private String paymentMethod = "cash";  // cash | digital

    // Lifecycle: active → used | expired | refunded
    @Column(name = "ticket_status", length = 20)
    private String ticketStatus = "active";  // active | used | expired | refunded

    @Column(name = "is_validated")
    private Boolean isValidated = false;

    @Column(name = "validated_at")
    private LocalDateTime validatedAt;

    // Named issuedAt to match: findByPassenger_UserIdOrderByIssuedAtDesc
    @Column(name = "issued_at", nullable = false)
    private LocalDateTime issuedAt = LocalDateTime.now();
}