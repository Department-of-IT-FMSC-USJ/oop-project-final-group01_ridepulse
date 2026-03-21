package com.ridepulse.backend.service.impl;

import com.ridepulse.backend.dto.StaffProfileDTO;
import com.ridepulse.backend.entity.*;
import com.ridepulse.backend.entity.Staff.StaffType;
import com.ridepulse.backend.repository.*;
import com.ridepulse.backend.service.WelfareService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class WelfareServiceImpl implements WelfareService {

    private final BusRepository busRepo;
    private final StaffBusAssignmentRepository assignmentRepo;
    private final StaffWelfareBalanceRepository welfareRepo;
    private final MonthlyRevenueSummaryRepository monthlyRepo;
    private final DailyRevenueRepository dailyRevenueRepo;
    private final DailyFuelExpenseRepository fuelRepo;
    private final BusMaintenanceConfigRepository maintenanceRepo;

    /**
     * Scheduled job: runs on the 1st of every month at midnight.
     * OOP Polymorphism: StaffType.getWelfareRate() resolves rate per type.
     * OOP Abstraction: Callers only know "welfare is processed" — not how.
     */
    @Scheduled(cron = "0 0 0 1 * *")   // 1st of every month, midnight
    @Override
    @Transactional
    public void processMonthlyWelfare(int month, int year) {
        log.info("Processing welfare for {}/{}", month, year);

        List<Bus> allBuses = busRepo.findAll();

        for (Bus bus : allBuses) {
            try {
                processBusWelfare(bus, month, year);
            } catch (Exception e) {
                log.error("Welfare processing failed for bus {}: {}", bus.getBusId(), e.getMessage());
            }
        }
    }

    /**
     * Core calculation per bus — Encapsulation: formula is private.
     *
     * Formula:
     *   grossRevenue  = SUM(daily_revenue.total_revenue for month)
     *   totalFuel     = SUM(daily_fuel_expense.fuel_amount for month)
     *   maintenance   = bus_maintenance_config.monthly_amount
     *   salaries      = SUM(staff.base_salary) for staff assigned this month
     *   netProfit     = grossRevenue - totalFuel - maintenance - salaries
     *   driverWelfare = netProfit * 3%    (Polymorphism: driver rate)
     *   condWelfare   = netProfit * 2%    (Polymorphism: conductor rate)
     */
    private void processBusWelfare(Bus bus, int month, int year) {
        // Step 1: Gross revenue from ticket sales this month
        BigDecimal grossRevenue = dailyRevenueRepo
                .sumRevenueForBusInMonth(bus.getBusId(), month, year);
        grossRevenue = nullSafe(grossRevenue);

        // Step 2: Total fuel cost for the month
        BigDecimal totalFuel = fuelRepo
                .sumFuelForBusInMonth(bus.getBusId(), month, year);
        totalFuel = nullSafe(totalFuel);

        // Step 3: Fixed monthly maintenance amount (set by owner)
        BigDecimal maintenance = maintenanceRepo.findByBus(bus)
                .map(BusMaintenanceConfig::getMonthlyAmount)
                .orElse(BigDecimal.ZERO);

        // Step 4: Sum of base salaries of staff currently assigned to this bus
        List<StaffBusAssignment> assignments =
                assignmentRepo.findCurrentAssignmentsByBus(bus.getBusId());

        BigDecimal totalSalaries = assignments.stream()
                .map(a -> nullSafe(a.getStaff().getBaseSalary()))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // Step 5: Net profit
        BigDecimal netProfit = grossRevenue
                .subtract(totalFuel)
                .subtract(maintenance)
                .subtract(totalSalaries);

        // Prevent negative welfare (protect against loss months)
        if (netProfit.compareTo(BigDecimal.ZERO) < 0) {
            netProfit = BigDecimal.ZERO;
        }

        // Step 6: Welfare per staff type — Polymorphism in action
        BigDecimal driverWelfare    = BigDecimal.ZERO;
        BigDecimal conductorWelfare = BigDecimal.ZERO;
        long driverCount    = assignments.stream().filter(a -> a.getStaff().getStaffType() == StaffType.driver).count();
        long conductorCount = assignments.stream().filter(a -> a.getStaff().getStaffType() == StaffType.conductor).count();

        if (driverCount > 0) {
            // Total driver welfare pool ÷ number of drivers
            BigDecimal totalDriverPool = netProfit.multiply(StaffType.driver.getWelfareRate());
            driverWelfare = totalDriverPool.divide(BigDecimal.valueOf(driverCount), 2, java.math.RoundingMode.HALF_UP);
        }
        if (conductorCount > 0) {
            BigDecimal totalConductorPool = netProfit.multiply(StaffType.conductor.getWelfareRate());
            conductorWelfare = totalConductorPool.divide(BigDecimal.valueOf(conductorCount), 2, java.math.RoundingMode.HALF_UP);
        }

        // Step 7: Save monthly summary
        MonthlyRevenueSummary summary = monthlyRepo
                .findByBus_BusIdAndSummaryMonthAndSummaryYear(bus.getBusId(), month, year)
                .orElse(MonthlyRevenueSummary.builder().bus(bus).owner(bus.getOwner())
                        .summaryMonth(month).summaryYear(year).build());

        final BigDecimal finalNetProfit = netProfit;
        final BigDecimal finalDriverWelfare = driverWelfare;
        final BigDecimal finalConductorWelfare = conductorWelfare;

        summary.setGrossRevenue(grossRevenue);
        summary.setTotalFuelCost(totalFuel);
        summary.setMaintenanceCost(maintenance);
        summary.setTotalStaffSalaries(totalSalaries);
        summary.setNetProfit(finalNetProfit);
        summary.setDriverWelfareAmount(finalDriverWelfare.multiply(BigDecimal.valueOf(driverCount)));
        summary.setConductorWelfareAmount(finalConductorWelfare.multiply(BigDecimal.valueOf(conductorCount)));
        summary.setIsFinalized(true);
        monthlyRepo.save(summary);

        // Step 8: Distribute welfare to each staff member's balance
        for (StaffBusAssignment assignment : assignments) {
            Staff staff = assignment.getStaff();
            // Polymorphism: each staff type gets its own rate-derived amount
            BigDecimal amount = staff.getStaffType() == StaffType.driver ? driverWelfare : conductorWelfare;
            saveWelfareBalance(staff, bus, month, year, amount);
        }

        log.info("Bus {} — Net: {}, Driver welfare: {}, Conductor welfare: {}",
                bus.getBusNumber(), finalNetProfit, finalDriverWelfare, finalConductorWelfare);
    }

    /** Saves or updates a staff member's welfare balance and cumulative total */
    private void saveWelfareBalance(Staff staff, Bus bus, int month, int year, BigDecimal amount) {
        // Get previous cumulative balance (from last month's record)
        BigDecimal prevCumulative = welfareRepo
                .findLatestCumulativeBalance(staff.getStaffId(), month, year)
                .orElse(BigDecimal.ZERO);

        StaffWelfareBalance balance = welfareRepo
                .findByStaffAndMonth(staff.getStaffId(), month, year)
                .orElse(StaffWelfareBalance.builder().staff(staff).bus(bus)
                        .balanceMonth(month).balanceYear(year).build());

        balance.setWelfareAmount(amount);
        balance.setCumulativeBalance(prevCumulative.add(amount));
        welfareRepo.save(balance);
    }

    @Override
    public List<StaffProfileDTO> getStaffWelfareSummary(Integer ownerId, int month, int year) {
        // Delegate to staff management service — returns list with welfare populated
        return welfareRepo.findByOwnerAndMonth(ownerId, month, year)
                .stream()
                .map(b -> StaffProfileDTO.builder()
                        .staffId(b.getStaff().getStaffId())
                        .fullName(b.getStaff().getUser().getFullName())
                        .staffType(b.getStaff().getStaffType().name())
                        .baseSalary(b.getStaff().getBaseSalary())
                        .welfareBalanceThisMonth(b.getWelfareAmount())
                        .cumulativeWelfareBalance(b.getCumulativeBalance())
                        .build())
                .collect(Collectors.toList());
    }

    // Encapsulation: null-safety helper is private
    private BigDecimal nullSafe(BigDecimal val) {
        return val != null ? val : BigDecimal.ZERO;
    }
}