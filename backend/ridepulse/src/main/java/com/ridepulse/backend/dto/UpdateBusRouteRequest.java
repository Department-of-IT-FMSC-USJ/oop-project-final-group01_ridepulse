package com.ridepulse.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.List;

/** Request to update a bus's assigned route */
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class UpdateBusRouteRequest {
    @NotNull private Integer busId;
    @NotNull private Integer routeId;
}