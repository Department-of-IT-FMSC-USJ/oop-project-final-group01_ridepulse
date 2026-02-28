package com.ridepulse.backend.service;

import com.ridepulse.backend.model.User;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * UserService Interface - Demonstrates ABSTRACTION
 * Defines contract for user-related business operations
 */
public interface UserService {

    /**
     * Abstraction: Method signatures define business operations
     */
    User createUser(User user);

    Optional<User> getUserById(UUID userId);

    Optional<User> getUserByEmail(String email);

    List<User> getAllUsers();

    User updateUser(UUID userId, User user);

    void deleteUser(UUID userId);

    boolean login(String email, String password);

    void logout(UUID userId);
}