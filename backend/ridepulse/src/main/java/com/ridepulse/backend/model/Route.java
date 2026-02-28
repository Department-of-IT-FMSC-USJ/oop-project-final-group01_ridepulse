package com.ridepulse.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Route Entity - Demonstrates COMPOSITION (HAS-A relationship)
 * Route HAS-A collection of RouteStops
 */
@Entity
@Table(name = "routes")
@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class Route extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "route_id")
    private Integer routeId;

    @Column(name = "route_number", unique = true, nullable = false)
    private String routeNumber;

    @Column(name = "route_name", nullable = false)
    private String routeName;

    @Column(name = "start_location", nullable = false)
    private String startLocation;

    @Column(name = "end_location", nullable = false)
    private String endLocation;

    @Column(name = "total_distance_km")
    private BigDecimal totalDistanceKm;

    @Column(name = "estimated_duration_minutes")
    private Integer estimatedDurationMinutes;

    @Column(name = "base_fare", nullable = false)
    private BigDecimal baseFare;

    @Column(name = "is_active")
    private Boolean isActive = true;

    /**
     * COMPOSITION: Route HAS-MANY RouteStops
     * Cascade operations demonstrate object lifecycle management
     */
    @OneToMany(mappedBy = "route", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RouteStop> stops = new ArrayList<>();

    /**
     * Business method - Encapsulation of route calculation logic
     */
    public BigDecimal calculateETA() {
        // Complex ETA calculation hidden in this method
        return BigDecimal.valueOf(estimatedDurationMinutes);
    }

    /**
     * Helper method to add stops - maintains bidirectional relationship
     */
    public void addStop(RouteStop stop) {
        stops.add(stop);
        stop.setRoute(this);
    }

    public void removeStop(RouteStop stop) {
        stops.remove(stop);
        stop.setRoute(null);
    }
}