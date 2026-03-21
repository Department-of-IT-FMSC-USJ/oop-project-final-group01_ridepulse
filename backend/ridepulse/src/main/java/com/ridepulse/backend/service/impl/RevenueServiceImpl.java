package com.ridepulse.backend.service.impl;

import com.ridepulse.backend.dto.*;
import com.ridepulse.backend.entity.*;
import com.ridepulse.backend.repository.*;
import com.ridepulse.backend.service.RevenueService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RevenueServiceImpl implements RevenueService {

    private final DailyFuelExpenseRepository fuelRepo;
    private final BusMaintenanceConfigRepository maintenanceRepo;
    private final MonthlyRevenueSummaryRepository monthlyRepo;
    private final BusOwnerRepository busOwnerRepo;
    private final BusRepository busRepo;

    @Override
    @Transactional
    public void recordDailyFuel(DailyFuelRequest request) {
        Bus bus = busRepo.findById(request.getBusId())
                .orElseThrow(() -> new RuntimeException("Bus not found"));

        // Upsert: if entry exists for this day, update it
        DailyFuelExpense expense = fuelRepo
                .findByBus_BusIdAndExpenseDate(request.getBusId(), request.getExpenseDate())
                .orElse(DailyFuelExpense.builder().bus(bus).expenseDate(request.getExpenseDate()).build());

        expense.setFuelAmount(request.getFuelAmount());
        fuelRepo.save(expense);
    }

    @Override
    @Transactional
    public void setMaintenanceConfig(MaintenanceConfigRequest request, Integer ownerId) {
        Bus bus = busRepo.findById(request.getBusId())
                .orElseThrow(() -> new RuntimeException("Bus not found"));

        BusMaintenanceConfig config = maintenanceRepo.findByBus(bus)
                .orElse(BusMaintenanceConfig.builder().bus(bus).build());

        config.setMonthlyAmount(request.getMonthlyAmount());
        maintenanceRepo.save(config);
    }

    @Override
    public MonthlyRevenueDTO getMonthlyRevenue(Integer busId, int month, int year, Integer ownerId) {
        MonthlyRevenueSummary summary = monthlyRepo
                .findByBus_BusIdAndSummaryMonthAndSummaryYear(busId, month, year)
                .orElseThrow(() -> new RuntimeException("No summary found for this period"));

        return toMonthlyRevenueDTO(summary);
    }

    @Override
    public List<MonthlyRevenueDTO> getAllBusesMonthlyRevenue(Integer ownerId, int month, int year) {
        return monthlyRepo.findAllByOwnerAndMonthYear(ownerId, month, year)
                .stream()
                .map(this::toMonthlyRevenueDTO)
                .collect(Collectors.toList());
    }

    // Encapsulation: mapping logic is private
    private MonthlyRevenueDTO toMonthlyRevenueDTO(MonthlyRevenueSummary s) {
        return MonthlyRevenueDTO.builder()
                .busId(s.getBus().getBusId())
                .busNumber(s.getBus().getBusNumber())
                .month(s.getSummaryMonth())
                .year(s.getSummaryYear())
                .grossRevenue(s.getGrossRevenue())
                .totalFuelCost(s.getTotalFuelCost())
                .maintenanceCost(s.getMaintenanceCost())
                .totalStaffSalaries(s.getTotalStaffSalaries())
                .netProfit(s.getNetProfit())
                .driverWelfareAmount(s.getDriverWelfareAmount())
                .conductorWelfareAmount(s.getConductorWelfareAmount())
                .isFinalized(s.getIsFinalized())
                .build();
    }
}