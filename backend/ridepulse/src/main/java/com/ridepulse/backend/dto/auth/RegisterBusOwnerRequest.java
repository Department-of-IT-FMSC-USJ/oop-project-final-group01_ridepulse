package com.ridepulse.backend.dto.auth;

import jakarta.validation.constraints.*;
import lombok.*;

/** Encapsulation: includes business-specific fields */
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class RegisterBusOwnerRequest {
    @NotBlank  private String fullName;
    @Email     private String email;
    @NotBlank  private String phone;
    @Size(min=8) private String password;
    @NotBlank  private String businessName;
    @NotBlank  private String nicNumber;
    private String address;
}