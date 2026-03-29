package com.ridepulse.backend.prediction;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import java.util.List;

@Data @JsonIgnoreProperties(ignoreUnknown = true)
class LstmScheduleResponse {
    @JsonProperty("route_id")
    private Integer routeId;

    @JsonProperty("date")
    private String date;

    @JsonProperty("slots")
    private List<LstmSlot> slots;

    @JsonProperty("model_version")
    private String modelVersion;
}

