package com.ridepulse.backend.service;

import com.ridepulse.backend.dto.*;
import java.math.BigDecimal;
import java.util.List;

/**
 * OOP Abstraction: Declares the contract for staff management.
 * Bus Owner module uses this interface — never the concrete impl.
 */
public interface StaffManagementService {
    List<StaffProfileDTO> getStaffByOwner(Integer ownerId);
    StaffProfileDTO getStaffProfile(Integer staffId, Integer ownerId);
    void toggleStaffStatus(ToggleStaffStatusRequest request, Integer ownerId);
    void updateBaseSalary(UpdateSalaryRequest request, Integer ownerId);
    void assignStaffToBus(StaffAssignRequest request, Integer ownerId);
    void unassignStaff(Integer staffId, Integer ownerId);
}