package com.ridepulse.backend.dto.auth;

import jakarta.validation.constraints.*;
import lombok.*;

/** Encapsulation: only passenger-relevant fields exposed */
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class RegisterPassengerRequest {
    @NotBlank  private String fullName;
    @Email     private String email;
    @NotBlank  private String phone;
    @Size(min=8) private String password;
}