package com.ridepulse.backend.service.impl;

import com.ridepulse.backend.model.Route;
import com.ridepulse.backend.repository.RouteRepository;
import com.ridepulse.backend.service.RouteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class RouteServiceImpl implements RouteService {

    private final RouteRepository routeRepository;

    @Override
    public Route createRoute(Route route) {
        return routeRepository.save(route);
    }

    @Override
    public Optional<Route> getRouteById(Integer routeId) {
        return routeRepository.findById(routeId);
    }

    @Override
    public List<Route> getAllRoutes() {
        return routeRepository.findAll();
    }

    @Override
    public List<Route> getActiveRoutes() {
        return routeRepository.findByIsActiveTrue();
    }

    @Override
    public Route updateRoute(Integer routeId, Route updatedRoute) {
        return routeRepository.findById(routeId)
                .map(existing -> {
                    existing.setRouteName(updatedRoute.getRouteName());
                    existing.setBaseFare(updatedRoute.getBaseFare());
                    return routeRepository.save(existing);
                })
                .orElseThrow(() -> new RuntimeException("Route not found"));
    }

    @Override
    public void deleteRoute(Integer routeId) {
        routeRepository.deleteById(routeId);
    }

    @Override
    public Double calculateETA(Integer routeId) {
        return routeRepository.findById(routeId)
                .map(route -> route.calculateETA().doubleValue())
                .orElseThrow(() -> new RuntimeException("Route not found"));
    }
}