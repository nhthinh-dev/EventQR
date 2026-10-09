package com.eventqr.backend.service;

import com.eventqr.backend.dto.EventRequest;
import com.eventqr.backend.dto.EventResponse;
import com.eventqr.backend.dto.PageResponse;
import com.eventqr.backend.entity.Event;
import com.eventqr.backend.entity.User;
import com.eventqr.backend.entity.enums.BookingStatus;
import com.eventqr.backend.entity.enums.EventStatus;
import com.eventqr.backend.exception.AppException;
import com.eventqr.backend.exception.ErrorCode;
import com.eventqr.backend.repository.BookingRepository;
import com.eventqr.backend.repository.EventRepository;
import com.eventqr.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EventService {
    private final EventRepository eventRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;

    public PageResponse<EventResponse> getOpenEvents(int page, int size, boolean upcoming) {
        Page<Event> eventPage;
        org.springframework.data.domain.Pageable pageable = PageRequest.of(page, size, org.springframework.data.domain.Sort.by(org.springframework.data.domain.Sort.Direction.DESC, "id"));
        
        if (upcoming) {
            eventPage = eventRepository.findByStartTimeAfter(java.time.LocalDateTime.now(), pageable);
        } else {
            eventPage = eventRepository.findAll(pageable);
        }
        
        List<EventResponse> content = eventPage.getContent().stream()
                .map(event -> EventResponse.from(event, bookingRepository.countByEventIdAndStatus(event.getId(), BookingStatus.CONFIRMED)))
                .collect(Collectors.toList());

        return PageResponse.<EventResponse>builder()
                .content(content)
                .page(eventPage.getNumber())
                .size(eventPage.getSize())
                .totalPages(eventPage.getTotalPages())
                .last(eventPage.isLast())
                .build();
    }

    public EventResponse getEventDetail(Long id) {
        Event event = eventRepository.findById(id).orElseThrow(() -> new AppException(ErrorCode.EVENT_NOT_FOUND));
        long taken = bookingRepository.countByEventIdAndStatus(id, BookingStatus.CONFIRMED);
        return EventResponse.from(event, taken);
    }

    @Transactional
    public EventResponse createEvent(EventRequest request, Long organizerId) {
        if (request.getEndTime().isBefore(request.getStartTime())) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }
        User organizer = userRepository.findById(organizerId).orElseThrow(() -> new AppException(ErrorCode.FORBIDDEN));
        
        Event event = Event.builder()
                .organizer(organizer)
                .title(request.getTitle())
                .description(request.getDescription())
                .imageUrl(request.getImageUrl())
                .location(request.getLocation())
                .startTime(request.getStartTime())
                .endTime(request.getEndTime())
                .capacity(request.getCapacity())
                .status(request.getStatus() != null ? EventStatus.valueOf(request.getStatus().toUpperCase()) : EventStatus.OPEN)
                .build();
                
        event = eventRepository.save(event);
        return EventResponse.from(event, 0);
    }
    
    @Transactional
    public EventResponse updateEvent(Long id, EventRequest request, Long organizerId) {
        Event event = eventRepository.findById(id).orElseThrow(() -> new AppException(ErrorCode.EVENT_NOT_FOUND));
        if (request.getEndTime().isBefore(request.getStartTime())) {
            throw new AppException(ErrorCode.VALIDATION_ERROR);
        }
        
        event.setTitle(request.getTitle());
        event.setDescription(request.getDescription());
        event.setImageUrl(request.getImageUrl());
        event.setLocation(request.getLocation());
        event.setStartTime(request.getStartTime());
        event.setEndTime(request.getEndTime());
        event.setCapacity(request.getCapacity());
        
        if (request.getStatus() != null) {
            try {
                event.setStatus(EventStatus.valueOf(request.getStatus().toUpperCase()));
            } catch (Exception e) {}
        }

        event = eventRepository.save(event);
        long taken = bookingRepository.countByEventIdAndStatus(id, BookingStatus.CONFIRMED);
        return EventResponse.from(event, taken);
    }
    
    @Transactional
    public void deleteEvent(Long id, Long userId, String userRole) {
        Event event = eventRepository.findById(id).orElseThrow(() -> new AppException(ErrorCode.EVENT_NOT_FOUND));
        if (!event.getOrganizer().getId().equals(userId) && !"ADMIN".equals(userRole)) {
            throw new AppException(ErrorCode.FORBIDDEN);
        }
        long bookingsCount = bookingRepository.countByEventIdAndStatus(id, BookingStatus.CONFIRMED);
        if (bookingsCount > 0) {
            throw new AppException(ErrorCode.EVENT_HAS_BOOKINGS);
        }
        eventRepository.delete(event);
    }
}
