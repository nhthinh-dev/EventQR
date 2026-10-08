package com.eventqr.backend.dto;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class AttendeeResponse {
    private String name;
    private String email;
    private String ticketStatus;
    private LocalDateTime checkedInAt;
    private String photoUrl;
}
