package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.*;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "emergency_alerts")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class EmergencyAlert {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "alert_id")
    private Integer alertId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_id", nullable = false)
    private Bus bus;

    // Optional: alert may be raised outside a formal trip
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trip_id")
    private BusTrip trip;

    // The staff member (driver or conductor) who raised the alert
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "staff_id", nullable = false)
    private Staff staff;

    // Polymorphism: accident | breakdown | medical | security | other
    @Column(name = "alert_type", nullable = false, length = 20)
    private String alertType;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    // GPS coordinates at time of alert
    @Column(name = "latitude", precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(name = "longitude", precision = 11, scale = 8)
    private BigDecimal longitude;

    // Polymorphism: active → acknowledged → resolved
    @Column(name = "status", length = 20)
    private String status = "active";   // active | acknowledged | resolved

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;
}
