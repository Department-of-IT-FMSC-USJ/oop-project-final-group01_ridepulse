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

// ── ConductorWelfareDTO ──────────────────────────────────────
// Welfare history per month
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class ConductorWelfareDTO {
    private Integer month;
    private Integer year;
    private Double  welfareAmount;
    private Double  cumulativeBalance;
    private String  busNumber;
}
