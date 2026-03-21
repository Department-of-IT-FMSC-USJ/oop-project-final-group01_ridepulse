package com.ridepulse.backend.service.impl;

import com.ridepulse.backend.dto.*;
import com.ridepulse.backend.entity.*;
import com.ridepulse.backend.repository.*;
import com.ridepulse.backend.service.BusManagementService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BusManagementServiceImpl implements BusManagementService {

    private final BusRepository              busRepo;
    private final BusOwnerRepository         ownerRepo;
    private final RouteRepository            routeRepo;
    private final StaffBusAssignmentRepository assignmentRepo;

    @Override
    @Transactional
    public BusDetailDTO addBus(CreateBusRequest req, Integer ownerId) {
        BusOwner owner = ownerRepo.findById(ownerId)
                .orElseThrow(() -> new RuntimeException("Owner not found"));

        Route route = routeRepo.findById(req.getRouteId())
                .orElseThrow(() -> new RuntimeException("Route not found"));

        // Validate bus number uniqueness
        if (busRepo.existsByBusNumber(req.getBusNumber())) {
            throw new RuntimeException("Bus number already registered: " + req.getBusNumber());
        }

        Bus bus = Bus.builder()
                .busNumber(req.getBusNumber())
                .registrationNumber(req.getRegistrationNumber())
                .owner(owner)
                .route(route)
                .capacity(req.getCapacity())
                .model(req.getModel())
                .yearManufactured(req.getYearManufactured())
                .hasGps(req.getHasGps() != null ? req.getHasGps() : true)
                .isActive(true)
                .build();

        busRepo.save(bus);
        return toBusDetailDTO(bus);
    }

    /**
     * Soft delete: sets is_active = false.
     * Encapsulation: bus history is preserved — not truly deleted.
     */
    @Override
    @Transactional
    public void deleteBus(Integer busId, Integer ownerId) {
        Bus bus = findBusOwnedBy(busId, ownerId);
        bus.setIsActive(false);
        busRepo.save(bus);
    }

    @Override
    @Transactional
    public BusDetailDTO updateBusRoute(UpdateBusRouteRequest req, Integer ownerId) {
        Bus bus = findBusOwnedBy(req.getBusId(), ownerId);

        Route route = routeRepo.findById(req.getRouteId())
                .orElseThrow(() -> new RuntimeException("Route not found"));

        bus.setRoute(route);
        busRepo.save(bus);
        return toBusDetailDTO(bus);
    }

    @Override
    public List<BusDetailDTO> getBusesByOwner(Integer ownerId) {
        return busRepo.findByOwner_OwnerIdAndIsActiveTrueOrderByBusNumber(ownerId)
                .stream()
                .map(this::toBusDetailDTO)
                .collect(Collectors.toList());
    }

    @Override
    public BusDetailDTO getBusById(Integer busId, Integer ownerId) {
        return toBusDetailDTO(findBusOwnedBy(busId, ownerId));
    }

    // ── Private helpers (Encapsulation) ──────────────────────

    /** Security: validates bus belongs to this owner before any operation */
    private Bus findBusOwnedBy(Integer busId, Integer ownerId) {
        Bus bus = busRepo.findById(busId)
                .orElseThrow(() -> new RuntimeException("Bus not found"));
        if (!bus.getOwner().getOwnerId().equals(ownerId)) {
            throw new RuntimeException("Unauthorized: bus does not belong to this owner");
        }
        return bus;
    }

    private BusDetailDTO toBusDetailDTO(Bus bus) {
        // Resolve current driver and conductor assigned to this bus
        List<StaffBusAssignment> assignments =
                assignmentRepo.findCurrentAssignmentsByBus(bus.getBusId());

        String driverName = assignments.stream()
                .filter(a -> a.getStaff().getStaffType() == Staff.StaffType.driver)
                .findFirst()
                .map(a -> a.getStaff().getUser().getFullName())
                .orElse("Unassigned");

        String conductorName = assignments.stream()
                .filter(a -> a.getStaff().getStaffType() == Staff.StaffType.conductor)
                .findFirst()
                .map(a -> a.getStaff().getUser().getFullName())
                .orElse("Unassigned");

        RouteDropdownDTO routeDTO = bus.getRoute() != null
                ? RouteDropdownDTO.builder()
                .routeId(bus.getRoute().getRouteId())
                .routeNumber(bus.getRoute().getRouteNumber())
                .routeName(bus.getRoute().getRouteName())
                .startLocation(bus.getRoute().getStartLocation())
                .endLocation(bus.getRoute().getEndLocation())
                .baseFare(bus.getRoute().getBaseFare())
                .build()
                : null;

        return BusDetailDTO.builder()
                .busId(bus.getBusId())
                .busNumber(bus.getBusNumber())
                .registrationNumber(bus.getRegistrationNumber())
                .capacity(bus.getCapacity())
                .model(bus.getModel())
                .yearManufactured(bus.getYearManufactured())
                .hasGps(bus.getHasGps())
                .isActive(bus.getIsActive())
                .route(routeDTO)
                .assignedDriverName(driverName)
                .assignedConductorName(conductorName)
                .build();
    }
}