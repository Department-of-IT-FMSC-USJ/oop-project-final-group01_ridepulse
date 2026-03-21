package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.StaffBusAssignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * OOP Association: Manages the many-to-many staff ↔ bus relationship over time.
 * Encapsulation: isCurrent=true filter is always applied — callers never worry about it.
 * Used by: StaffManagementServiceImpl, WelfareServiceImpl, BusManagementServiceImpl
 */
@Repository
public interface StaffBusAssignmentRepository extends JpaRepository<StaffBusAssignment, Integer> {

    // Used by: StaffManagementServiceImpl.getStaffByOwner() — all current assignments for owner
    @Query("""
        SELECT a FROM StaffBusAssignment a
        JOIN FETCH a.staff s
        JOIN FETCH s.user
        JOIN FETCH a.bus b
        WHERE b.owner.ownerId = :ownerId
          AND a.isCurrent = true
        ORDER BY s.staffType, s.user.fullName
        """)
    List<StaffBusAssignment> findCurrentAssignmentsByOwner(@Param("ownerId") Integer ownerId);

    // Used by: BusManagementServiceImpl.toBusDetailDTO() — get staff on a specific bus
    @Query("""
        SELECT a FROM StaffBusAssignment a
        JOIN FETCH a.staff s
        JOIN FETCH s.user
        WHERE a.bus.busId = :busId
          AND a.isCurrent = true
        """)
    List<StaffBusAssignment> findCurrentAssignmentsByBus(@Param("busId") Integer busId);

    // Used by: StaffManagementServiceImpl.getStaffProfile() — security: verify ownership
    @Query("""
        SELECT a FROM StaffBusAssignment a
        WHERE a.staff.staffId = :staffId
          AND a.bus.owner.ownerId = :ownerId
          AND a.isCurrent = true
        """)
    Optional<StaffBusAssignment> findCurrentAssignmentByStaffAndOwner(
            @Param("staffId") Integer staffId,
            @Param("ownerId") Integer ownerId);

    // Used by: StaffManagementServiceImpl.assignStaffToBus() — get existing assignment to close it
    @Query("""
        SELECT a FROM StaffBusAssignment a
        WHERE a.staff.staffId = :staffId
          AND a.isCurrent = true
        """)
    Optional<StaffBusAssignment> findCurrentAssignmentByStaff(@Param("staffId") Integer staffId);

    // Used by: WelfareServiceImpl — count distinct buses this staff member worked on this month
    @Query("""
        SELECT a FROM StaffBusAssignment a
        WHERE a.staff.staffId = :staffId
          AND a.assignedDate <= :lastDayOfMonth
          AND (a.unassignedDate IS NULL OR a.unassignedDate >= :firstDayOfMonth)
        """)
    List<StaffBusAssignment> findAssignmentsForStaffInMonth(
            @Param("staffId") Integer staffId,
            @Param("firstDayOfMonth") java.time.LocalDate firstDayOfMonth,
            @Param("lastDayOfMonth") java.time.LocalDate lastDayOfMonth);
}
