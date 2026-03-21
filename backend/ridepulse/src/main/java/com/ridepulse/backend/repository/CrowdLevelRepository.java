package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.CrowdLevel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * OOP Abstraction: Latest crowd snapshot lookup — used for live display.
 * Used by: DashboardServiceImpl, PassengerApp crowd display
 */
@Repository
public interface CrowdLevelRepository extends JpaRepository<CrowdLevel, Long> {

    // Used by: DashboardServiceImpl — latest crowd reading per bus for dashboard card
    @Query("""
        SELECT c FROM CrowdLevel c
        WHERE c.bus.busId = :busId
          AND c.recordedAt = (
              SELECT MAX(c2.recordedAt) FROM CrowdLevel c2
              WHERE c2.bus.busId = :busId
          )
        """)
    Optional<CrowdLevel> findLatestByBusId(@Param("busId") Integer busId);

    // Used by: LSTM training — historical crowd data for a route
    @Query("""
        SELECT c FROM CrowdLevel c
        WHERE c.trip.route.routeId = :routeId
        ORDER BY c.recordedAt ASC
        """)
    List<CrowdLevel> findHistoricalByRouteId(@Param("routeId") Integer routeId);

    // Used by: PassengerApp — current crowd for all buses on a route
    @Query("""
        SELECT c FROM CrowdLevel c
        WHERE c.trip.route.routeId = :routeId
          AND c.recordedAt = (
              SELECT MAX(c2.recordedAt) FROM CrowdLevel c2
              WHERE c2.bus.busId = c.bus.busId
          )
        """)
    List<CrowdLevel> findLatestCrowdForRoute(@Param("routeId") Integer routeId);
}