package com.ridepulse.backend.service;

import com.ridepulse.backend.dto.*;
import java.util.List;

/** OOP Abstraction: contract for route operations */
public interface RouteService {
    List<RouteDropdownDTO> getAllActiveRoutes();   // For dropdown
    RouteDetailDTO         getRouteById(Integer routeId);
}