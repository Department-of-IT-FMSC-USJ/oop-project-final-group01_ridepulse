package com.ridepulse.backend.repository;

import com.ridepulse.backend.model.Ticket;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface TicketRepository extends JpaRepository<Ticket, Long> {

    Optional<Ticket> findByTicketNumber(String ticketNumber);

    Optional<Ticket> findByQrCode(String qrCode);

    List<Ticket> findByPassengerUserId(java.util.UUID userId);
}