package com.ridepulse.backend.service;

import com.ridepulse.backend.model.Route;
import java.util.List;
import java.util.Optional;

public interface RouteService {

    Route createRoute(Route route);

    Optional<Route> getRouteById(Integer routeId);

    List<Route> getAllRoutes();

    List<Route> getActiveRoutes();

    Route updateRoute(Integer routeId, Route route);

    void deleteRoute(Integer routeId);

    // Business method - calculates ETA
    Double calculateETA(Integer routeId);
}