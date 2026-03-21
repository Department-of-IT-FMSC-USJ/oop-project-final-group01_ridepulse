package com.ridepulse.backend.config;

import com.ridepulse.backend.entity.User;
import com.ridepulse.backend.entity.User.UserRole;
import com.ridepulse.backend.repository.BusOwnerRepository;
import com.ridepulse.backend.repository.StaffRepository;
import com.ridepulse.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Spring Security hook that turns an email address into a fully-populated
 * {@link CustomUserDetails} principal.
 *
 * <p>Called automatically by Spring's authentication machinery on every login
 * and on every JWT-authenticated request (via {@link JwtAuthFilter}).
 *
 * <p>OOP Polymorphism — the switch on {@code role} resolves a different
 * secondary ID per user type without any if-else chains in calling code.</p>
 */
@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    // Encapsulation: only this service touches these repos for auth purposes
    private final UserRepository     userRepo;
    private final BusOwnerRepository busOwnerRepo;
    private final StaffRepository    staffRepo;

    /**
     * Loads a {@link CustomUserDetails} from the database by email.
     *
     * <p>Polymorphism: the resolution branch is selected by the user's role:
     * <ul>
     *   <li>{@code bus_owner}  → resolves {@code ownerId} from bus_owners table</li>
     *   <li>{@code driver} / {@code conductor} → resolves {@code staffId} from staff table</li>
     *   <li>{@code passenger} / {@code authority} → no secondary ID needed</li>
     * </ul>
     *
     * @param email used as the Spring Security "username"
     * @throws UsernameNotFoundException when no user exists with that email
     */
    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {

        // Step 1 — load the base user row (Abstraction: hides the SQL)
        User user = userRepo.findByEmail(email)
                .orElseThrow(() ->
                        new UsernameNotFoundException("No account found for: " + email));

        // Step 2 — Polymorphism: resolve the role-specific secondary ID
        Integer ownerId = null;
        Integer staffId = null;

        UserRole role = user.getRole();

        if (role == UserRole.bus_owner) {
            // Encapsulation: ownerId is resolved once here and cached in the principal
            ownerId = busOwnerRepo
                    .findByUser(user)
                    .map(owner -> owner.getOwnerId())
                    .orElseThrow(() ->
                            new UsernameNotFoundException(
                                    "Bus owner profile not found for user: " + email));

        } else if (role == UserRole.driver || role == UserRole.conductor) {
            // Polymorphism: same branch handles both staff types
            staffId = staffRepo
                    .findByUser_UserId(user.getUserId())
                    .map(staff -> staff.getStaffId())
                    .orElseThrow(() ->
                            new UsernameNotFoundException(
                                    "Staff profile not found for user: " + email));
        }

        // Step 3 — Encapsulation: assemble the principal — callers never see this logic
        return new CustomUserDetails(user, ownerId, staffId);
    }
}