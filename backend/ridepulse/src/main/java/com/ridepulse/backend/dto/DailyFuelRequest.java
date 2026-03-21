package com.ridepulse.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class DailyFuelRequest {
    private Integer busId;
    private LocalDate expenseDate;
    private BigDecimal fuelAmount;    // Amount in LKR
}
