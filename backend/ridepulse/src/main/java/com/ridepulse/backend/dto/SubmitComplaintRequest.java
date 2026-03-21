package com.ridepulse.backend.dto;

// ============================================================
// SubmitComplaintRequest.java
// Used by: Passenger when submitting a new complaint
// OOP Encapsulation: only fields a passenger can provide
// ============================================================

import jakarta.validation.constraints.*;
import lombok.*;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class SubmitComplaintRequest {

    // Optional: passenger may not know the exact bus number
    private Integer busId;

    private Integer tripId;

    @NotBlank(message = "Category is required")
    @Pattern(
            regexp = "crowding|driver_behavior|delay|cleanliness|safety|other",
            message = "Invalid category"
    )
    private String category;

    @NotBlank(message = "Description is required")
    @Size(min = 10, max = 1000, message = "Description must be 10–1000 characters")
    private String description;

    // Optional: URL of uploaded photo
    private String photoUrl;
}
