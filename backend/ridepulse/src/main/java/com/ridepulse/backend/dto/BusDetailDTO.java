package com.ridepulse.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.List;
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class BusDetailDTO {
    private Integer busId;
    private String  busNumber;
    private String  registrationNumber;
    private Integer capacity;
    private String  model;
    private Integer yearManufactured;
    private Boolean hasGps;
    private Boolean isActive;
    private RouteDropdownDTO route;
    private String  assignedDriverName;
    private String  assignedConductorName;
}
