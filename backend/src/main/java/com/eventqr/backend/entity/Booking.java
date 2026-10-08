package com.eventqr.backend.entity;
import com.eventqr.backend.entity.enums.BookingStatus;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity @Table(name = "bookings")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Booking {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "user_id", nullable = false)
    private User user;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "event_id", nullable = false)
    private Event event;
    @Column(name = "booking_time", nullable = false, updatable = false) private LocalDateTime bookingTime;
    @Enumerated(EnumType.STRING) @Column(nullable = false) private BookingStatus status;
    @PrePersist protected void onCreate() { if (bookingTime == null) bookingTime = LocalDateTime.now(); }
}
