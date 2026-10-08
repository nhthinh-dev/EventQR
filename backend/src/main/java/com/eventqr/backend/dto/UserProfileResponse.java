package com.eventqr.backend.dto;
import com.eventqr.backend.entity.User;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDate;

@Data @Builder
public class UserProfileResponse {
    private String name;
    private String email;
    private String phone;
    private LocalDate dob;
    private String role;

    public static UserProfileResponse from(User user) {
        return UserProfileResponse.builder()
            .name(user.getName())
            .email(user.getEmail())
            .phone(user.getPhone())
            .dob(user.getDob())
            .role(user.getRole().name())
            .build();
    }
}
