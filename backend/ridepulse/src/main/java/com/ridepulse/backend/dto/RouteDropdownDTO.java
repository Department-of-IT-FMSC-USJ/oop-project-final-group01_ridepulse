package com.ridepulse.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class RouteDropdownDTO {
    private Integer routeId;
    private String  routeNumber;       // e.g. "133"
    private String  routeName;         // e.g. "Colombo - Negombo"
    private String  startLocation;
    private String  endLocation;
    private BigDecimal baseFare;
    private Double  totalDistanceKm;
}