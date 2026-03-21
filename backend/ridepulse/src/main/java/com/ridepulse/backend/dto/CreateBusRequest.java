package com.ridepulse.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.List;

/** Request to create a new bus — Encapsulation: only needed fields */
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class CreateBusRequest {
    @NotBlank  private String busNumber;             // e.g. "NB-1234"
    @NotBlank  private String registrationNumber;
    @NotNull   private Integer routeId;              // Route selected from dropdown
    @NotNull   private Integer capacity;
    private String  model;
    private Integer yearManufactured;
    private Boolean hasGps;
}
