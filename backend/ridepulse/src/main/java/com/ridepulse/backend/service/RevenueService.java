package com.ridepulse.backend.service;

import com.ridepulse.backend.dto.*;
import java.util.List;

/**
 * OOP Abstraction: Revenue operations contract.
 * Separated from welfare — single responsibility principle.
 */
public interface RevenueService {
    void recordDailyFuel(DailyFuelRequest request);
    void setMaintenanceConfig(MaintenanceConfigRequest request, Integer ownerId);
    MonthlyRevenueDTO getMonthlyRevenue(Integer busId, int month, int year, Integer ownerId);
    List<MonthlyRevenueDTO> getAllBusesMonthlyRevenue(Integer ownerId, int month, int year);
}