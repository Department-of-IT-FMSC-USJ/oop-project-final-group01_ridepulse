package com.ridepulse.backend.dto;

// ============================================================
// CONDUCTOR MODULE — ALL DTOs
// OOP Encapsulation: each DTO exposes only what the conductor
//     app needs, hiding internal entity relationships.
// ============================================================

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.List;

// ── TicketDTO ────────────────────────────────────────────────
// Returned to conductor after issuing a ticket — includes QR
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class TicketDTO {
    private Long    ticketId;
    private String  ticketNumber;     // e.g. TKT-20250115-00042
    private String  qrCode;           // Base64 payload — Flutter renders as QR image
    private String  boardingStop;
    private String  alightingStop;
    private Double  fareAmount;
    private String  paymentMethod;
    private String  ticketStatus;     // active | used | expired
    private String  issuedAt;
}