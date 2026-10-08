package com.eventqr.backend.dto;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class OrganizerEventResponse {
    private Long id;
    private String title;
    private LocalDateTime startTime;
    private Integer capacity;
    private Long registeredCount;
    private Long checkedInCount;
    private String status;
}
