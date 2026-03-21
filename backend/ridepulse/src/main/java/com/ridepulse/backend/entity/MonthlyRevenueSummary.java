package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "monthly_revenue_summary",
        uniqueConstraints = @UniqueConstraint(columnNames = {"bus_id", "summary_month", "summary_year"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MonthlyRevenueSummary {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "summary_id")
    private Integer summaryId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_id", nullable = false)
    private Bus bus;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private BusOwner owner;

    @Column(name = "summary_month", nullable = false)
    private Integer summaryMonth;

    @Column(name = "summary_year", nullable = false)
    private Integer summaryYear;

    // === Revenue breakdown (Encapsulation: each component stored separately) ===
    @Column(name = "gross_revenue",         precision = 12, scale = 2)
    private BigDecimal grossRevenue          = BigDecimal.ZERO;

    @Column(name = "total_fuel_cost",        precision = 12, scale = 2)
    private BigDecimal totalFuelCost         = BigDecimal.ZERO;

    @Column(name = "maintenance_cost",       precision = 12, scale = 2)
    private BigDecimal maintenanceCost       = BigDecimal.ZERO;

    @Column(name = "total_staff_salaries",   precision = 12, scale = 2)
    private BigDecimal totalStaffSalaries    = BigDecimal.ZERO;

    @Column(name = "net_profit",             precision = 12, scale = 2)
    private BigDecimal netProfit             = BigDecimal.ZERO;

    // Welfare allocations — Polymorphism: rate differs by staff type
    @Column(name = "driver_welfare_amount",    precision = 12, scale = 2)
    private BigDecimal driverWelfareAmount   = BigDecimal.ZERO;   // netProfit * 3%

    @Column(name = "conductor_welfare_amount", precision = 12, scale = 2)
    private BigDecimal conductorWelfareAmount= BigDecimal.ZERO;   // netProfit * 2%

    @Column(name = "is_finalized")
    private Boolean isFinalized = false;

    @Column(name = "generated_at", updatable = false)
    private LocalDateTime generatedAt = LocalDateTime.now();
}


// ============================================================
// FILE: entity/StaffWelfareBalance.java
// OOP: Encapsulation — tracks each staff member's welfare per month
//      and maintains a running cumulative balance.
// ============================================================
