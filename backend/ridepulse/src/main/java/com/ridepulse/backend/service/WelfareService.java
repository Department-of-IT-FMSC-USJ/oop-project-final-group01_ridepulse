package com.ridepulse.backend.service;

import com.ridepulse.backend.dto.StaffProfileDTO;
import java.util.List;

/**
 * OOP Abstraction: Welfare calculation contract.
 * Impl uses StaffType.getWelfareRate() — Polymorphism.
 */
public interface WelfareService {
    /**
     * Called by @Scheduled job on the 1st of every month.
     * Calculates and persists welfare for all staff per bus for prior month.
     */
    void processMonthlyWelfare(int month, int year);

    List<StaffProfileDTO> getStaffWelfareSummary(Integer ownerId, int month, int year);
}