package com.ridepulse.backend.dto.auth;

import jakarta.validation.constraints.*;
import lombok.*;

/** Shared login request — all roles use same endpoint */
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class LoginRequest {
    @Email     private String email;
    @NotBlank  private String password;
}