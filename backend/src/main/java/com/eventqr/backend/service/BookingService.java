package com.eventqr.backend.service;

import com.eventqr.backend.dto.TicketResponse;
import com.eventqr.backend.entity.Booking;
import com.eventqr.backend.entity.Event;
import com.eventqr.backend.entity.Ticket;
import com.eventqr.backend.entity.User;
import com.eventqr.backend.entity.enums.BookingStatus;
import com.eventqr.backend.entity.enums.EventStatus;
import com.eventqr.backend.entity.enums.TicketStatus;
import com.eventqr.backend.exception.AppException;
import com.eventqr.backend.exception.ErrorCode;
import com.eventqr.backend.repository.BookingRepository;
import com.eventqr.backend.repository.EventRepository;
import com.eventqr.backend.repository.TicketRepository;
import com.eventqr.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BookingService {
    private final EventRepository eventRepository;
    private final BookingRepository bookingRepository;
    private final TicketRepository ticketRepository;
    private final UserRepository userRepository;

    @Transactional
    public TicketResponse book(Long eventId, Long userId) {
        // 1. DÃ¹ng Pessimistic Lock khÃ³a sá»± kiá»‡n láº¡i
        Event event = eventRepository.findByIdForUpdate(eventId)
                .orElseThrow(() -> new AppException(ErrorCode.EVENT_NOT_FOUND));

        // 2. Kiá»ƒm tra Ä‘Ã£ Ä‘Äƒng kÃ½ chÆ°a
        if (bookingRepository.existsByUserIdAndEventIdAndStatus(userId, eventId, BookingStatus.CONFIRMED)) {
            throw new AppException(ErrorCode.ALREADY_REGISTERED);
        }

        // 3. Sá»± kiá»‡n cÃ²n má»Ÿ khÃ´ng
        if (event.getStatus() != EventStatus.OPEN) {
            throw new AppException(ErrorCode.EVENT_CLOSED);
        }

        // 3.5 Kiểm tra thời gian
        if (event.getEndTime() != null && event.getEndTime().isBefore(java.time.LocalDateTime.now())) {
            throw new AppException(ErrorCode.EVENT_EXPIRED);
        }

        // 4. Kiá»ƒm tra sá»©c chá»©a
        long taken = bookingRepository.countByEventIdAndStatus(eventId, BookingStatus.CONFIRMED);
        if (taken >= event.getCapacity()) {
            throw new AppException(ErrorCode.EVENT_FULL);
        }

        User user = userRepository.getReferenceById(userId);
        Booking booking = Booking.builder()
                .user(user)
                .event(event)
                .status(BookingStatus.CONFIRMED)
                .build();
        
        try {
            booking = bookingRepository.save(booking);
        } catch (DataIntegrityViolationException e) {
            // Äá» phÃ²ng Constraint UNIQUE(user_id, event_id) bá»‹ vÄƒng á»Ÿ database
            throw new AppException(ErrorCode.ALREADY_REGISTERED);
        }

        String ticketCode = generateUniqueCode();
        Ticket ticket = Ticket.builder()
                .booking(booking)
                .ticketCode(ticketCode)
                .status(TicketStatus.VALID)
                .version(0L)
                .build();
        
        ticket = ticketRepository.save(ticket);
        return TicketResponse.from(ticket);
    }

    private String generateUniqueCode() {
        int year = LocalDate.now().getYear();
        String randomStr = UUID.randomUUID().toString().substring(0, 5).toUpperCase();
        return "EVT-" + year + "-" + randomStr;
    }

    public List<TicketResponse> getMyBookings(Long userId) {
        return bookingRepository.findByUserId(userId).stream()
                .filter(b -> b.getStatus() == BookingStatus.CONFIRMED)
                .map(b -> ticketRepository.findByBookingUserId(userId).stream()
                        .filter(t -> t.getBooking().getId().equals(b.getId()))
                        .findFirst()
                        .map(TicketResponse::from)
                        .orElse(null))
                .filter(t -> t != null)
                .collect(Collectors.toList());
    }
}
