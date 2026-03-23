package com.ridepulse.backend.prediction;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import java.util.List;

// Request body for /predict/batch
@Data @Builder
class LstmBatchRequest {
    @JsonProperty("route_ids")
    private List<Integer> routeIds;

    @JsonProperty("date")
    private String date;

    @JsonProperty("bus_capacities")
    private java.util.Map<String, Integer> busCapacities;

    @JsonProperty("weather")
    private String weather;

    @JsonProperty("rain")
    private Double rain;

    @JsonProperty("traffic_level")
    private String trafficLevel;
}