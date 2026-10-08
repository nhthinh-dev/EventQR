package com.eventqr.backend.dto;

import com.eventqr.backend.entity.Event;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class EventResponse {
    private Long id;
    private String title;
    private String description;
    private String imageUrl;
    private String location;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer capacity;
    private Long remainingSeats;
    private String status;

    public static EventResponse from(Event event, long confirmedBookings) {
        return EventResponse.builder()
                .id(event.getId())
                .title(event.getTitle())
                .description(event.getDescription())
                .imageUrl(event.getImageUrl())
                .location(event.getLocation())
                .startTime(event.getStartTime())
                .endTime(event.getEndTime())
                .capacity(event.getCapacity())
                .remainingSeats(event.getCapacity() - confirmedBookings)
                .status(event.getStatus().name())
                .build();
    }
}
