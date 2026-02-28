package com.ridepulse.backend.security;

import com.ridepulse.backend.model.User;
import lombok.AllArgsConstructor;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import java.util.Collection;
import java.util.Collections;

/**
 * ADAPTER PATTERN (Design Pattern):
 * Adapts our User entity to Spring Security's UserDetails interface
 *
 * ENCAPSULATION:
 * Wraps User entity and provides security-specific methods
 */
@Data
@AllArgsConstructor
public class CustomUserDetails implements UserDetails {

    private User user;

    /**
     * Return user authorities (roles)
     * Spring Security uses this for authorization
     */
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // Convert user role to Spring Security authority
        return Collections.singletonList(
                new SimpleGrantedAuthority("ROLE_" + user.getRole().name())
        );
    }

    @Override
    public String getPassword() {
        return user.getPasswordHash();
    }

    @Override
    public String getUsername() {
        return user.getEmail();
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return user.getIsActive();
    }
}