package com.eventqr.backend.dto;
import lombok.Data;
import java.time.LocalDate;

@Data
public class ProfileUpdateRequest {
    private String name;
    private String phone;
    private LocalDate dob;
}
