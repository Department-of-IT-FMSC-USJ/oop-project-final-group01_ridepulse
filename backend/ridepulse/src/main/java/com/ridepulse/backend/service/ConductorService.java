package com.ridepulse.backend.service;
// ============================================================
// ConductorService.java — interface
// OOP Abstraction: defines the full conductor module contract.
//     Controllers depend only on this — never the impl.
// ============================================================

import com.ridepulse.backend.dto.*;
import java.util.List;

public interface ConductorService {

    /** Full home screen data in one call */
    ConductorDashboardDTO getDashboard(Integer staffId);

    /** Today's duty roster for this conductor */
    List<RosterDetailDTO> getTodayRosters(Integer staffId);

    /** All rosters for a specific date (YYYY-MM-DD) */
    List<RosterDetailDTO> getRostersForDate(Integer staffId, String date);

    /** Start a trip — creates BusTrip record, marks roster active */
    TripStatusDTO startTrip(Integer rosterId, Integer staffId);

    /** Stop the active trip — marks completed, updates roster */
    TripStatusDTO stopTrip(Integer tripId, Integer staffId);

    /** Current active trip for this conductor */
    TripStatusDTO getActiveTrip(Integer staffId);

    /** Issue a ticket during an active trip */
    TicketDTO issueTicket(IssueTicketRequest request, Integer staffId);

    /** All tickets issued in a specific trip */
    List<TicketDTO> getTripTickets(Integer tripId, Integer staffId);

    /** Validate (scan) an existing ticket */
    TicketDTO validateTicket(String qrCode, Integer staffId);

    /** Update crowd level during a trip */
    TripStatusDTO updateCrowdLevel(CrowdUpdateRequest request, Integer staffId);

    /** Route stops for the conductor's current route (for ticket dropdown) */
    List<StopDTO> getRouteStops(Integer routeId);

    /** Welfare balance history */
    List<ConductorWelfareDTO> getWelfareHistory(Integer staffId);
}
