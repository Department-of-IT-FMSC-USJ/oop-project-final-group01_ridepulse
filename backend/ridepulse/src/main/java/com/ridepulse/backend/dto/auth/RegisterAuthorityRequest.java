package com.ridepulse.backend.dto.auth;

import jakarta.validation.constraints.*;
import lombok.*;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class RegisterAuthorityRequest {
    @NotBlank  private String fullName;
    @Email     private String email;
    @NotBlank  private String phone;
    @Size(min=8) private String password;
    @NotBlank  private String designation;    // e.g. "Senior Inspector"
}
