package com.ridepulse.backend.service.impl;

import com.ridepulse.backend.dto.*;
import com.ridepulse.backend.entity.*;
import com.ridepulse.backend.repository.*;
import com.ridepulse.backend.service.RouteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RouteServiceImpl implements RouteService {

    private final RouteRepository     routeRepo;
    private final RouteStopRepository stopRepo;

    @Override
    public List<RouteDropdownDTO> getAllActiveRoutes() {
        return routeRepo.findByIsActiveTrueOrderByRouteNumber().stream()
                .map(r -> RouteDropdownDTO.builder()
                        .routeId(r.getRouteId())
                        .routeNumber(r.getRouteNumber())
                        .routeName(r.getRouteName())
                        .startLocation(r.getStartLocation())
                        .endLocation(r.getEndLocation())
                        .baseFare(r.getBaseFare())
                        .totalDistanceKm(r.getTotalDistanceKm() != null
                                ? r.getTotalDistanceKm().doubleValue() : null)
                        .build())
                .collect(Collectors.toList());
    }

    @Override
    public RouteDetailDTO getRouteById(Integer routeId) {
        Route route = routeRepo.findById(routeId)
                .orElseThrow(() -> new RuntimeException("Route not found"));

        List<RouteStopDTO> stops = stopRepo.findByRouteOrderByStopSequence(route)
                .stream()
                .map(s -> RouteStopDTO.builder()
                        .stopId(s.getStopId())
                        .stopName(s.getStopName())
                        .stopSequence(s.getStopSequence())
                        .latitude(s.getLatitude().doubleValue())
                        .longitude(s.getLongitude().doubleValue())
                        .build())
                .collect(Collectors.toList());

        return RouteDetailDTO.builder()
                .routeId(route.getRouteId())
                .routeNumber(route.getRouteNumber())
                .routeName(route.getRouteName())
                .startLocation(route.getStartLocation())
                .endLocation(route.getEndLocation())
                .baseFare(route.getBaseFare())
                .totalDistanceKm(route.getTotalDistanceKm() != null
                        ? route.getTotalDistanceKm().doubleValue() : null)
                .isActive(route.getIsActive())
                .stops(stops)
                .build();
    }
}