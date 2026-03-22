package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.StaffWelfareBalance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * OOP Encapsulation: Welfare balance lookups — cumulative calculation hidden.
 * Used by: WelfareServiceImpl, StaffManagementServiceImpl
 */
@Repository
public interface StaffWelfareBalanceRepository extends JpaRepository<StaffWelfareBalance, Integer> {

    // Used by: WelfareServiceImpl.saveWelfareBalance() — upsert this month's record
    Optional<StaffWelfareBalance> findByStaff_StaffIdAndBalanceMonthAndBalanceYear(
            Integer staffId, Integer balanceMonth, Integer balanceYear);

    // Used by: StaffManagementServiceImpl.buildStaffProfileDTO() — welfare for profile card
    @Query("""
        SELECT w FROM StaffWelfareBalance w
        WHERE w.staff.staffId = :staffId
          AND w.balanceMonth = :month
          AND w.balanceYear = :year
        """)
    Optional<StaffWelfareBalance> findByStaffAndMonth(
            @Param("staffId") Integer staffId,
            @Param("month") Integer month,
            @Param("year") Integer year);

    // Used by: WelfareServiceImpl — get most recent cumulative balance for running total
    @Query("""
        SELECT COALESCE(w.cumulativeBalance, 0) FROM StaffWelfareBalance w
        WHERE w.staff.staffId = :staffId
          AND (w.balanceYear < :year
               OR (w.balanceYear = :year AND w.balanceMonth < :month))
        ORDER BY w.balanceYear DESC, w.balanceMonth DESC
        """)
    Optional<BigDecimal> findLatestCumulativeBalance(
            @Param("staffId") Integer staffId,
            @Param("month") Integer month,
            @Param("year") Integer year);

    // Used by: WelfareService.getStaffWelfareSummary() — all staff welfare for owner in month
    @Query("""
        SELECT w FROM StaffWelfareBalance w
        JOIN FETCH w.staff s
        JOIN FETCH s.user
        WHERE w.bus.owner.ownerId = :ownerId
          AND w.balanceMonth = :month
          AND w.balanceYear = :year
        ORDER BY s.staffType, s.user.fullName
        """)
    List<StaffWelfareBalance> findByOwnerAndMonth(
            @Param("ownerId") Integer ownerId,
            @Param("month") Integer month,
            @Param("year") Integer year);

    // Used by: ConductorServiceImpl.getWelfareHistory()

    // Returns all welfare records for a staff member, newest first
    List<StaffWelfareBalance> findByStaff_StaffIdOrderByBalanceYearDescBalanceMonthDesc(
            Integer staffId);
}