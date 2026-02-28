package com.ridepulse.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

/**
 * Bus Entity - Demonstrates ASSOCIATION relationships
 */
@Entity
@Table(name = "buses")
@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class Bus extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "bus_id")
    private Integer busId;

    @Column(name = "bus_number", unique = true, nullable = false)
    private String busNumber;

    @Column(nullable = false)
    private Integer capacity;

    @Column(name = "registration_number", unique = true)
    private String registrationNumber;

    private String model;

    @Column(name = "has_gps_device")
    private Boolean hasGpsDevice;

    @Column(name = "is_active")
    private Boolean isActive = true;

    /**
     * ASSOCIATION: Bus belongs to one Route (Many-to-One)
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "route_id")
    private Route route;

    /**
     * Business method - Encapsulation
     */
    public GPSData updateLocation(double latitude, double longitude) {
        GPSData gpsData = new GPSData();
        gpsData.setLatitude(latitude);
        gpsData.setLongitude(longitude);
        gpsData.setBus(this);
        return gpsData;
    }

    public Route getCurrentRoute() {
        return this.route;
    }
}