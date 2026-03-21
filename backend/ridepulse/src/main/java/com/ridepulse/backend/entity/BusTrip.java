package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.*;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "bus_trips")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BusTrip {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "trip_id")
    private Integer tripId;

    // Aggregation: trip owns references to bus, route, roster
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_id", nullable = false)
    private Bus bus;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "route_id", nullable = false)
    private Route route;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "roster_id")
    private DutyRoster roster;    // nullable: trip may start without a roster

    @Column(name = "trip_start", nullable = false)
    private LocalDateTime tripStart;

    // Null until trip ends
    @Column(name = "trip_end")
    private LocalDateTime tripEnd;

    // Polymorphism: status drives behavior in ConductorApp and PassengerApp
    @Column(name = "status", length = 20)
    private String status = "in_progress";  // in_progress | completed | cancelled

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}