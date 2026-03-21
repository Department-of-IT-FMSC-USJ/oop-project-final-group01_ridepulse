package com.ridepulse.backend.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class MaintenanceConfigRequest {
    private Integer busId;
    private BigDecimal monthlyAmount; // Fixed LKR amount per month
}
