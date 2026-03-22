package com.ridepulse.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.List;

// ── TripStatusDTO ────────────────────────────────────────────
// Returned after starting or stopping a trip
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class TripStatusDTO {
    private Integer tripId;
    private String  busNumber;
    private String  routeName;
    private String  status;          // in_progress | completed | cancelled
    private String  tripStart;
    private String  tripEnd;         // null while in progress
    private Integer ticketsIssuedCount;
    private Double  totalFareCollected;
    private Integer currentPassengerCount;
}
