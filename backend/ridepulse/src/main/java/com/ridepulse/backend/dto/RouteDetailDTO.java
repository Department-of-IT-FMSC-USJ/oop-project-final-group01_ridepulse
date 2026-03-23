package com.ridepulse.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class RouteDetailDTO {
    private Integer routeId;
    private String  routeNumber;
    private String  routeName;
    private String  startLocation;
    private String  endLocation;
    private BigDecimal baseFare;
    private Double  totalDistanceKm;
    private Boolean isActive;
    private List<RouteStopDTO> stops;
}
