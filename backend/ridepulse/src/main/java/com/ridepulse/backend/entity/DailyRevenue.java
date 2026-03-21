package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.*;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "daily_revenue",
        uniqueConstraints = @UniqueConstraint(
                columnNames = {"bus_id", "revenue_date"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DailyRevenue {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "revenue_id")
    private Integer revenueId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_id", nullable = false)
    private Bus bus;

    // Denormalized for fast owner-scoped queries
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private BusOwner owner;

    // Named revenueDate to match: findByBus_BusIdAndRevenueDate
    @Column(name = "revenue_date", nullable = false)
    private LocalDate revenueDate;

    @Column(name = "total_tickets_sold")
    private Integer totalTicketsSold = 0;

    @Column(name = "cash_collection", precision = 10, scale = 2)
    private BigDecimal cashCollection = BigDecimal.ZERO;

    @Column(name = "digital_collection", precision = 10, scale = 2)
    private BigDecimal digitalCollection = BigDecimal.ZERO;

    // totalRevenue = cashCollection + digitalCollection
    @Column(name = "total_revenue", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalRevenue = BigDecimal.ZERO;

    @Column(name = "refunds", precision = 10, scale = 2)
    private BigDecimal refunds = BigDecimal.ZERO;

    // netRevenue = totalRevenue - refunds
    @Column(name = "net_revenue", nullable = false, precision = 10, scale = 2)
    private BigDecimal netRevenue = BigDecimal.ZERO;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
