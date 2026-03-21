package com.ridepulse.backend.controller;

import com.ridepulse.backend.config.CustomUserDetails;
import com.ridepulse.backend.dto.*;
import com.ridepulse.backend.service.StaffManagementService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * OOP: Single Responsibility — handles only staff management for bus owners.
 *      Encapsulation — service details are hidden behind clean HTTP verbs.
 */
@RestController
@RequestMapping("/api/v1/bus-owner/staff")
@RequiredArgsConstructor
public class StaffController {

    private final StaffManagementService staffService; // Abstraction: interface only

    /**
     * GET /api/v1/bus-owner/staff
     * Returns all drivers and conductors under this bus owner
     */
    @GetMapping
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<List<StaffProfileDTO>> getAllStaff(
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        return ResponseEntity.ok(
                staffService.getStaffByOwner(userDetails.getOwnerId()));
    }

    /**
     * GET /api/v1/bus-owner/staff/{staffId}
     * Returns full profile for a single staff member
     */
    @GetMapping("/{staffId}")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<StaffProfileDTO> getStaffProfile(
            @PathVariable Integer staffId,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        return ResponseEntity.ok(
                staffService.getStaffProfile(staffId, userDetails.getOwnerId()));
    }

    /**
     * PATCH /api/v1/bus-owner/staff/toggle-status
     * Body: { "staffId": 5, "isActive": false }
     * Activates or deactivates a staff member's profile
     */
    @PatchMapping("/toggle-status")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<Map<String, String>> toggleStaffStatus(
            @Valid @RequestBody ToggleStaffStatusRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        staffService.toggleStaffStatus(request, userDetails.getOwnerId());
        String msg = Boolean.TRUE.equals(request.getIsActive()) ? "activated" : "deactivated";
        return ResponseEntity.ok(Map.of("message", "Staff " + msg + " successfully"));
    }

    /**
     * PATCH /api/v1/bus-owner/staff/salary
     * Body: { "staffId": 5, "baseSalary": 35000.00 }
     * Updates a staff member's base monthly salary
     */
    @PatchMapping("/salary")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<Map<String, String>> updateSalary(
            @Valid @RequestBody UpdateSalaryRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        staffService.updateBaseSalary(request, userDetails.getOwnerId());
        return ResponseEntity.ok(Map.of("message", "Salary updated successfully"));
    }

    /**
     * POST /api/v1/bus-owner/staff/assign
     * Body: { "staffId": 5, "busId": 2, "assignedDate": "2025-01-15" }
     * Assigns a staff member to a specific bus
     */
    @PostMapping("/assign")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<Map<String, String>> assignStaffToBus(
            @Valid @RequestBody StaffAssignRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        staffService.assignStaffToBus(request, userDetails.getOwnerId());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(Map.of("message", "Staff assigned to bus successfully"));
    }

    /**
     * DELETE /api/v1/bus-owner/staff/{staffId}/assign
     * Removes a staff member from their current bus assignment
     */
    @DeleteMapping("/{staffId}/assign")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<Map<String, String>> unassignStaff(
            @PathVariable Integer staffId,
            @AuthenticationPrincipal CustomUserDetails userDetails) {

        staffService.unassignStaff(staffId, userDetails.getOwnerId());
        return ResponseEntity.ok(Map.of("message", "Staff unassigned successfully"));
    }
}