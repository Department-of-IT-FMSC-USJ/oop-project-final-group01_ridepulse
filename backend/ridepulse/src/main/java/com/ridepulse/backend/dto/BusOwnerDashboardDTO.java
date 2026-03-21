package com.ridepulse.backend.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class BusOwnerDashboardDTO {
    private String ownerName;
    private String businessName;
    private Integer totalBuses;
    private Integer activeBuses;
    private Integer totalStaff;
    private Integer activeStaff;

    // Combined totals across all buses this month
    private BigDecimal totalMonthGrossRevenue;
    private BigDecimal totalMonthNetProfit;
    private BigDecimal totalDriverWelfare;      // Sum across all buses
    private BigDecimal totalConductorWelfare;

    private Integer totalOpenComplaints;
    private List<BusDashboardCardDTO> buses;    // One card per bus
}