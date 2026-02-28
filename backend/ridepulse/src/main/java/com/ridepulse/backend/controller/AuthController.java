package com.ridepulse.backend.controller;

import com.ridepulse.backend.dto.AuthResponse;
import com.ridepulse.backend.dto.LoginRequest;
import com.ridepulse.backend.dto.RegisterRequest;
import com.ridepulse.backend.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * INTERFACE PATTERN:
 * REST API endpoints for authentication
 * Exposes authentication functionality to external clients (Flutter app)
 *
 * ENCAPSULATION:
 * Authentication logic is hidden behind service layer
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;

    /**
     * Register new user
     * POST /api/auth/register
     *
     * @param request Registration details
     * @return AuthResponse with JWT token
     */
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(
            @Valid @RequestBody RegisterRequest request
    ) {
        try {
            AuthResponse response = authService.register(request);
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        } catch (Exception e) {
            // In production, use proper exception handling
            throw new RuntimeException("Registration failed: " + e.getMessage());
        }
    }

    /**
     * Login user
     * POST /api/auth/login
     *
     * @param request Login credentials
     * @return AuthResponse with JWT token
     */
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(
            @Valid @RequestBody LoginRequest request
    ) {
        try {
            AuthResponse response = authService.login(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(null);
        }
    }

    /**
     * Logout user
     * POST /api/auth/logout
     *
     * @param authHeader Authorization header with JWT token
     */
    @PostMapping("/logout")
    public ResponseEntity<String> logout(
            @RequestHeader("Authorization") String authHeader
    ) {
        try {
            String token = authHeader.substring(7); // Remove "Bearer " prefix
            authService.logout(token);
            return ResponseEntity.ok("Logged out successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Logout failed");
        }
    }

    /**
     * Test endpoint to verify authentication
     * GET /api/auth/test
     * Requires valid JWT token
     */
    @GetMapping("/test")
    public ResponseEntity<String> test() {
        return ResponseEntity.ok("Authentication successful! You are authorized.");
    }
}