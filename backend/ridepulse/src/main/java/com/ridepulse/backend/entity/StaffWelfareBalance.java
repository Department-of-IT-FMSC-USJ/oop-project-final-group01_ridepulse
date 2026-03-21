package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "staff_welfare_balance",
        uniqueConstraints = @UniqueConstraint(columnNames = {"staff_id", "balance_month", "balance_year"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class StaffWelfareBalance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "balance_id")
    private Integer balanceId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "staff_id", nullable = false)
    private Staff staff;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_id", nullable = false)
    private Bus bus;

    @Column(name = "balance_month", nullable = false)
    private Integer balanceMonth;

    @Column(name = "balance_year", nullable = false)
    private Integer balanceYear;

    @Column(name = "welfare_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal welfareAmount = BigDecimal.ZERO;      // This month's allocation

    @Column(name = "cumulative_balance", nullable = false, precision = 10, scale = 2)
    private BigDecimal cumulativeBalance = BigDecimal.ZERO;  // Running total

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}