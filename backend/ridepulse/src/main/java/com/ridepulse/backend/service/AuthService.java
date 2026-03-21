package com.ridepulse.backend.service;

import com.ridepulse.backend.dto.auth.*;

public interface AuthService {
    AuthResponse login(LoginRequest request);
    AuthResponse registerPassenger(RegisterPassengerRequest request);
    AuthResponse registerBusOwner(RegisterBusOwnerRequest request);
    AuthResponse registerAuthority(RegisterAuthorityRequest request);
    AuthResponse registerStaff(RegisterStaffRequest request, Integer ownerId);
}
