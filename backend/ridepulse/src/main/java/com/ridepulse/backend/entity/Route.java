package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.*;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "routes")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Route {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "route_id")
    private Integer routeId;

    // e.g. "133", "100", "1"  — unique per NTC numbering
    @Column(name = "route_number", unique = true, nullable = false, length = 20)
    private String routeNumber;

    // e.g. "Colombo - Negombo"
    @Column(name = "route_name", nullable = false, length = 200)
    private String routeName;

    @Column(name = "start_location", nullable = false, length = 150)
    private String startLocation;

    @Column(name = "end_location", nullable = false, length = 150)
    private String endLocation;

    @Column(name = "total_distance_km", precision = 8, scale = 2)
    private BigDecimal totalDistanceKm;

    // Minimum fare for this route — used in ticket fare calculation
    @Column(name = "base_fare", nullable = false, precision = 8, scale = 2)
    private BigDecimal baseFare;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    // Aggregation: Route owns its stops — cascade delete stops with route
    @OneToMany(mappedBy = "route", fetch = FetchType.LAZY,
            cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("stopSequence ASC")
    private List<RouteStop> stops;
}
