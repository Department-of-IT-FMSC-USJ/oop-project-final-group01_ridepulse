package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.MonthlyRevenueSummary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * OOP Abstraction: Monthly financial summary lookup — hides aggregation SQL.
 * Used by: RevenueServiceImpl, WelfareServiceImpl, DashboardServiceImpl
 */
@Repository
public interface MonthlyRevenueSummaryRepository extends JpaRepository<MonthlyRevenueSummary, Integer> {

    // Used by: RevenueServiceImpl.getMonthlyRevenue() — single bus detail
    Optional<MonthlyRevenueSummary> findByBus_BusIdAndSummaryMonthAndSummaryYear(
            Integer busId, Integer summaryMonth, Integer summaryYear);

    // Used by: RevenueServiceImpl.getAllBusesMonthlyRevenue() — all buses for owner
    @Query("""
        SELECT m FROM MonthlyRevenueSummary m
        WHERE m.owner.ownerId = :ownerId
          AND m.summaryMonth = :month
          AND m.summaryYear = :year
        ORDER BY m.bus.busNumber
        """)
    List<MonthlyRevenueSummary> findAllByOwnerAndMonthYear(
            @Param("ownerId") Integer ownerId,
            @Param("month") Integer month,
            @Param("year") Integer year);

    // Used by: DashboardServiceImpl — combined net profit across all owner's buses this month
    @Query("""
        SELECT COALESCE(SUM(m.netProfit), 0) FROM MonthlyRevenueSummary m
        WHERE m.owner.ownerId = :ownerId
          AND m.summaryMonth = :month
          AND m.summaryYear = :year
        """)
    BigDecimal sumNetProfitByOwnerAndMonth(
            @Param("ownerId") Integer ownerId,
            @Param("month") Integer month,
            @Param("year") Integer year);

    // Used by: DashboardServiceImpl — combined welfare totals for dashboard header
    @Query("""
        SELECT COALESCE(SUM(m.driverWelfareAmount), 0) FROM MonthlyRevenueSummary m
        WHERE m.owner.ownerId = :ownerId
          AND m.summaryMonth = :month
          AND m.summaryYear = :year
        """)
    BigDecimal sumDriverWelfareByOwnerAndMonth(
            @Param("ownerId") Integer ownerId,
            @Param("month") Integer month,
            @Param("year") Integer year);

    @Query("""
        SELECT COALESCE(SUM(m.conductorWelfareAmount), 0) FROM MonthlyRevenueSummary m
        WHERE m.owner.ownerId = :ownerId
          AND m.summaryMonth = :month
          AND m.summaryYear = :year
        """)
    BigDecimal sumConductorWelfareByOwnerAndMonth(
            @Param("ownerId") Integer ownerId,
            @Param("month") Integer month,
            @Param("year") Integer year);
}