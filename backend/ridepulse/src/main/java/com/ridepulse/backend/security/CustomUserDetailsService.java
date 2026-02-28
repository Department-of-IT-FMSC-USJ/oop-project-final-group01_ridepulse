package com.ridepulse.backend.security;

import com.ridepulse.backend.model.User;
import com.ridepulse.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

/**
 * SINGLETON PATTERN (via Spring @Service):
 * Spring manages this as a singleton bean
 *
 * ENCAPSULATION:
 * Encapsulates user loading logic for Spring Security
 */
@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    /**
     * DEPENDENCY INJECTION:
     * Repository is injected via constructor (RequiredArgsConstructor)
     */
    private final UserRepository userRepository;

    /**
     * Load user by username (email in our case)
     * Required by Spring Security for authentication
     *
     * @param email User's email
     * @return UserDetails object
     * @throws UsernameNotFoundException if user not found
     */
    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new UsernameNotFoundException("User not found with email: " + email)
                );

        // Return our custom UserDetails implementation
        return new CustomUserDetails(user);
    }
}