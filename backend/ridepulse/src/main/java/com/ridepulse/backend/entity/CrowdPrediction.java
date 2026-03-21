package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.*;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "crowd_predictions",
        uniqueConstraints = @UniqueConstraint(
                columnNames = {"route_id", "prediction_date", "time_slot"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class CrowdPrediction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "prediction_id")
    private Integer predictionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "route_id", nullable = false)
    private Route route;

    @Column(name = "prediction_date", nullable = false)
    private LocalDate predictionDate;

    // 30-minute slots e.g. 08:00, 08:30, 09:00 ...
    @Column(name = "time_slot", nullable = false)
    private LocalTime timeSlot;

    @Column(name = "predicted_percentage", nullable = false, precision = 5, scale = 2)
    private BigDecimal predictedPercentage;

    // Polymorphism: same category enum as CrowdLevel for consistent UI display
    @Column(name = "predicted_category", nullable = false, length = 10)
    private String predictedCategory;   // low | medium | high

    // 0.0000–1.0000 — LSTM model's confidence in this prediction
    @Column(name = "confidence_score", precision = 5, scale = 4)
    private BigDecimal confidenceScore;

    // Tracks which model version generated this — e.g. "lstm_v1.2"
    @Column(name = "model_version", length = 20)
    private String modelVersion;

    @Column(name = "generated_at", updatable = false)
    private LocalDateTime generatedAt = LocalDateTime.now();
}

