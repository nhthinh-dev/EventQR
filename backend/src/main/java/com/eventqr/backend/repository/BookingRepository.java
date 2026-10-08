package com.eventqr.backend.repository;
import com.eventqr.backend.entity.Booking;
import com.eventqr.backend.entity.enums.BookingStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface BookingRepository extends JpaRepository<Booking, Long> {
    boolean existsByUserIdAndEventIdAndStatus(Long userId, Long eventId, BookingStatus status);
    long countByEventIdAndStatus(Long eventId, BookingStatus status);
    List<Booking> findByUserId(Long userId);
    List<Booking> findByEventIdAndStatus(Long eventId, BookingStatus status);
}
