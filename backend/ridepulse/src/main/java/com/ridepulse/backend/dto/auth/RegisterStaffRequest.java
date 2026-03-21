package com.ridepulse.backend.dto.auth;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Used by Bus Owner to register a Driver or Conductor.
 * OOP Polymorphism: same DTO handles both staff types — staffType field drives behavior.
 */
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class RegisterStaffRequest {
    @NotBlank  private String fullName;
    @Email     private String email;
    @NotBlank  private String phone;
    @Size(min=8) private String password;       // Owner sets initial password for staff

    @NotBlank
    @Pattern(regexp = "driver|conductor")
    private String staffType;                   // "driver" or "conductor"

    @NotBlank  private String employeeId;
    @NotNull   private LocalDate dateOfJoining;
    private String  licenseNumber;              // Required only for driver
    private LocalDate licenseExpiry;            // Required only for driver
    private BigDecimal baseSalary;
    private Integer busId;                      // Optional: assign to bus immediately
}
