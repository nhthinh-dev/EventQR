package com.eventqr.backend.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TicketVerifyResponse {
    private String ticketCode;
    private String attendeeName;
    private String attendeeEmail;
    private String attendeePhone;
    private java.time.LocalDate attendeeDob;
    private String eventTitle;
    private String status;
}
