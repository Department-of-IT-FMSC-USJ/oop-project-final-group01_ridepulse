package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.BusOwner;
import com.ridepulse.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

/**
 * OOP Abstraction: Bus owner data access — hides JOIN on users table.
 * Used by: CustomUserDetailsService, AuthServiceImpl, all bus-owner services
 */
@Repository
public interface BusOwnerRepository extends JpaRepository<BusOwner, Integer> {

    // Used by: CustomUserDetailsService — resolves ownerId from logged-in user
    Optional<BusOwner> findByUser(User user);

    // Used by: CustomUserDetailsService — resolves ownerId by userId UUID
    Optional<BusOwner> findByUser_UserId(UUID userId);

    // Used by: AuthServiceImpl — checks NIC uniqueness on registration
    boolean existsByNicNumber(String nicNumber);
}
