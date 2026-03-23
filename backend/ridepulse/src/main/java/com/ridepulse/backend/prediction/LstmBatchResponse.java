package com.ridepulse.backend.prediction;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import java.util.List;

@Data @JsonIgnoreProperties(ignoreUnknown = true)
class LstmBatchResponse {
    @JsonProperty("schedules")
    private List<LstmScheduleResponse> schedules;

    @JsonProperty("total_predictions")
    private Integer totalPredictions;

    @JsonProperty("generated_at")
    private String generatedAt;
}
