package com.ridepulse.backend.controller;

import com.ridepulse.backend.config.CustomUserDetails;
import com.ridepulse.backend.dto.*;
import com.ridepulse.backend.service.BusOwnerDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * OOP Encapsulation: Controller hides service layer from HTTP clients.
 * Polymorphism: @PreAuthorize enforces bus_owner-only access per endpoint.
 */
@RestController
@RequestMapping("/api/v1/bus-owner/dashboard")
@RequiredArgsConstructor
public class BusOwnerDashboardController {

    // Abstraction: depends on interface, not implementation
    private final BusOwnerDashboardService dashboardService;

    /**
     * GET /api/v1/bus-owner/dashboard
     * Returns full dashboard: all buses, totals, staff counts, complaints
     */
    @GetMapping
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<BusOwnerDashboardDTO> getDashboard(
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        BusOwnerDashboardDTO dashboard =
                dashboardService.getDashboard(userDetails.getOwnerId());
        return ResponseEntity.ok(dashboard);
    }

    /**
     * GET /api/v1/bus-owner/dashboard/live-locations
     * Returns latest GPS coordinates for all buses owned by this owner
     */
    @GetMapping("/live-locations")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<List<BusLocationDTO>> getLiveBusLocations(
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        return ResponseEntity.ok(
                dashboardService.getLiveBusLocations(userDetails.getOwnerId()));
    }

    /**
     * GET /api/v1/bus-owner/dashboard/complaints?status=submitted
     * Returns complaints for all buses/staff under this owner
     */
    @GetMapping("/complaints")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<List<ComplaintSummaryDTO>> getComplaints(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam(defaultValue = "all") String status) {

        return ResponseEntity.ok(
                dashboardService.getComplaints(userDetails.getOwnerId(), status));
    }
}