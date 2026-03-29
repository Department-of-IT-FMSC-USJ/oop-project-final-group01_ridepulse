package com.ridepulse.backend.dto;


import lombok.*;
import java.util.List;

// ── RoutePredictionScheduleDTO ───────────────────────────────
// All predictions for a route on a date (full day schedule)
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class RoutePredictionScheduleDTO {
    private Integer routeId;
    private String  routeName;
    private String  date;
    private Boolean hasData;              // false = LSTM not yet trained
    private List<CrowdPredictionDTO> slots;
}