package com.ridepulse.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "bus_owners")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BusOwner {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "owner_id")
    private Integer ownerId;

    // Inheritance via composition: BusOwner extends User identity through FK
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", referencedColumnName = "user_id", unique = true)
    private User user;

    @Column(name = "business_name", length = 150)
    private String businessName;

    @Column(name = "nic_number", unique = true, nullable = false, length = 20)
    private String nicNumber;

    @Column(name = "address")
    private String address;

    // Aggregation: BusOwner owns many Buses — they can exist independently
    @OneToMany(mappedBy = "owner", fetch = FetchType.LAZY)
    private List<Bus> buses;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}