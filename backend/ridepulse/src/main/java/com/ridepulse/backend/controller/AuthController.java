package com.ridepulse.backend.controller;

import com.ridepulse.backend.config.CustomUserDetails;
import com.ridepulse.backend.dto.auth.*;
import com.ridepulse.backend.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService; // Abstraction: interface only

    /**
     * POST /api/v1/auth/login
     * Body: { "email": "...", "password": "..." }
     * OOP Polymorphism: same endpoint serves all roles.
     * Client reads 'role' in response to navigate accordingly.
     */
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(
            @Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    /**
     * POST /api/v1/auth/register/passenger
     * Public: any user can self-register as passenger
     */
    @PostMapping("/register/passenger")
    public ResponseEntity<AuthResponse> registerPassenger(
            @Valid @RequestBody RegisterPassengerRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(authService.registerPassenger(request));
    }

    /**
     * POST /api/v1/auth/register/bus-owner
     * Public: any user can self-register as bus owner
     */
    @PostMapping("/register/bus-owner")
    public ResponseEntity<AuthResponse> registerBusOwner(
            @Valid @RequestBody RegisterBusOwnerRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(authService.registerBusOwner(request));
    }

    /**
     * POST /api/v1/auth/register/authority
     * Public for demo; in production restrict to admin invitation
     */
    @PostMapping("/register/authority")
    public ResponseEntity<AuthResponse> registerAuthority(
            @Valid @RequestBody RegisterAuthorityRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(authService.registerAuthority(request));
    }

    /**
     * POST /api/v1/auth/register/staff
     * PROTECTED: only bus_owner can call this.
     * Bus owner registers drivers and conductors — staff cannot self-register.
     * OOP Polymorphism: staffType in body determines driver vs conductor creation.
     */
    @PostMapping("/register/staff")
    @PreAuthorize("hasRole('bus_owner')")
    public ResponseEntity<AuthResponse> registerStaff(
            @Valid @RequestBody RegisterStaffRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        // ownerId from JWT principal — Encapsulation
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(authService.registerStaff(request, userDetails.getOwnerId()));
    }
}
