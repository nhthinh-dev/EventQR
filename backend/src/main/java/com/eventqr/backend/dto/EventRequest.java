package com.eventqr.backend.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class EventRequest {
    @NotBlank(message = "TÃªn sá»± kiá»‡n khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")
    private String title;

    private String description;
    private String imageUrl;

    @NotBlank(message = "Äá»‹a Ä‘iá»ƒm khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")
    private String location;

    @NotNull(message = "Thá»i gian báº¯t Ä‘áº§u khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")
    private LocalDateTime startTime;

    @NotNull(message = "Thá»i gian káº¿t thÃºc khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")
    private LocalDateTime endTime;

    @NotNull(message = "Sá»©c chá»©a khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")
    @Min(value = 1, message = "Sá»©c chá»©a pháº£i lá»›n hÆ¡n 0")
    private Integer capacity;
    private Integer cancelDeadlineHours;
    
    private String status;
}
