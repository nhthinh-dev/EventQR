package com.eventqr.backend.controller;

import com.eventqr.backend.dto.TicketResponse;
import com.eventqr.backend.security.CustomUserDetails;
import com.eventqr.backend.service.BookingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class BookingController {
    
    private final BookingService bookingService;

    @PostMapping("/events/{id}/book")
    public ResponseEntity<TicketResponse> bookEvent(
            @PathVariable("id") Long eventId,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return new ResponseEntity<>(bookingService.book(eventId, userDetails.getUser().getId()), HttpStatus.CREATED);
    }

    @GetMapping("/bookings/me")
    public ResponseEntity<List<TicketResponse>> getMyBookings(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(bookingService.getMyBookings(userDetails.getUser().getId()));
    }
}
