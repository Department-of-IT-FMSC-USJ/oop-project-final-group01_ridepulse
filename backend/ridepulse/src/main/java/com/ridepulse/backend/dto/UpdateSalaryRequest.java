package com.ridepulse.backend.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class UpdateSalaryRequest {
    private Integer staffId;
    private BigDecimal baseSalary;    // New salary amount in LKR
}