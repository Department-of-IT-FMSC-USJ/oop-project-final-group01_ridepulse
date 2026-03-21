package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.Bus;
import com.ridepulse.backend.entity.BusMaintenanceConfig;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * OOP Encapsulation: one config per bus — one-to-one relationship.
 * Used by: RevenueServiceImpl, WelfareServiceImpl
 */
@Repository
public interface BusMaintenanceConfigRepository extends JpaRepository<BusMaintenanceConfig, Integer> {

    // Used by: WelfareServiceImpl — get fixed monthly maintenance cost for a bus
    Optional<BusMaintenanceConfig> findByBus(Bus bus);

    // Used by: RevenueServiceImpl — same, by bus ID
    Optional<BusMaintenanceConfig> findByBus_BusId(Integer busId);
}