package com.ridepulse.backend.service.impl;

import com.ridepulse.backend.model.User;
import com.ridepulse.backend.repository.UserRepository;
import com.ridepulse.backend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * ENCAPSULATION:
 * Business logic for user management
 * Now includes BCrypt password hashing
 */
@Service
@RequiredArgsConstructor
@Transactional
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder; // BCrypt encoder injected

    /**
     * Create user with encrypted password
     * BCrypt automatically salts and hashes the password
     */
    @Override
    public User createUser(User user) {
        // Validation
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        // ENCRYPT PASSWORD using BCrypt
        String encryptedPassword = passwordEncoder.encode(user.getPasswordHash());
        user.setPasswordHash(encryptedPassword);

        // Set default values
        user.setIsActive(true);

        return userRepository.save(user);
    }

    @Override
    public Optional<User> getUserById(UUID userId) {
        return userRepository.findById(userId);
    }

    @Override
    public Optional<User> getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    @Override
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @Override
    public User updateUser(UUID userId, User updatedUser) {
        return userRepository.findById(userId)
                .map(existingUser -> {
                    existingUser.setFullName(updatedUser.getFullName());
                    existingUser.setPhone(updatedUser.getPhone());

                    // If password is being updated, encrypt it
                    if (updatedUser.getPasswordHash() != null &&
                            !updatedUser.getPasswordHash().isEmpty()) {
                        String encryptedPassword = passwordEncoder.encode(
                                updatedUser.getPasswordHash()
                        );
                        existingUser.setPasswordHash(encryptedPassword);
                    }

                    return userRepository.save(existingUser);
                })
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Override
    public void deleteUser(UUID userId) {
        userRepository.deleteById(userId);
    }

    /**
     * Login method now uses BCrypt to verify password
     */
    @Override
    public boolean login(String email, String password) {
        Optional<User> userOpt = userRepository.findByEmail(email);

        if (userOpt.isPresent()) {
            User user = userOpt.get();
            // Use BCrypt to verify password
            return passwordEncoder.matches(password, user.getPasswordHash());
        }

        return false;
    }

    @Override
    public void logout(UUID userId) {
        userRepository.findById(userId)
                .ifPresent(User::logout);
    }
}