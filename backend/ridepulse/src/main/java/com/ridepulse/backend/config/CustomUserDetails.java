package com.ridepulse.backend.config;

import com.ridepulse.backend.entity.User;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

/**
 * Spring Security principal that wraps the {@link User} entity.
 *
 * <p>This is the object that lives inside the {@code SecurityContext} for every
 * authenticated request.  Controllers receive it via
 * {@code @AuthenticationPrincipal CustomUserDetails userDetails} and can read
 * {@code ownerId} (bus owners) or {@code staffId} (drivers / conductors)
 * without making extra DB calls.</p>
 *
 * <p>OOP note — the three extra ID fields (userId, ownerId, staffId) are
 * populated once at login and then carried in the JWT so that downstream
 * services never have to resolve them again.  Null fields are intentional:
 * a passenger has neither ownerId nor staffId.</p>
 */
@Getter
public class CustomUserDetails implements UserDetails {

    // ── Encapsulation: all fields private final ──────────────
    private final UUID    userId;
    private final String  email;
    private final String  passwordHash;
    private final String  fullName;

    /**
     * Polymorphism: one string drives all role-based branching in the system.
     * Values: "passenger" | "driver" | "conductor" | "bus_owner" | "authority"
     */
    private final String  role;

    private final boolean active;

    /**
     * Populated only when role == "bus_owner".
     * Null for every other role.
     * Used by: all /bus-owner/** endpoints via @AuthenticationPrincipal.
     */
    private final Integer ownerId;

    /**
     * Populated only when role == "driver" or "conductor".
     * Null for every other role.
     * Used by: /driver/** and /conductor/** endpoints.
     */
    private final Integer staffId;

    // ── Constructor ──────────────────────────────────────────

    /**
     * Builds the principal from the resolved {@link User} entity plus the
     * role-specific secondary IDs.  Called only from
     * {@link CustomUserDetailsService#loadUserByUsername}.
     *
     * @param user    the persisted user entity
     * @param ownerId resolved bus_owner profile ID — null if not a bus_owner
     * @param staffId resolved staff profile ID   — null if not driver/conductor
     */
    public CustomUserDetails(User user, Integer ownerId, Integer staffId) {
        this.userId       = user.getUserId();
        this.email        = user.getEmail();
        this.passwordHash = user.getPasswordHash();
        this.fullName     = user.getFullName();
        this.role         = user.getRole().name();          // e.g. "bus_owner"
        this.active       = Boolean.TRUE.equals(user.getIsActive());
        this.ownerId      = ownerId;
        this.staffId      = staffId;
    }

    // ── UserDetails contract ─────────────────────────────────

    /**
     * Polymorphism: the single role string is converted to a Spring
     * {@link GrantedAuthority} at runtime.
     * Example: role "bus_owner" → authority "ROLE_bus_owner"
     * This is what @PreAuthorize("hasRole('bus_owner')") checks against.
     */
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role));
    }

    /** Spring uses this as the credential for authentication checks. */
    @Override
    public String getPassword() { return passwordHash; }

    /** Spring uses email as the unique username. */
    @Override
    public String getUsername() { return email; }

    @Override public boolean isAccountNonExpired()    { return true;   }
    @Override public boolean isAccountNonLocked()     { return active; }  // deactivated = locked
    @Override public boolean isCredentialsNonExpired(){ return true;   }
    @Override public boolean isEnabled()              { return active; }

    // ── Convenience helpers (Encapsulation) ──────────────────

    /** True only for bus_owner role. */
    public boolean isBusOwner() { return "bus_owner".equals(role); }

    /** True for driver or conductor. */
    public boolean isStaff() {
        return "driver".equals(role) || "conductor".equals(role);
    }

    /** True for passenger role. */
    public boolean isPassenger() { return "passenger".equals(role); }

    /** True for authority role. */
    public boolean isAuthority() { return "authority".equals(role); }
}