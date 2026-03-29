package com.ridepulse.backend.prediction;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import java.util.List;

@Data @JsonIgnoreProperties(ignoreUnknown = true)
class LstmSlot {
    @JsonProperty("route_id")
    private Integer routeId;

    @JsonProperty("prediction_date")
    private String predictionDate;

    @JsonProperty("time_slot")
    private String timeSlot;              // "08:00"

    @JsonProperty("predicted_count")
    private Double predictedCount;

    @JsonProperty("predicted_percentage")
    private Double predictedPercentage;

    @JsonProperty("predicted_category")
    private String predictedCategory;    // "low" | "medium" | "high"

    @JsonProperty("confidence_score")
    private Double confidenceScore;

    @JsonProperty("model_version")
    private String modelVersion;
}