package com.ridepulse.backend.repository;

import com.ridepulse.backend.model.Route;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

/**
 * RouteRepository - Data Access Layer
 */
@Repository
public interface RouteRepository extends JpaRepository<Route, Integer> {

    Optional<Route> findByRouteNumber(String routeNumber);

    List<Route> findByIsActiveTrue();

    /**
     * Custom query method
     */
    @Query("SELECT r FROM Route r WHERE r.startLocation = :location OR r.endLocation = :location")
    List<Route> findRoutesByLocation(String location);
}