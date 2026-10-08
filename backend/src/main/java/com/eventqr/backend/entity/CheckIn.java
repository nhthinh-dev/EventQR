package com.eventqr.backend.entity;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity @Table(name = "check_ins")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class CheckIn {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @OneToOne(fetch = FetchType.LAZY) @JoinColumn(name = "ticket_id", nullable = false, unique = true)
    private Ticket ticket;
    @Column(name = "checked_in_at", nullable = false, updatable = false) private LocalDateTime checkedInAt;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "checked_in_by", nullable = false)
    private User checkedInBy;
    @Column(name = "photo_url")
    private String photoUrl;
    @PrePersist protected void onCreate() { if (checkedInAt == null) checkedInAt = LocalDateTime.now(); }
}
