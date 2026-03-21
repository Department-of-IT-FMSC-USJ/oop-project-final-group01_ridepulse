package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "bus_maintenance_config")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BusMaintenanceConfig {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "config_id")
    private Integer configId;

    // One-to-one: each bus has exactly one maintenance cost config
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_id", unique = true, nullable = false)
    private Bus bus;

    @Column(name = "monthly_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal monthlyAmount = BigDecimal.ZERO;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    @PreUpdate
    public void onUpdate() { this.updatedAt = LocalDateTime.now(); }
}