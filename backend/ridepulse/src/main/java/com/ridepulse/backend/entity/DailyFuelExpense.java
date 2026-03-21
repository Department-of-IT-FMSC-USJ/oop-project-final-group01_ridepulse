package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "daily_fuel_expense",
        uniqueConstraints = @UniqueConstraint(columnNames = {"bus_id", "expense_date"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DailyFuelExpense {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "fuel_id")
    private Integer fuelId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_id", nullable = false)
    private Bus bus;

    @Column(name = "expense_date", nullable = false)
    private LocalDate expenseDate;

    @Column(name = "fuel_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal fuelAmount = BigDecimal.ZERO;

    @Column(name = "entered_by")
    private UUID enteredBy;   // UUID of the bus owner who entered it

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}