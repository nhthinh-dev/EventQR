package com.eventqr.backend.service;

import com.eventqr.backend.dto.CheckInRequest;
import com.eventqr.backend.dto.CheckInResponse;
import com.eventqr.backend.entity.CheckIn;
import com.eventqr.backend.entity.Event;
import com.eventqr.backend.entity.Ticket;
import com.eventqr.backend.entity.User;
import com.eventqr.backend.entity.enums.TicketStatus;
import com.eventqr.backend.exception.AppException;
import com.eventqr.backend.exception.ErrorCode;
import com.eventqr.backend.repository.CheckInRepository;
import com.eventqr.backend.repository.TicketRepository;
import com.eventqr.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.orm.ObjectOptimisticLockingFailureException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CheckInService {
    private final TicketRepository ticketRepository;
    private final CheckInRepository checkInRepository;
    private final UserRepository userRepository;
    private final FileStorageService fileStorageService;

    @Transactional
    public CheckInResponse checkInWithPhoto(String ticketCode, Long eventId, org.springframework.web.multipart.MultipartFile photo, Long organizerId) {
        Ticket ticket = ticketRepository.findByTicketCode(ticketCode)
                .orElseThrow(() -> new AppException(ErrorCode.TICKET_NOT_FOUND));

        Event event = ticket.getBooking().getEvent();
        if (!event.getId().equals(eventId)) {
            throw new AppException(ErrorCode.TICKET_WRONG_EVENT);
        }
        if (java.time.LocalDateTime.now().isBefore(event.getStartTime().minusHours(4))) {
            throw new AppException(ErrorCode.CHECKIN_TOO_EARLY);
        }
        if (ticket.getStatus() != TicketStatus.VALID) {
            throw new AppException(ErrorCode.TICKET_ALREADY_CHECKED_IN);
        }

        String photoUrl = fileStorageService.storeFile(photo);

        ticket.setStatus(TicketStatus.CHECKED_IN);
        User organizer = userRepository.getReferenceById(organizerId);
        
        CheckIn checkIn = CheckIn.builder()
                .ticket(ticket)
                .checkedInBy(organizer)
                .photoUrl(photoUrl)
                .build();
                
        try {
            checkIn = checkInRepository.save(checkIn);
            ticketRepository.save(ticket);
            ticketRepository.flush();
        } catch (ObjectOptimisticLockingFailureException | DataIntegrityViolationException e) {
            throw new AppException(ErrorCode.TICKET_ALREADY_CHECKED_IN);
        }

        return CheckInResponse.builder()
                .ticketCode(ticket.getTicketCode())
                .attendeeName(ticket.getBooking().getUser().getName())
                .eventTitle(event.getTitle())
                .checkedInAt(checkIn.getCheckedInAt())
                .build();
    }

    @Transactional
    public CheckInResponse checkIn(CheckInRequest req, Long organizerId) {
        Ticket ticket = ticketRepository.findByTicketCode(req.getTicketCode())
                .orElseThrow(() -> new AppException(ErrorCode.TICKET_NOT_FOUND));

        Event event = ticket.getBooking().getEvent();
        
        if (!event.getId().equals(req.getEventId())) {
            throw new AppException(ErrorCode.TICKET_WRONG_EVENT);
        }
        if (java.time.LocalDateTime.now().isBefore(event.getStartTime().minusHours(4))) {
            throw new AppException(ErrorCode.CHECKIN_TOO_EARLY);
        }
        
        if (ticket.getStatus() != TicketStatus.VALID) {
            throw new AppException(ErrorCode.TICKET_ALREADY_CHECKED_IN);
        }

        ticket.setStatus(TicketStatus.CHECKED_IN);
        User organizer = userRepository.getReferenceById(organizerId);
        
        CheckIn checkIn = CheckIn.builder()
                .ticket(ticket)
                .checkedInBy(organizer)
                .build();
                
        try {
            checkIn = checkInRepository.save(checkIn);
            ticketRepository.save(ticket);
            ticketRepository.flush(); // Äáº©y SQL xuá»‘ng ngay láº­p tá»©c Ä‘á»ƒ kÃ­ch hoáº¡t @Version check
        } catch (ObjectOptimisticLockingFailureException | DataIntegrityViolationException e) {
            throw new AppException(ErrorCode.TICKET_ALREADY_CHECKED_IN);
        }

        return CheckInResponse.builder()
                .ticketCode(ticket.getTicketCode())
                .attendeeName(ticket.getBooking().getUser().getName())
                .eventTitle(event.getTitle())
                .checkedInAt(checkIn.getCheckedInAt())
                .build();
    }
}
