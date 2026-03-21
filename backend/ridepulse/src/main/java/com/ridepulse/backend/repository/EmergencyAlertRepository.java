package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.EmergencyAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * OOP Encapsulation: Alert lookup scoped to owner or authority.
 * Used by: EmergencyAlertService (Driver app), AuthorityDashboard
 */
@Repository
public interface EmergencyAlertRepository extends JpaRepository<EmergencyAlert, Integer> {

    // Used by: AuthorityDashboard — all active alerts system-wide
    List<EmergencyAlert> findByStatusOrderByCreatedAtDesc(String status);

    // Used by: BusOwnerDashboard — active alerts for owner's buses
    @Query("""
        SELECT a FROM EmergencyAlert a
        WHERE a.bus.owner.ownerId = :ownerId
          AND a.status = 'active'
        ORDER BY a.createdAt DESC
        """)
    List<EmergencyAlert> findActiveAlertsByOwner(@Param("ownerId") Integer ownerId);

    // Used by: Driver/Conductor app — active alert for their bus
    List<EmergencyAlert> findByBus_BusIdAndStatus(Integer busId, String status);
}