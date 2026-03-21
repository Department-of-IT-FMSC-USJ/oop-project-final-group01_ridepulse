package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.*;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "duty_rosters",
        uniqueConstraints = @UniqueConstraint(
                columnNames = {"staff_id", "duty_date", "shift_start"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DutyRoster {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "roster_id")
    private Integer rosterId;

    // Polymorphism: same roster entity handles both driver and conductor
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "staff_id", nullable = false)
    private Staff staff;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bus_id", nullable = false)
    private Bus bus;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "route_id", nullable = false)
    private Route route;

    @Column(name = "duty_date", nullable = false)
    private LocalDate dutyDate;

    // Named shiftStart to match: findByStaff_StaffIdAndDutyDateOrderByShiftStart
    @Column(name = "shift_start", nullable = false)
    private LocalTime shiftStart;

    @Column(name = "shift_end", nullable = false)
    private LocalTime shiftEnd;

    // Lifecycle: scheduled → active → completed / cancelled
    @Column(name = "status", length = 20)
    private String status = "scheduled";  // scheduled | active | completed | cancelled

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}

