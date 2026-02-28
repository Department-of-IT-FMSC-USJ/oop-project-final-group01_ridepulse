package com.ridepulse.backend.service.impl;

import com.ridepulse.backend.dto.AuthResponse;
import com.ridepulse.backend.dto.LoginRequest;
import com.ridepulse.backend.dto.RegisterRequest;
import com.ridepulse.backend.model.User;
import com.ridepulse.backend.repository.UserRepository;
import com.ridepulse.backend.service.AuthService;
import com.ridepulse.backend.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ridepulse.backend.model.UserRole;

/**
 * ENCAPSULATION:
 * Authentication business logic encapsulated here
 * Handles registration, login, and JWT token generation
 */
@Service
@RequiredArgsConstructor
@Transactional
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;

    /**
     * Register new user
     * 1. Validate user doesn't exist
     * 2. Hash password with BCrypt
     * 3. Save user
     * 4. Generate JWT token
     * 5. Return authentication response
     */
    @Override
    public AuthResponse register(RegisterRequest request) {
        // Check if user already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered");
        }

        // Create new user
        User user = new User();
        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());

        // ENCRYPT PASSWORD with BCrypt
        String hashedPassword = passwordEncoder.encode(request.getPassword());
        user.setPasswordHash(hashedPassword);

        // Set role (convert string to enum)
        try {
            user.setRole(UserRole.valueOf(request.getRole().toUpperCase()));
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid role: " + request.getRole());
        }

        user.setIsActive(true);

        // Save user to database
        User savedUser = userRepository.save(user);

        // Generate JWT token
        String token = jwtUtil.generateToken(
                savedUser.getEmail(),
                savedUser.getRole().name()
        );

        // Return authentication response
        return new AuthResponse(
                savedUser.getUserId(),
                savedUser.getEmail(),
                savedUser.getFullName(),
                savedUser.getRole().name(),
                token
        );
    }

    /**
     * Login user
     * 1. Authenticate with Spring Security
     * 2. Load user from database
     * 3. Generate JWT token
     * 4. Return authentication response
     */
    @Override
    public AuthResponse login(LoginRequest request) {
        try {
            // Authenticate user using Spring Security
            // This will use BCrypt to verify password
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail(),
                            request.getPassword()
                    )
            );

            // If authentication successful, load user details
            User user = userRepository.findByEmail(request.getEmail())
                    .orElseThrow(() -> new RuntimeException("User not found"));

            // Check if account is active
            if (!user.getIsActive()) {
                throw new RuntimeException("Account is inactive");
            }

            // Generate JWT token
            String token = jwtUtil.generateToken(
                    user.getEmail(),
                    user.getRole().name()
            );

            // Return authentication response
            return new AuthResponse(
                    user.getUserId(),
                    user.getEmail(),
                    user.getFullName(),
                    user.getRole().name(),
                    token
            );

        } catch (Exception e) {
            throw new RuntimeException("Invalid email or password");
        }
    }

    /**
     * Logout user
     * In stateless JWT authentication, logout is typically handled client-side
     * by removing the token from storage
     */
    @Override
    public void logout(String token) {
        // For stateless JWT, logout is client-side
        // Token will expire after configured time
        // For enhanced security, you could maintain a blacklist of invalidated tokens
        System.out.println("User logged out");
    }
}