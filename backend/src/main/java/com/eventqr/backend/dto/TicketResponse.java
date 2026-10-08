package com.eventqr.backend.dto;

import com.eventqr.backend.entity.Ticket;
import com.eventqr.backend.entity.Event;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class TicketResponse {
    private Long ticketId;
    private String ticketCode;
    private String status;
    private Long eventId;
    private String eventTitle;
    private LocalDateTime startTime;
    private String location;

    public static TicketResponse from(Ticket ticket) {
        Event event = ticket.getBooking().getEvent();
        return TicketResponse.builder()
                .ticketId(ticket.getId())
                .ticketCode(ticket.getTicketCode())
                .status(ticket.getStatus().name())
                .eventId(event.getId())
                .eventTitle(event.getTitle())
                .startTime(event.getStartTime())
                .location(event.getLocation())
                .build();
    }
}
