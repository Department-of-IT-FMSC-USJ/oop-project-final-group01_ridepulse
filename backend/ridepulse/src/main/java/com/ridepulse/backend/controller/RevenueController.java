package com.ridepulse.backend.controller;

import com.ridepulse.backend.config.CustomUserDetails;
import com.ridepulse.backend.dto.*;
import com.ridepulse.backend.service.RevenueService;
import com.ridepulse.backend.service.WelfareService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * OOP Encapsulation: All revenue and welfare HTTP operations are bundled here.
 *      Single Responsibility: owns revenue + welfare endpoints only.
 */
@RestController
@RequestMapping("/api/v1/bus-owner/revenue")
@RequiredArgsConstructor
public class RevenueController {

    private final RevenueService  revenueService;  // Abstraction: interface
    private final WelfareService  welfareService;  // Abstraction: interface

    /**
     * POST /api/v1/bus-owner/revenue/fuel
     * Body: { "busId": 2, "expenseDate": "2025-01-15", "fuelAmount": 4500.00 }
     * Owner enters daily fuel expense for a bus
     */
    @PostMapping("/fuel")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<Map<String, String>> recordFuelExpense(
            @Valid @RequestBody DailyFuelRequest request) {

        revenueService.recordDailyFuel(request);
        return ResponseEntity.ok(Map.of("message", "Fuel expense recorded"));
    }

    /**
     * PUT /api/v1/bus-owner/revenue/maintenance-config
     * Body: { "busId": 2, "monthlyAmount": 15000.00 }
     * Sets the fixed monthly maintenance cost for a bus
     */
    @PutMapping("/maintenance-config")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<Map<String, String>> setMaintenanceConfig(
            @Valid @RequestBody MaintenanceConfigRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        revenueService.setMaintenanceConfig(request, userDetails.getOwnerId());
        return ResponseEntity.ok(Map.of("message", "Maintenance config updated"));
    }

    /**
     * GET /api/v1/bus-owner/revenue/monthly?month=1&year=2025
     * Returns monthly revenue summary for ALL buses of this owner
     */
    @GetMapping("/monthly")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<List<MonthlyRevenueDTO>> getMonthlyRevenue(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam(defaultValue = "0") int month,
            @RequestParam(defaultValue = "0") int year) {

        // Default to current month/year
        int m = month == 0 ? LocalDate.now().getMonthValue() : month;
        int y = year  == 0 ? LocalDate.now().getYear()        : year;

        return ResponseEntity.ok(
                revenueService.getAllBusesMonthlyRevenue(userDetails.getOwnerId(), m, y));
    }

    /**
     * GET /api/v1/bus-owner/revenue/monthly/{busId}?month=1&year=2025
     * Returns monthly revenue for a specific bus
     */
    @GetMapping("/monthly/{busId}")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<MonthlyRevenueDTO> getSingleBusRevenue(
            @PathVariable Integer busId,
            @RequestParam int month,
            @RequestParam int year,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        return ResponseEntity.ok(
                revenueService.getMonthlyRevenue(busId, month, year, userDetails.getOwnerId()));
    }

    /**
     * GET /api/v1/bus-owner/revenue/welfare?month=1&year=2025
     * Returns welfare breakdown per staff member for the given month
     */
    @GetMapping("/welfare")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<List<StaffProfileDTO>> getWelfareSummary(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam(defaultValue = "0") int month,
            @RequestParam(defaultValue = "0") int year) {

        int m = month == 0 ? LocalDate.now().getMonthValue() : month;
        int y = year  == 0 ? LocalDate.now().getYear()        : year;

        return ResponseEntity.ok(
                welfareService.getStaffWelfareSummary(userDetails.getOwnerId(), m, y));
    }
}