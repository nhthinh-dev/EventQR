package com.eventqr.backend.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class UserAdminResponse {
    private Long id;
    private String name;
    private String email;
    private String phone;
    private java.time.LocalDate dob;
    private String role;
    private Boolean isActive;
    private LocalDateTime createdAt;
}
