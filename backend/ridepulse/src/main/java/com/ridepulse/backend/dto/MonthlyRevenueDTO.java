package com.ridepulse.backend.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class MonthlyRevenueDTO {
    private Integer busId;
    private String busNumber;
    private Integer month;
    private Integer year;
    private BigDecimal grossRevenue;
    private BigDecimal totalFuelCost;
    private BigDecimal maintenanceCost;
    private BigDecimal totalStaffSalaries;
    private BigDecimal netProfit;
    private BigDecimal driverWelfareAmount;     // 3% of netProfit
    private BigDecimal conductorWelfareAmount;  // 2% of netProfit
    private Boolean isFinalized;
}