package com.eventqr.backend.controller;

import com.eventqr.backend.dto.CheckInRequest;
import com.eventqr.backend.dto.CheckInResponse;
import com.eventqr.backend.security.CustomUserDetails;
import com.eventqr.backend.service.CheckInService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/check-ins")
@RequiredArgsConstructor
public class CheckInController {
    
    private final CheckInService checkInService;

    @PostMapping
    public ResponseEntity<CheckInResponse> checkIn(
            @Valid @RequestBody CheckInRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(checkInService.checkIn(request, userDetails.getUser().getId()));
    }

    @PostMapping(value = "/with-photo", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<CheckInResponse> checkInWithPhoto(
            @RequestParam("ticketCode") String ticketCode,
            @RequestParam("eventId") Long eventId,
            @RequestParam("photo") org.springframework.web.multipart.MultipartFile photo,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(checkInService.checkInWithPhoto(ticketCode, eventId, photo, userDetails.getUser().getId()));
    }
}
