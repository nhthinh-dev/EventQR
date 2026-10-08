package com.eventqr.backend.controller;

import com.eventqr.backend.dto.AttendeeResponse;
import com.eventqr.backend.dto.OrganizerEventResponse;
import com.eventqr.backend.security.CustomUserDetails;
import com.eventqr.backend.service.OrganizerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class OrganizerController {

    private final OrganizerService organizerService;

    @GetMapping("/organizer/events")
    public ResponseEntity<List<OrganizerEventResponse>> getMyEvents(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(organizerService.getMyEvents(userDetails.getUser().getId()));
    }

    @GetMapping("/events/{id}/attendees")
    public ResponseEntity<List<AttendeeResponse>> getEventAttendees(
            @PathVariable Long id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(organizerService.getEventAttendees(id, userDetails.getUser().getId()));
    }

    @GetMapping("/organizer/check-ins/recent")
    public ResponseEntity<List<com.eventqr.backend.dto.CheckInHistoryResponse>> getRecentCheckIns(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(organizerService.getRecentCheckIns(userDetails.getUser().getId()));
    }
}
