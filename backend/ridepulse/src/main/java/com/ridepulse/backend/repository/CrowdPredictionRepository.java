package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.CrowdPrediction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

/**
 * OOP Abstraction: Hides LSTM prediction lookup from the REST layer.
 * Used by: PassengerApp (show predicted crowd), AuthorityDashboard
 */
@Repository
public interface CrowdPredictionRepository extends JpaRepository<CrowdPrediction, Integer> {

    // Used by: PassengerApp — what is the predicted crowd for this route right now?
    @Query("""
        SELECT p FROM CrowdPrediction p
        WHERE p.route.routeId = :routeId
          AND p.predictionDate = :date
          AND p.timeSlot = :timeSlot
        """)
    Optional<CrowdPrediction> findPrediction(
            @Param("routeId") Integer routeId,
            @Param("date") LocalDate date,
            @Param("timeSlot") LocalTime timeSlot);

    // Used by: AuthorityDashboard — all predictions for a route on a date
    List<CrowdPrediction> findByRoute_RouteIdAndPredictionDateOrderByTimeSlot(
            Integer routeId, LocalDate predictionDate);

    // Used by: LSTM service — delete stale predictions before inserting new ones
    void deleteByRoute_RouteIdAndPredictionDate(Integer routeId, LocalDate date);
}