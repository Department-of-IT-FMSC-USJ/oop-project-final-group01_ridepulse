package com.ridepulse.backend.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class ToggleStaffStatusRequest {
    private Integer staffId;
    private Boolean isActive;         // true = activate, false = deactivate
}