package com.eventqr.backend.dto;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class CheckInResponse {
    private String ticketCode;
    private String attendeeName;
    private String eventTitle;
    private LocalDateTime checkedInAt;
}
