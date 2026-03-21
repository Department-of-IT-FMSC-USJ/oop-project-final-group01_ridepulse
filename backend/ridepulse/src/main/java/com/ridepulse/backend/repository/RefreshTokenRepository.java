package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

/**
 * OOP Encapsulation: Token rotation logic — revoke old tokens on logout.
 * Used by: AuthServiceImpl (future refresh token endpoint)
 */
@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Integer> {

    // Used by: AuthServiceImpl — validate incoming refresh token
    Optional<RefreshToken> findByTokenAndIsRevokedFalse(String token);

    // Used by: AuthServiceImpl.logout() — revoke all tokens for a user
    @Modifying
    @Query("UPDATE RefreshToken r SET r.isRevoked = true WHERE r.user.userId = :userId")
    void revokeAllTokensForUser(@Param("userId") UUID userId);
}