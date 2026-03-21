package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.DailyRevenue;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * OOP Abstraction: Daily revenue aggregation — used by welfare job and dashboard.
 * Used by: WelfareServiceImpl, RevenueServiceImpl
 */
@Repository
public interface DailyRevenueRepository extends JpaRepository<DailyRevenue, Integer> {

    // Used by: RevenueServiceImpl — upsert daily record
    Optional<DailyRevenue> findByBus_BusIdAndRevenueDate(
            Integer busId, LocalDate revenueDate);

    // Used by: WelfareServiceImpl.processBusWelfare() — gross revenue for month
    @Query("""
        SELECT COALESCE(SUM(r.totalRevenue), 0) FROM DailyRevenue r
        WHERE r.bus.busId = :busId
          AND MONTH(r.revenueDate) = :month
          AND YEAR(r.revenueDate) = :year
        """)
    BigDecimal sumRevenueForBusInMonth(
            @Param("busId") Integer busId,
            @Param("month") Integer month,
            @Param("year") Integer year);

    // Used by: BusOwner revenue screen — last 30 days for chart
    @Query("""
        SELECT r FROM DailyRevenue r
        WHERE r.bus.busId = :busId
          AND r.revenueDate BETWEEN :from AND :to
        ORDER BY r.revenueDate ASC
        """)
    List<DailyRevenue> findByBusAndDateRange(
            @Param("busId") Integer busId,
            @Param("from") LocalDate from,
            @Param("to") LocalDate to);

    // Used by: DashboardServiceImpl — gross revenue for current month across all owner's buses
    @Query("""
        SELECT COALESCE(SUM(r.totalRevenue), 0) FROM DailyRevenue r
        WHERE r.bus.owner.ownerId = :ownerId
          AND MONTH(r.revenueDate) = :month
          AND YEAR(r.revenueDate) = :year
        """)
    BigDecimal sumGrossRevenueByOwnerAndMonth(
            @Param("ownerId") Integer ownerId,
            @Param("month") Integer month,
            @Param("year") Integer year);
}