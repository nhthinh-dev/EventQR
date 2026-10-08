package com.eventqr.backend.controller;

import com.eventqr.backend.dto.CheckInHistoryResponse;
import com.eventqr.backend.dto.PageResponse;
import com.eventqr.backend.dto.UserAdminResponse;
import com.eventqr.backend.dto.UserCreateRequest;
import com.eventqr.backend.service.AdminService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/users")
    public ResponseEntity<List<UserAdminResponse>> getAllUsers() {
        return ResponseEntity.ok(adminService.getAllUsers());
    }

    @PostMapping("/users")
    public ResponseEntity<UserAdminResponse> createUser(@Valid @RequestBody UserCreateRequest request) {
        return new ResponseEntity<>(adminService.createUser(request), HttpStatus.CREATED);
    }

    @GetMapping("/check-ins")
    public ResponseEntity<PageResponse<CheckInHistoryResponse>> getAllCheckIns(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(adminService.getAllCheckIns(page, size));
    }

    @PostMapping("/users/{id}/toggle-lock")
    public ResponseEntity<Void> toggleUserLock(@PathVariable Long id) {
        adminService.toggleUserLock(id);
        return ResponseEntity.noContent().build();
    }
}
