package com.ridepulse.backend.dto.auth;

import lombok.*;

/**
 * OOP Encapsulation: token + role returned to client.
 * Flutter reads 'role' to navigate to role-specific home screen.
 */
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class AuthResponse {
    private String  accessToken;
    private String  role;           // "passenger" | "driver" | "conductor" | "bus_owner" | "authority"
    private String  fullName;
    private String  email;
    private Integer ownerId;        // Only for bus_owner
    private Integer staffId;        // Only for driver/conductor
}