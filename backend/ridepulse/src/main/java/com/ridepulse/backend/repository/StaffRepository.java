package com.ridepulse.backend.repository;

import com.ridepulse.backend.entity.Staff;
import com.ridepulse.backend.entity.Staff.StaffType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * OOP Abstraction: All staff queries centralized here.
 * Polymorphism: queries filter by StaffType (driver/conductor).
 * Used by: AuthServiceImpl, StaffManagementServiceImpl, WelfareServiceImpl
 */
@Repository
public interface StaffRepository extends JpaRepository<Staff, Integer> {

    // Used by: AuthServiceImpl.login() — resolves staffId from email
    @Query("SELECT s FROM Staff s WHERE s.user.email = :email")
    Optional<Staff> findByUserEmail(@Param("email") String email);

    // Used by: AuthServiceImpl — get staff linked to a user UUID
    Optional<Staff> findByUser_UserId(UUID userId);

    // Used by: StaffManagementServiceImpl — get all staff owned by a bus owner
    // Encapsulation: navigates staff → assignment → bus → owner in one query
    @Query("""
        SELECT DISTINCT s FROM Staff s
        JOIN StaffBusAssignment a ON a.staff = s
        JOIN Bus b ON a.bus = b
        WHERE b.owner.ownerId = :ownerId
          AND a.isCurrent = true
        ORDER BY s.staffType, s.user.fullName
        """)
    List<Staff> findAllByOwnerId(@Param("ownerId") Integer ownerId);

    // Used by: StaffManagementServiceImpl — filter by type (driver or conductor)
    @Query("""
        SELECT DISTINCT s FROM Staff s
        JOIN StaffBusAssignment a ON a.staff = s
        JOIN Bus b ON a.bus = b
        WHERE b.owner.ownerId = :ownerId
          AND a.isCurrent = true
          AND s.staffType = :staffType
        """)
    List<Staff> findByOwnerIdAndStaffType(
            @Param("ownerId") Integer ownerId,
            @Param("staffType") StaffType staffType);

    // Used by: AuthServiceImpl — validate employee ID uniqueness
    boolean existsByEmployeeId(String employeeId);
}