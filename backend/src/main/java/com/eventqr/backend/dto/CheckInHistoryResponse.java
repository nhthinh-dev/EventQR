package com.eventqr.backend.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class CheckInHistoryResponse {
    private Long checkInId;
    private String ticketCode;
    private String attendeeName;
    private String attendeeEmail;
    private String attendeePhone;
    private java.time.LocalDate attendeeDob;
    private String eventTitle;
    private LocalDateTime checkedInAt;
    private String photoUrl;
    private CheckedInByDto checkedInBy;

    @Data
    @Builder
    public static class CheckedInByDto {
        private Long id;
        private String name;
        private String email;
    }
}
