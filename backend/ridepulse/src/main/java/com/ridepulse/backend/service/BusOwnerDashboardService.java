package com.ridepulse.backend.service;

import com.ridepulse.backend.dto.*;
import java.util.List;

/** OOP Abstraction: Dashboard data aggregation contract. */
public interface BusOwnerDashboardService {
    BusOwnerDashboardDTO getDashboard(Integer ownerId);
    List<ComplaintSummaryDTO> getComplaints(Integer ownerId, String status);
    List<BusLocationDTO> getLiveBusLocations(Integer ownerId);
}