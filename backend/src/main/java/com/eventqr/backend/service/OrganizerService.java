package com.eventqr.backend.service;

import com.eventqr.backend.dto.AttendeeResponse;
import com.eventqr.backend.dto.OrganizerEventResponse;
import com.eventqr.backend.entity.CheckIn;
import com.eventqr.backend.entity.Event;
import com.eventqr.backend.entity.Ticket;
import com.eventqr.backend.entity.enums.BookingStatus;
import com.eventqr.backend.entity.enums.TicketStatus;
import com.eventqr.backend.exception.AppException;
import com.eventqr.backend.exception.ErrorCode;
import com.eventqr.backend.repository.BookingRepository;
import com.eventqr.backend.repository.CheckInRepository;
import com.eventqr.backend.repository.EventRepository;
import com.eventqr.backend.repository.TicketRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrganizerService {
    private final EventRepository eventRepository;
    private final BookingRepository bookingRepository;
    private final TicketRepository ticketRepository;
    private final CheckInRepository checkInRepository;

    public List<OrganizerEventResponse> getMyEvents(Long organizerId) {
        return eventRepository.findAll().stream().map(event -> {
            long registered = bookingRepository.countByEventIdAndStatus(event.getId(), BookingStatus.CONFIRMED);
            long checkedIn = checkInRepository.findByTicketBookingEventId(event.getId()).size();
            
            return OrganizerEventResponse.builder()
                    .id(event.getId())
                    .title(event.getTitle())
                    .startTime(event.getStartTime())
                    .capacity(event.getCapacity())
                    .registeredCount(registered)
                    .checkedInCount(checkedIn)
                    .status(event.getStatus().name())
                    .build();
        }).collect(Collectors.toList());
    }

    public List<AttendeeResponse> getEventAttendees(Long eventId, Long organizerId) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new AppException(ErrorCode.EVENT_NOT_FOUND));

        return bookingRepository.findByEventIdAndStatus(eventId, BookingStatus.CONFIRMED).stream()
                .map(b -> {
                    Ticket t = ticketRepository.findByBookingUserId(b.getUser().getId()).stream()
                            .filter(ticket -> ticket.getBooking().getId().equals(b.getId()))
                            .findFirst().orElse(null);
                    
                    LocalDateTime checkedInAt = null;
                    String photoUrl = null;
                    if (t != null && t.getStatus() == TicketStatus.CHECKED_IN) {
                        CheckIn ci = checkInRepository.findByTicketBookingEventId(eventId).stream()
                                .filter(c -> c.getTicket().getId().equals(t.getId()))
                                .findFirst().orElse(null);
                        if (ci != null) {
                            checkedInAt = ci.getCheckedInAt();
                            photoUrl = ci.getPhotoUrl();
                        }
                    }
                    
                    return AttendeeResponse.builder()
                            .name(b.getUser().getName())
                            .email(b.getUser().getEmail())
                            .ticketStatus(t != null ? t.getStatus().name() : "N/A")
                            .checkedInAt(checkedInAt)
                            .photoUrl(photoUrl)
                            .build();
                }).collect(Collectors.toList());
    }

    public List<com.eventqr.backend.dto.CheckInHistoryResponse> getRecentCheckIns(Long organizerId) {
        return checkInRepository.findTop5ByCheckedInByIdOrderByCheckedInAtDesc(organizerId).stream()
                .map(ci -> com.eventqr.backend.dto.CheckInHistoryResponse.builder()
                        .checkInId(ci.getId())
                        .ticketCode(ci.getTicket().getTicketCode())
                        .attendeeName(ci.getTicket().getBooking().getUser().getName())
                        .attendeeEmail(ci.getTicket().getBooking().getUser().getEmail())
                        .eventTitle(ci.getTicket().getBooking().getEvent().getTitle())
                        .checkedInAt(ci.getCheckedInAt())
                        .photoUrl(ci.getPhotoUrl())
                        .build())
                .collect(Collectors.toList());
    }
}
