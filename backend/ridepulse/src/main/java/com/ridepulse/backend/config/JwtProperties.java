package com.ridepulse.backend.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import lombok.Data;

/**
 * ENCAPSULATION (OOP Concept):
 * This class encapsulates JWT configuration properties
 * All JWT-related settings are centralized here
 */
@Configuration
@ConfigurationProperties(prefix = "jwt")
@Data
public class JwtProperties {

    /**
     * Secret key for signing JWT tokens
     * In production, store this in environment variables or secure vault
     */
    private String secret = "5367566B59703373367639792F423F4528482B4D6251655468576D5A71347437";

    /**
     * Token expiration time in milliseconds
     * Default: 24 hours (86400000 ms)
     */
    private long expiration = 86400000;

    /**
     * Token prefix for Authorization header
     * Example: "Bearer <token>"
     */
    private String tokenPrefix = "Bearer ";

    /**
     * Header name for JWT token
     */
    private String headerString = "Authorization";
}