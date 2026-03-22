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

// ── ConductorDashboardDTO ────────────────────────────────────
// Home screen snapshot — OOP Abstraction: one call returns everything
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class ConductorDashboardDTO {
    private String  conductorName;
    private String  employeeId;
    private Integer staffId;

    // Today's duty (null if no duty today)
    private RosterDetailDTO todayRoster;

    // Active trip (null if not on a trip)
    private TripStatusDTO   activeTrip;

    // This month stats
    private Integer dutyDaysThisMonth;
    private Integer ticketsIssuedThisMonth;
    private Double  totalFareThisMonth;

    // Welfare
    private Double  welfareThisMonth;
    private Double  totalWelfareBalance;
}

