package com.ridepulse.backend.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class StaffAssignRequest {
    private Integer staffId;
    private Integer busId;
    private LocalDate assignedDate;
}