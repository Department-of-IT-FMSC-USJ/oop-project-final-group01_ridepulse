package com.ridepulse.backend.service;

import com.ridepulse.backend.dto.*;
import java.util.List;

/** OOP Abstraction: bus management contract */
public interface BusManagementService {
    BusDetailDTO         addBus(CreateBusRequest request, Integer ownerId);
    void                 deleteBus(Integer busId, Integer ownerId);
    BusDetailDTO         updateBusRoute(UpdateBusRouteRequest request, Integer ownerId);
    List<BusDetailDTO>   getBusesByOwner(Integer ownerId);
    BusDetailDTO         getBusById(Integer busId, Integer ownerId);
}