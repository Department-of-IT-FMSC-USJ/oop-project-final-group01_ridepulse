package com.ridepulse.backend.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class BusLocationDTO {
    private Integer busId;
    private String busNumber;
    private Double latitude;
    private Double longitude;
    private Double speedKmh;
    private String recordedAt;
    private String crowdCategory;
}