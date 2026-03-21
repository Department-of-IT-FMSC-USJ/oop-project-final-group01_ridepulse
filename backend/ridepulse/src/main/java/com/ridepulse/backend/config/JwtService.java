package com.ridepulse.backend.config;

// OOP Encapsulation — all token generation and validation logic is private.
//     The rest of the system only calls generateToken(), isTokenValid(),
//     extractEmail(), extractRole(). The crypto details never leak out.

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Service
public class JwtService {

    @Value("${app.jwt.secret}")
    private String jwtSecret;

    @Value("${app.jwt.expiration-ms}")
    private long jwtExpirationMs;

    // Encapsulation: key construction is private — callers never touch the key
    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes());
    }

    /**
     * Generates a signed JWT for the given principal.
     * OOP Polymorphism: role, ownerId, staffId are embedded so every role
     * carries exactly the claims it needs — no extra DB calls downstream.
     */
    public String generateToken(CustomUserDetails userDetails) {
        Map<String, Object> extraClaims = new HashMap<>();
        extraClaims.put("role",    userDetails.getRole());
        extraClaims.put("userId",  userDetails.getUserId().toString());
        extraClaims.put("ownerId", userDetails.getOwnerId());   // null for non-owners
        extraClaims.put("staffId", userDetails.getStaffId());   // null for non-staff

        // JJWT 0.12+ new fluent API — replaces all deprecated set*() methods
        return Jwts.builder()
                .claims(extraClaims)                                          // replaces setClaims()
                .subject(userDetails.getUsername())                           // replaces setSubject()
                .issuedAt(new Date())                                         // replaces setIssuedAt()
                .expiration(new Date(System.currentTimeMillis() + jwtExpirationMs)) // replaces setExpiration()
                .signWith(getSigningKey())                                    // replaces signWith(key, algorithm)
                .compact();
    }

    public String extractEmail(String token) {
        return extractAllClaims(token).getSubject();
    }

    public String extractRole(String token) {
        return extractAllClaims(token).get("role", String.class);
    }

    public boolean isTokenValid(String token, CustomUserDetails userDetails) {
        final String email = extractEmail(token);
        return email.equals(userDetails.getUsername()) && !isTokenExpired(token);
    }

    private boolean isTokenExpired(String token) {
        return extractAllClaims(token).getExpiration().before(new Date());
    }

    // Encapsulation: parsing detail is private — callers never parse themselves
    private Claims extractAllClaims(String token) {
        // JJWT 0.12+ replaces parserBuilder() with parser()
        return Jwts.parser()
                .verifyWith(getSigningKey())          // replaces setSigningKey()
                .build()
                .parseSignedClaims(token)             // replaces parseClaimsJws()
                .getPayload();                        // replaces getBody()
    }
}
