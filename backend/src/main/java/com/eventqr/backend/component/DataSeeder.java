package com.eventqr.backend.component;

import com.eventqr.backend.entity.User;
import com.eventqr.backend.entity.enums.Role;
import com.eventqr.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Tự động tạo tài khoản Admin mặc định nếu chưa có
        if (!userRepository.existsByEmail("admin@gmail.com")) {
            User admin = User.builder()
                    .name("Quản trị viên Hệ thống")
                    .email("admin@gmail.com")
                    .password(passwordEncoder.encode("admin123"))
                    .role(Role.ADMIN)
                    .isActive(true)
                    .build();
            userRepository.save(admin);
            System.out.println("====== ĐÃ TẠO TÀI KHOẢN ADMIN MẶC ĐỊNH ======");
            System.out.println("Email: admin@gmail.com");
            System.out.println("Mật khẩu: admin123");
            System.out.println("=============================================");
        }
    }
}
