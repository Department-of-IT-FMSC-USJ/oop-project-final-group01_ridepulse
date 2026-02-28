package com.ridepulse.backend.repository;

import com.ridepulse.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

/**
 * UserRepository - Demonstrates ABSTRACTION (OOP Concept)
 * Interface defines contract for data access operations
 * Implementation details are hidden by Spring Data JPA
 */
@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    /**
     * Abstraction: Method signature defines WHAT to do, not HOW
     * Spring Data JPA provides implementation automatically
     */
    Optional<User> findByEmail(String email);

    Optional<User> findByPhone(String phone);

    boolean existsByEmail(String email);

    boolean existsByPhone(String phone);
}
