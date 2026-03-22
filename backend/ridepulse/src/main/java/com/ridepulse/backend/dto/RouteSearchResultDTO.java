package com.ridepulse.dto;


import lombok.*;
import java.util.List;

// ── RouteSearchResultDTO ─────────────────────────────────────
// Returned from route search — lightweight, no stops
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class RouteSearchResultDTO {
    private Integer routeId;
    private String  routeNumber;       // e.g. "133"
    private String  routeName;         // e.g. "Colombo - Negombo"
    private String  startLocation;
    private String  endLocation;
    private Double  totalDistanceKm;
    private Double  baseFare;
    private Integer activeBusCount;    // how many buses currently on this route
}
