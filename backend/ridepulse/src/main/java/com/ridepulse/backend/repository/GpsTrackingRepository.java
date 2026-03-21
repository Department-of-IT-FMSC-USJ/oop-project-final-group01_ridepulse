package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.GpsTracking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * OOP Encapsulation: GPS query complexity is hidden — callers just ask
 *                    for "latest location" without writing any SQL.
 * Used by: DashboardServiceImpl (live map), GPS tracking endpoint
 */
@Repository
public interface GpsTrackingRepository extends JpaRepository<GpsTracking, Long> {

    // Used by: DashboardServiceImpl.getLiveBusLocations() — one latest point per bus
    @Query("""
        SELECT g FROM GpsTracking g
        WHERE g.bus.busId = :busId
          AND g.recordedAt = (
              SELECT MAX(g2.recordedAt) FROM GpsTracking g2
              WHERE g2.bus.busId = :busId
          )
        """)
    Optional<GpsTracking> findLatestByBusId(@Param("busId") Integer busId);

    // Used by: DashboardServiceImpl — batch fetch latest for all owner's buses
    @Query("""
        SELECT g FROM GpsTracking g
        WHERE g.bus.owner.ownerId = :ownerId
          AND g.recordedAt = (
              SELECT MAX(g2.recordedAt) FROM GpsTracking g2
              WHERE g2.bus.busId = g.bus.busId
          )
        """)
    List<GpsTracking> findLatestLocationForAllBusesOfOwner(
            @Param("ownerId") Integer ownerId);

    // Used by: PassengerApp — recent GPS trail for map animation (last 10 points)
    List<GpsTracking> findTop10ByBus_BusIdOrderByRecordedAtDesc(Integer busId);
}