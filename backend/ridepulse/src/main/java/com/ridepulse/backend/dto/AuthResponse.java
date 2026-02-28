package com.ridepulse.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.UUID;

/**
 * ENCAPSULATION:
 * Response object containing authentication details
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {

    private UUID userId;
    private String email;
    private String fullName;
    private String role;
    private String token;
    private String tokenType = "Bearer";

    public AuthResponse(UUID userId, String email, String fullName, String role, String token) {
        this.userId = userId;
        this.email = email;
        this.fullName = fullName;
        this.role = role;
        this.token = token;
    }
}