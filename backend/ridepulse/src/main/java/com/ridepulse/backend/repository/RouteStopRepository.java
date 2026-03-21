package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.Route;
import com.ridepulse.backend.entity.RouteStop;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * OOP Encapsulation: Stop ordering is encapsulated in repository method.
 * Used by: RouteServiceImpl.getRouteById()
 */
@Repository
public interface RouteStopRepository extends JpaRepository<RouteStop, Integer> {

    // Used by: RouteServiceImpl — returns stops in sequence order for map display
    List<RouteStop> findByRouteOrderByStopSequence(Route route);

    // Used by: RouteServiceImpl — stops for a routeId (when Route entity not in hand)
    List<RouteStop> findByRoute_RouteIdOrderByStopSequence(Integer routeId);

    // Used by: TicketServiceImpl — validate boarding/alighting stop belongs to route
    boolean existsByStopIdAndRoute_RouteId(Integer stopId, Integer routeId);
}
