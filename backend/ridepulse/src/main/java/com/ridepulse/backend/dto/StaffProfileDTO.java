package com.ridepulse.backend.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class StaffProfileDTO {
    private Integer staffId;
    private String fullName;
    private String phone;
    private String nicNumber;             // From User entity (as NIC = phone for demo)
    private String employeeId;
    private String staffType;             // "driver" or "conductor"
    private String licenseNumber;         // Null for conductors
    private LocalDate licenseExpiry;      // Null for conductors
    private LocalDate dateOfJoining;
    private BigDecimal baseSalary;
    private Boolean isActive;
    private String assignedBusNumber;     // Current bus assignment
    private Integer dutyDaysThisMonth;    // Attendance count
    private BigDecimal welfareBalanceThisMonth;   // Current month welfare so far
    private BigDecimal cumulativeWelfareBalance;  // All-time welfare balance
}