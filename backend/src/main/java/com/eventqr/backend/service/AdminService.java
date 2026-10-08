package com.eventqr.backend.service;

import com.eventqr.backend.dto.CheckInHistoryResponse;
import com.eventqr.backend.dto.PageResponse;
import com.eventqr.backend.dto.UserAdminResponse;
import com.eventqr.backend.dto.UserCreateRequest;
import com.eventqr.backend.entity.CheckIn;
import com.eventqr.backend.entity.User;
import com.eventqr.backend.entity.enums.Role;
import com.eventqr.backend.exception.AppException;
import com.eventqr.backend.exception.ErrorCode;
import com.eventqr.backend.repository.CheckInRepository;
import com.eventqr.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminService {
    private final UserRepository userRepository;
    private final CheckInRepository checkInRepository;
    private final PasswordEncoder passwordEncoder;

    public List<UserAdminResponse> getAllUsers() {
        return userRepository.findAll().stream()
                .map(u -> UserAdminResponse.builder()
                        .id(u.getId())
                        .name(u.getName())
                        .email(u.getEmail())
                        .phone(u.getPhone())
                        .dob(u.getDob())
                        .role(u.getRole().name()).isActive(u.getIsActive())
                        .createdAt(u.getCreatedAt())
                        .build())
                .collect(Collectors.toList());
    }

    public UserAdminResponse createUser(UserCreateRequest req) {
        if (userRepository.findByEmail(req.getEmail()).isPresent()) {
            throw new AppException(ErrorCode.EMAIL_ALREADY_EXISTS);
        }

        Role role;
        try {
            role = Role.valueOf(req.getRole());
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("INVALID_ROLE");
        }

        if (role != Role.USER && role != Role.ORGANIZER) {
            throw new RuntimeException("INVALID_ROLE");
        }

        User user = User.builder()
                .name(req.getName())
                .email(req.getEmail())
                .password(passwordEncoder.encode(req.getPassword()))
                .role(role)
                .build();

        user = userRepository.save(user);

        return UserAdminResponse.builder()
                .id(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .role(user.getRole().name()).isActive(user.getIsActive())
                .createdAt(user.getCreatedAt())
                .build();
    }

    public PageResponse<CheckInHistoryResponse> getAllCheckIns(int page, int size) {
        Page<CheckIn> checkInPage = checkInRepository.findAllByOrderByCheckedInAtDesc(PageRequest.of(page, size));
        
        List<CheckInHistoryResponse> content = checkInPage.getContent().stream()
                .map(ci -> CheckInHistoryResponse.builder()
                        .checkInId(ci.getId())
                        .ticketCode(ci.getTicket().getTicketCode())
                        .attendeeName(ci.getTicket().getBooking().getUser().getName())
                        .attendeeEmail(ci.getTicket().getBooking().getUser().getEmail())
                        .attendeePhone(ci.getTicket().getBooking().getUser().getPhone())
                        .attendeeDob(ci.getTicket().getBooking().getUser().getDob())
                        .eventTitle(ci.getTicket().getBooking().getEvent().getTitle())
                        .checkedInAt(ci.getCheckedInAt())
                        .photoUrl(ci.getPhotoUrl())
                        .checkedInBy(CheckInHistoryResponse.CheckedInByDto.builder()
                                .id(ci.getCheckedInBy().getId())
                                .name(ci.getCheckedInBy().getName())
                                .email(ci.getCheckedInBy().getEmail())
                                .build())
                        .build())
                .collect(Collectors.toList());
                
        return PageResponse.<CheckInHistoryResponse>builder()
                .content(content)
                .page(checkInPage.getNumber())
                .size(checkInPage.getSize())
                .totalPages(checkInPage.getTotalPages())
                .last(checkInPage.isLast())
                .build();
    }

    public void toggleUserLock(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new AppException(ErrorCode.VALIDATION_ERROR));
        user.setIsActive(!Boolean.TRUE.equals(user.getIsActive()));
        userRepository.save(user);
    }
}
