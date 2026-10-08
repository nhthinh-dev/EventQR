package com.eventqr.backend.dto;

import com.eventqr.backend.entity.enums.Role;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AuthResponse {
    private String token;
    private Role role;
    private Long userId;
    private String name;
    private String email;
}
