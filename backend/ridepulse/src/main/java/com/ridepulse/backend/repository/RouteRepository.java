package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.Route;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * OOP Abstraction: Route data access — used for dropdown and detail views.
 * Used by: RouteServiceImpl, BusManagementServiceImpl
 */
@Repository
public interface RouteRepository extends JpaRepository<Route, Integer> {

    // Used by: RouteServiceImpl.getAllActiveRoutes() — populates Flutter dropdown
    List<Route> findByIsActiveTrueOrderByRouteNumber();

    // Used by: BusManagementServiceImpl — find route by number for validation
    Optional<Route> findByRouteNumber(String routeNumber);

    // Used by: RouteServiceImpl — check if route number already exists
    boolean existsByRouteNumber(String routeNumber);
}
