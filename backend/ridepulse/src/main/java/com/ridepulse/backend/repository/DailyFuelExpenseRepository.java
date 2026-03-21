package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.DailyFuelExpense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;

/**
 * OOP Encapsulation: Fuel cost aggregation logic hidden from services.
 * Used by: RevenueServiceImpl, WelfareServiceImpl
 */
@Repository
public interface DailyFuelExpenseRepository extends JpaRepository<DailyFuelExpense, Integer> {

    // Used by: RevenueServiceImpl.recordDailyFuel() — upsert: check if entry exists
    Optional<DailyFuelExpense> findByBus_BusIdAndExpenseDate(
            Integer busId, LocalDate expenseDate);

    // Used by: WelfareServiceImpl.processBusWelfare() — total fuel for the month
    @Query("""
        SELECT COALESCE(SUM(f.fuelAmount), 0) FROM DailyFuelExpense f
        WHERE f.bus.busId = :busId
          AND MONTH(f.expenseDate) = :month
          AND YEAR(f.expenseDate) = :year
        """)
    BigDecimal sumFuelForBusInMonth(
            @Param("busId") Integer busId,
            @Param("month") Integer month,
            @Param("year") Integer year);
}