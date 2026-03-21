package com.ridepulse.backend.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class BusDashboardCardDTO {
    private Integer busId;
    private String busNumber;
    private String registrationNumber;
    private String routeName;
    private Boolean isActive;
    private Integer capacity;

    // Live data
    private Double currentLatitude;       // Latest GPS point
    private Double currentLongitude;
    private String crowdCategory;         // "low" | "medium" | "high"
    private Integer currentPassengerCount;

    // This month snapshot
    private BigDecimal monthGrossRevenue;
    private BigDecimal monthNetProfit;
    private Integer openComplaintsCount;

    // Staff on this bus
    private String assignedDriverName;
    private String assignedConductorName;
}