package com.ridepulse.backend.dto;

// ============================================================
// CONDUCTOR MODULE — ALL DTOs
// OOP Encapsulation: each DTO exposes only what the conductor
//     app needs, hiding internal entity relationships.
// ============================================================

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.List;

// ── CrowdUpdateRequest ───────────────────────────────────────
// Conductor manually updates passenger count during trip
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class CrowdUpdateRequest {
    @NotNull private Integer tripId;
    @NotNull @Min(0) private Integer passengerCount;
}
