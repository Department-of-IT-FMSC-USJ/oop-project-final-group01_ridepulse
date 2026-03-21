package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.*;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "gps_tracking")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class GpsTracking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "tracking_id")
    private Long trackingId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_id", nullable = false)
    private Bus bus;

    // Optional: null if GPS ping outside of a trip
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trip_id")
    private BusTrip trip;

    @Column(name = "latitude", nullable = false, precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(name = "longitude", nullable = false, precision = 11, scale = 8)
    private BigDecimal longitude;

    // Named speedKmh to match: BusLocationDTO.speedKmh
    @Column(name = "speed_kmh", precision = 6, scale = 2)
    private BigDecimal speedKmh;

    // Compass heading in degrees (0–360)
    @Column(name = "heading", precision = 6, scale = 2)
    private BigDecimal heading;

    // Named recordedAt to match: findTop10ByBus_BusIdOrderByRecordedAtDesc
    @Column(name = "recorded_at", nullable = false)
    private LocalDateTime recordedAt = LocalDateTime.now();
}