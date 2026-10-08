package com.eventqr.backend.service;

import com.eventqr.backend.dto.TicketResponse;
import com.eventqr.backend.entity.Ticket;
import com.eventqr.backend.exception.AppException;
import com.eventqr.backend.exception.ErrorCode;
import com.eventqr.backend.repository.TicketRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TicketService {
    private final TicketRepository ticketRepository;

    public List<TicketResponse> getMyTickets(Long userId) {
        return ticketRepository.findByBookingUserId(userId).stream()
                .map(TicketResponse::from)
                .collect(Collectors.toList());
    }

    public TicketResponse getTicketDetail(Long ticketId, Long userId) {
        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new AppException(ErrorCode.TICKET_NOT_FOUND));
        
        if (!ticket.getBooking().getUser().getId().equals(userId)) {
            throw new AppException(ErrorCode.FORBIDDEN);
        }
        
        return TicketResponse.from(ticket);
    }

    public com.eventqr.backend.dto.TicketVerifyResponse verifyTicket(String code, Long eventId, Long organizerId) {
        Ticket ticket = ticketRepository.findByTicketCode(code)
                .orElseThrow(() -> new AppException(ErrorCode.TICKET_NOT_FOUND));
                
        if (!ticket.getBooking().getEvent().getId().equals(eventId)) {
            throw new AppException(ErrorCode.TICKET_WRONG_EVENT);
        }
        if (java.time.LocalDateTime.now().isBefore(ticket.getBooking().getEvent().getStartTime().minusHours(4))) {
            throw new AppException(ErrorCode.CHECKIN_TOO_EARLY);
        }
        if (ticket.getStatus() == com.eventqr.backend.entity.enums.TicketStatus.CHECKED_IN) {
            throw new AppException(ErrorCode.TICKET_ALREADY_CHECKED_IN);
        }
        
        return com.eventqr.backend.dto.TicketVerifyResponse.builder()
                .ticketCode(ticket.getTicketCode())
                .attendeeName(ticket.getBooking().getUser().getName())
                .attendeeEmail(ticket.getBooking().getUser().getEmail())
                .attendeePhone(ticket.getBooking().getUser().getPhone())
                .attendeeDob(ticket.getBooking().getUser().getDob())
                .eventTitle(ticket.getBooking().getEvent().getTitle())
                .status(ticket.getStatus().name())
                .build();
    }
}
