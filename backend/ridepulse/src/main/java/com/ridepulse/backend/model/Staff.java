package com.ridepulse.backend.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

/**
 * Driver Entity - Demonstrates INHERITANCE
 */
@Entity
@Table(name = "staff")
@Data
@NoArgsConstructor
public class Staff {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "staff_id")
    private Integer staffId;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "staff_type", nullable = false)
    private String staffType; // driver or conductor

    @Column(name = "employee_id", nullable = false)
    private String employeeId;

    @Column(name = "license_number")
    private String licenseNumber;

    @Column(name = "license_expiry")
    private java.time.LocalDate licenseExpiry;

    @Column(name = "is_active")
    private Boolean isActive = true;
}
