package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.DutyRoster;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

/**
 * OOP Encapsulation: Duty/attendance query logic is hidden here.
 * Used by: StaffManagementServiceImpl (duty day count), future DutyRosterService
 */
@Repository
public interface DutyRosterRepository extends JpaRepository<DutyRoster, Integer> {

    // Used by: StaffManagementServiceImpl.buildStaffProfileDTO()
    // Counts scheduled/completed duty days for a staff member in a given month
    @Query("""
        SELECT COUNT(r) FROM DutyRoster r
        WHERE r.staff.staffId = :staffId
          AND MONTH(r.dutyDate) = :month
          AND YEAR(r.dutyDate) = :year
          AND r.status IN ('active', 'completed')
        """)
    Integer countDutyDaysForStaffInMonth(
            @Param("staffId") Integer staffId,
            @Param("month") Integer month,
            @Param("year") Integer year);

    // Used by: DutyRosterService (future) — get roster by bus for a specific date
    List<DutyRoster> findByBus_BusIdAndDutyDate(Integer busId, LocalDate dutyDate);

    // Used by: Driver/Conductor home screen — today's roster for logged-in staff
    List<DutyRoster> findByStaff_StaffIdAndDutyDateOrderByShiftStart(
            Integer staffId, LocalDate dutyDate);

    // Used by: BusOwner — roster view for a date range
    @Query("""
        SELECT r FROM DutyRoster r
        JOIN FETCH r.staff s
        JOIN FETCH s.user
        WHERE r.bus.busId = :busId
          AND r.dutyDate BETWEEN :from AND :to
        ORDER BY r.dutyDate, r.shiftStart
        """)
    List<DutyRoster> findByBusAndDateRange(
            @Param("busId") Integer busId,
            @Param("from") LocalDate from,
            @Param("to") LocalDate to);
}