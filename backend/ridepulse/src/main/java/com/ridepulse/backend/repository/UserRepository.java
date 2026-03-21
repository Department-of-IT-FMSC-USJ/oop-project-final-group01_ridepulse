package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

/**
 * OOP Abstraction: Hides all user-table SQL behind typed method signatures.
 * Used by: AuthServiceImpl, CustomUserDetailsService
 */
@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    // Used by: AuthServiceImpl.login(), CustomUserDetailsService.loadUserByUsername()
    Optional<User> findByEmail(String email);

    // Used by: AuthServiceImpl.validateEmailUnique()
    boolean existsByEmail(String email);

    // Used by: AuthServiceImpl (phone uniqueness check on registration)
    boolean existsByPhone(String phone);
}