package com.eventqr.backend.service;
import com.eventqr.backend.dto.ProfileUpdateRequest;
import com.eventqr.backend.dto.UserProfileResponse;
import com.eventqr.backend.entity.User;
import com.eventqr.backend.exception.AppException;
import com.eventqr.backend.exception.ErrorCode;
import com.eventqr.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    public UserProfileResponse getMyProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.UNAUTHORIZED));
        return UserProfileResponse.from(user);
    }

    public UserProfileResponse updateMyProfile(Long userId, ProfileUpdateRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(ErrorCode.UNAUTHORIZED));
        
        if (request.getName() != null && !request.getName().trim().isEmpty()) {
            user.setName(request.getName().trim());
        }
        user.setPhone(request.getPhone());
        user.setDob(request.getDob());
        
        user = userRepository.save(user);
        return UserProfileResponse.from(user);
    }
}
