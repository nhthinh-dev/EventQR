package com.eventqr.backend.entity;
import com.eventqr.backend.entity.enums.TicketStatus;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity @Table(name = "tickets")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Ticket {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @OneToOne(fetch = FetchType.LAZY) @JoinColumn(name = "booking_id", nullable = false, unique = true)
    private Booking booking;
    @Column(name = "ticket_code", nullable = false, unique = true, length = 50) private String ticketCode;
    @Enumerated(EnumType.STRING) @Column(nullable = false) private TicketStatus status;
    @Version @Column(nullable = false) private Long version;
    @Column(name = "created_at", nullable = false, updatable = false) private LocalDateTime createdAt;
    @PrePersist protected void onCreate() { if (createdAt == null) createdAt = LocalDateTime.now(); }
}
