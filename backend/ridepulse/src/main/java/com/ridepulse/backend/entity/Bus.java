// OOP: Encapsulation — bus object holds all its own state.
//      Aggregation — belongs to BusOwner, associated to a Route.
// ============================================================
package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "buses")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Bus {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "bus_id")
    private Integer busId;

    @Column(name = "bus_number", unique = true, nullable = false, length = 30)
    private String busNumber;

    @Column(name = "registration_number", unique = true, nullable = false, length = 30)
    private String registrationNumber;

    // Aggregation: Bus belongs to a BusOwner
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private BusOwner owner;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "route_id")
    private Route route;

    @Column(name = "capacity", nullable = false)
    private Integer capacity;

    @Column(name = "model", length = 100)
    private String model;

    @Column(name = "year_manufactured")
    private Integer yearManufactured;

    @Column(name = "has_gps")
    private Boolean hasGps = true;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}