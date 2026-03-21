package com.ridepulse.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class RouteStopDTO {
    private Integer stopId;
    private String  stopName;
    private Integer stopSequence;
    private Double  latitude;
    private Double  longitude;
}
