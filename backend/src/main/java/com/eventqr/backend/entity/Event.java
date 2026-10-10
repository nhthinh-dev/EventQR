package com.eventqr.backend.entity;
import com.eventqr.backend.entity.enums.EventStatus;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity @Table(name = "events")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Event {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "organizer_id", nullable = false)
    private User organizer;
    @Column(nullable = false, length = 200) private String title;
    @Column(columnDefinition = "TEXT") private String description;
    @Column(name = "image_url", length = 500) private String imageUrl;
    @Column(nullable = false, length = 255) private String location;
    @Column(name = "start_time", nullable = false) private LocalDateTime startTime;
    @Column(name = "end_time", nullable = false) private LocalDateTime endTime;
    @Column(nullable = false) private Integer capacity;
    @Column(name = "cancel_deadline_hours", nullable = false) private Integer cancelDeadlineHours = 72;
    @Enumerated(EnumType.STRING) @Column(nullable = false) private EventStatus status;
    @Column(name = "created_at", nullable = false, updatable = false) private LocalDateTime createdAt;
    @PrePersist protected void onCreate() { if (createdAt == null) createdAt = LocalDateTime.now(); }
}
