package com.ridepulse.backend.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * Base Entity - Demonstrates ABSTRACTION (OOP Concept)
 * This abstract class contains common fields for all entities
 * Promotes code reusability and follows DRY principle
 */
@Data
@MappedSuperclass
public abstract class BaseEntity {

    /**
     * Encapsulation: Private fields with public getters/setters via Lombok
     */
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    /**
     * Lifecycle callback - automatically sets creation timestamp
     */
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    /**
     * Lifecycle callback - automatically updates timestamp
     */
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}