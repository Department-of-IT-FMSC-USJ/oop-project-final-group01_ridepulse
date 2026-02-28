package com.ridepulse.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

/**
 * GPSData Entity - Demonstrates time-series data handling
 */
@Entity
@Table(name = "gps_tracking")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GPSData {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "tracking_id")
    private Long trackingId;

    /**
     * ASSOCIATION: GPS data belongs to a Bus
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_id", nullable = false)
    private Bus bus;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    private Double speed;

    private Double heading;

    @Column(nullable = false)
    private LocalDateTime timestamp;

    @Column(name = "is_deviation")
    private Boolean isDeviation = false;

    /**
     * Business method - Coordinate validation
     */
    public boolean updateCoordinates(double lat, double lon) {
        if (isValidCoordinate(lat, lon)) {
            this.latitude = lat;
            this.longitude = lon;
            this.timestamp = LocalDateTime.now();
            return true;
        }
        return false;
    }

    /**
     * Helper method - Encapsulation
     */
    private boolean isValidCoordinate(double lat, double lon) {
        return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
    }
}
