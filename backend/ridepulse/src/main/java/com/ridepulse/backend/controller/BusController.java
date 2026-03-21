package com.ridepulse.backend.controller;

import com.ridepulse.backend.config.CustomUserDetails;
import com.ridepulse.backend.dto.*;
import com.ridepulse.backend.service.BusManagementService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/bus-owner/buses")
@RequiredArgsConstructor
public class BusController {

    private final BusManagementService busService;

    /**
     * GET /api/v1/bus-owner/buses
     * List all buses owned by logged-in bus owner
     */
    @GetMapping
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<List<BusDetailDTO>> getBuses(
            @AuthenticationPrincipal CustomUserDetails user) {
        return ResponseEntity.ok(busService.getBusesByOwner(user.getOwnerId()));
    }

    /**
     * GET /api/v1/bus-owner/buses/{busId}
     */
    @GetMapping("/{busId}")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<BusDetailDTO> getBusById(
            @PathVariable Integer busId,
            @AuthenticationPrincipal CustomUserDetails user) {
        return ResponseEntity.ok(busService.getBusById(busId, user.getOwnerId()));
    }

    /**
     * POST /api/v1/bus-owner/buses
     * Body: { busNumber, registrationNumber, routeId, capacity, model, year }
     * Add a new bus — routeId selected from dropdown
     */
    @PostMapping
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<BusDetailDTO> addBus(
            @Valid @RequestBody CreateBusRequest request,
            @AuthenticationPrincipal CustomUserDetails user) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(busService.addBus(request, user.getOwnerId()));
    }

    /**
     * PATCH /api/v1/bus-owner/buses/route
     * Body: { busId, routeId }
     * Update which route a bus is assigned to
     */
    @PatchMapping("/route")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<BusDetailDTO> updateBusRoute(
            @Valid @RequestBody UpdateBusRouteRequest request,
            @AuthenticationPrincipal CustomUserDetails user) {
        return ResponseEntity.ok(busService.updateBusRoute(request, user.getOwnerId()));
    }

    /**
     * DELETE /api/v1/bus-owner/buses/{busId}
     * Soft delete — sets is_active = false
     */
    @DeleteMapping("/{busId}")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<Map<String, String>> deleteBus(
            @PathVariable Integer busId,
            @AuthenticationPrincipal CustomUserDetails user) {
        busService.deleteBus(busId, user.getOwnerId());
        return ResponseEntity.ok(Map.of("message", "Bus deactivated successfully"));
    }
}
