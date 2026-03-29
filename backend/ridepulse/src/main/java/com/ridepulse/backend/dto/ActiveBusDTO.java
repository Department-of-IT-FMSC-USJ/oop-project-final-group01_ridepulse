package com.ridepulse.backend.dto;


import lombok.*;
import java.util.List;


// ── ActiveBusDTO ─────────────────────────────────────────────
// A live bus on a route — location + crowd combined in one DTO
// OOP Abstraction: hides GPS + CrowdLevel join behind one object
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class ActiveBusDTO {
    private Integer busId;
    private String  busNumber;
    private Integer capacity;

    // Live GPS
    private Double  latitude;
    private Double  longitude;
    private Double  speedKmh;
    private String  lastUpdated;       // "2 mins ago" style

    // Live crowd
    private Integer passengerCount;
    private Double  capacityPercentage;
    private String  crowdCategory;     // low | medium | high

    // Trip context
    private Integer tripId;
    private String  tripStartedAt;
}

