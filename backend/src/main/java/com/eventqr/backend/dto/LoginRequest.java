package com.eventqr.backend.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequest {
    @NotBlank(message = "Vui lÃ²ng nháº­p email")
    private String email;

    @NotBlank(message = "Vui lÃ²ng nháº­p máº­t kháº©u")
    private String password;
}
