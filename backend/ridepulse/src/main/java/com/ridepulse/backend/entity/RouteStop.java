package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.*;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "route_stops",
        uniqueConstraints = @UniqueConstraint(
                columnNames = {"route_id", "stop_sequence"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class RouteStop {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "stop_id")
    private Integer stopId;

    // Association: many stops belong to one route
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "route_id", nullable = false)
    private Route route;

    @Column(name = "stop_name", nullable = false, length = 150)
    private String stopName;

    // Position in route sequence — 1, 2, 3 ...
    @Column(name = "stop_sequence", nullable = false)
    private Integer stopSequence;

    @Column(name = "latitude", nullable = false, precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(name = "longitude", nullable = false, precision = 11, scale = 8)
    private BigDecimal longitude;
}