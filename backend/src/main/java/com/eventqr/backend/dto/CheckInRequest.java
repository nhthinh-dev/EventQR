package com.eventqr.backend.dto;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CheckInRequest {
    @NotBlank(message = "MÃ£ vÃ© khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")
    private String ticketCode;
    @NotNull(message = "ID sá»± kiá»‡n khÃ´ng Ä‘Æ°á»£c Ä‘á»ƒ trá»‘ng")
    private Long eventId;
}
