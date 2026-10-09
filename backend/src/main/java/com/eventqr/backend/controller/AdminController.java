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
import org.springframework.web.multipart.MultipartFile;
import com.eventqr.backend.service.FileStorageService;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final FileStorageService fileStorageService;

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

    @PostMapping(value = "/upload-image", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<java.util.Map<String, String>> uploadImage(@RequestParam("file") MultipartFile file) {
        String photoUrl = fileStorageService.storeFile(file);
        java.util.Map<String, String> response = new java.util.HashMap<>();
        response.put("imageUrl", photoUrl);
        return ResponseEntity.ok(response);
    }

}