package com.ridepulse.dto;


import lombok.*;
import java.util.List;


// ── BusLiveDetailDTO ─────────────────────────────────────────
// Single bus full live view — for the bus detail screen
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class BusLiveDetailDTO {
    private Integer busId;
    private String  busNumber;
    private String  registrationNumber;
    private Integer capacity;

    // Route
    private Integer routeId;
    private String  routeName;
    private String  routeNumber;
    private List<StopDTO> stops;       // full stop list for map polyline

    // Live location
    private Double  latitude;
    private Double  longitude;
    private Double  speedKmh;
    private Double  heading;
    private String  lastUpdated;

    // Live crowd
    private Integer passengerCount;
    private Double  capacityPercentage;
    private String  crowdCategory;     // low | medium | high

    // Trip
    private Integer tripId;
    private String  tripStartedAt;
}

