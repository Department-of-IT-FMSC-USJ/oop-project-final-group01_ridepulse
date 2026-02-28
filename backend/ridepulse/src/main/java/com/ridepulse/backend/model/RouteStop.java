package com.ridepulse.backend.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * RouteStop Entity
 * Demonstrates COMPOSITION (Many stops belong to one Route)
 */
@Entity
@Table(name = "route_stops")
@Data
@NoArgsConstructor
public class RouteStop {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "stop_id")
    private Integer stopId;

    @Column(name = "stop_name", nullable = false)
    private String stopName;

    @Column(name = "stop_sequence", nullable = false)
    private Integer stopSequence;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @Column(name = "distance_from_start_km")
    private BigDecimal distanceFromStartKm;

    /**
     * Many RouteStops belong to one Route
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "route_id")
    private Route route;
}
