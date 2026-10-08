package com.eventqr.backend.controller;

import com.eventqr.backend.dto.TicketResponse;
import com.eventqr.backend.security.CustomUserDetails;
import com.eventqr.backend.service.TicketService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tickets")
@RequiredArgsConstructor
public class TicketController {

    private final TicketService ticketService;

    @GetMapping("/me")
    public ResponseEntity<List<TicketResponse>> getMyTickets(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(ticketService.getMyTickets(userDetails.getUser().getId()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TicketResponse> getTicketDetail(
            @PathVariable Long id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(ticketService.getTicketDetail(id, userDetails.getUser().getId()));
    }

    @GetMapping("/verify")
    public ResponseEntity<com.eventqr.backend.dto.TicketVerifyResponse> verifyTicket(
            @RequestParam String code,
            @RequestParam Long eventId,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(ticketService.verifyTicket(code, eventId, userDetails.getUser().getId()));
    }
}
