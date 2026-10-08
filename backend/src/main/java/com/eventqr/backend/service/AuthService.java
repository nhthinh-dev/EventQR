package com.eventqr.backend.service;

import com.eventqr.backend.dto.AuthResponse;
import com.eventqr.backend.dto.LoginRequest;
import com.eventqr.backend.dto.RegisterRequest;
import com.eventqr.backend.entity.User;
import com.eventqr.backend.entity.enums.Role;
import com.eventqr.backend.exception.AppException;
import com.eventqr.backend.exception.ErrorCode;
import com.eventqr.backend.repository.UserRepository;
import com.eventqr.backend.security.CustomUserDetails;
import com.eventqr.backend.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;

    public Map<String, Object> register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new AppException(ErrorCode.EMAIL_ALREADY_EXISTS);
        }

        User user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(Role.USER)
                .phone(request.getPhone())
                .dob(request.getDob()) // LuÃ´n táº¡o USER theo Ä‘áº·c táº£
                .build();

        userRepository.save(user);

        Map<String, Object> res = new HashMap<>();
        res.put("userId", user.getId());
        res.put("email", user.getEmail());
        res.put("message", "ÄÄƒng kÃ½ thÃ nh cÃ´ng");
        return res;
    }

    public AuthResponse login(LoginRequest request) {
        User checkUser = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new AppException(ErrorCode.INVALID_CREDENTIALS));
        if (Boolean.FALSE.equals(checkUser.getIsActive())) {
            throw new AppException(ErrorCode.ACCOUNT_LOCKED);
        }
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
            );

            CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
            String token = jwtUtil.generateToken(userDetails);
            User user = userDetails.getUser();

            return AuthResponse.builder()
                    .token(token)
                    .role(user.getRole())
                    .userId(user.getId())
                    .name(user.getName())
                    .email(user.getEmail())
                    .build();

        } catch (AuthenticationException e) {
            throw new AppException(ErrorCode.INVALID_CREDENTIALS);
        }
    }
}
