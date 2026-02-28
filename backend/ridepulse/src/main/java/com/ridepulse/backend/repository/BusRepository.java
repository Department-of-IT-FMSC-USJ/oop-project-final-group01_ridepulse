package com.ridepulse.backend.repository;

import com.ridepulse.backend.model.Bus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface BusRepository extends JpaRepository<Bus, Integer> {

    Optional<Bus> findByBusNumber(String busNumber);

    List<Bus> findByRouteRouteId(Integer routeId);

    List<Bus> findByIsActiveTrue();
}