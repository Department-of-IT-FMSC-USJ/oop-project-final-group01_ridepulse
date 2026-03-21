package com.ridepulse.backend.controller;

import com.ridepulse.backend.dto.*;
import com.ridepulse.backend.service.RouteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/routes")
@RequiredArgsConstructor
public class RouteController {

    private final RouteService routeService;

    /**
     * GET /api/v1/routes
     * Returns all active routes for dropdown — used in Flutter DropdownButton
     */
    @GetMapping
    public ResponseEntity<List<RouteDropdownDTO>> getAllRoutes() {
        return ResponseEntity.ok(routeService.getAllActiveRoutes());
    }

    /**
     * GET /api/v1/routes/{routeId}
     * Returns route with stops — used on map / route detail screen
     */
    @GetMapping("/{routeId}")
    public ResponseEntity<RouteDetailDTO> getRouteById(@PathVariable Integer routeId) {
        return ResponseEntity.ok(routeService.getRouteById(routeId));
    }
}