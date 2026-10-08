package com.eventqr.backend.controller;

import com.eventqr.backend.dto.EventRequest;
import com.eventqr.backend.dto.EventResponse;
import com.eventqr.backend.dto.PageResponse;
import com.eventqr.backend.security.CustomUserDetails;
import com.eventqr.backend.service.EventService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/events")
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;

    @GetMapping
    public ResponseEntity<PageResponse<EventResponse>> getEvents(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "false") boolean upcoming) {
        return ResponseEntity.ok(eventService.getOpenEvents(page, size, upcoming));
    }

    @GetMapping("/{id}")
    public ResponseEntity<EventResponse> getEventDetail(@PathVariable Long id) {
        return ResponseEntity.ok(eventService.getEventDetail(id));
    }

    @PostMapping
    public ResponseEntity<EventResponse> createEvent(
            @Valid @RequestBody EventRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return new ResponseEntity<>(eventService.createEvent(request, userDetails.getUser().getId()), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<EventResponse> updateEvent(
            @PathVariable Long id,
            @Valid @RequestBody EventRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(eventService.updateEvent(id, request, userDetails.getUser().getId()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEvent(
            @PathVariable Long id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        eventService.deleteEvent(id, userDetails.getUser().getId(), userDetails.getUser().getRole().name());
        return ResponseEntity.noContent().build();
    }
}
