package com.ridepulse.backend.controller;

import com.ridepulse.backend.prediction.PredictionSchedulerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/authority/predictions")
@RequiredArgsConstructor
public class AuthorityPredictionController {

    private final PredictionSchedulerService schedulerService;

    /**
     * POST /api/v1/authority/predictions/generate
     * Body: { "date": "2025-01-15", "weather": "clear",
     *         "rain": 0.0, "trafficLevel": "medium" }
     * Authority manually triggers LSTM prediction generation.
     */
    @PostMapping("/generate")
    @PreAuthorize("hasRole('authority')")
    public ResponseEntity<Map<String, String>> generatePredictions(
            @RequestBody(required = false) Map<String, Object> body) {

        String date    = body != null && body.containsKey("date")
                ? (String) body.get("date") : LocalDate.now().toString();
        String weather = body != null && body.containsKey("weather")
                ? (String) body.get("weather") : "clear";
        Double rain    = body != null && body.containsKey("rain")
                ? Double.parseDouble(body.get("rain").toString()) : 0.0;
        String traffic = body != null && body.containsKey("trafficLevel")
                ? (String) body.get("trafficLevel") : "medium";

        // Run asynchronously so HTTP response is immediate
        new Thread(() ->
                schedulerService.generatePredictionsForDate(
                        date, weather, rain, traffic)
        ).start();

        return ResponseEntity.accepted().body(Map.of(
                "message", "Prediction generation started for " + date,
                "date", date,
                "weather", weather
        ));
    }

    /**
     * POST /api/v1/authority/predictions/generate/today
     * Quick trigger — generates predictions for today with defaults.
     */
    @PostMapping("/generate/today")
    @PreAuthorize("hasRole('authority')")
    public ResponseEntity<Map<String, String>> generateToday() {
        new Thread(() ->
                schedulerService.generatePredictionsForDate(
                        LocalDate.now().toString(), "clear", 0.0, "medium")
        ).start();
        return ResponseEntity.accepted().body(Map.of(
                "message", "Generating today's predictions in background"
        ));
    }
}