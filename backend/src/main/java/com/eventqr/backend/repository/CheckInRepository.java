package com.eventqr.backend.repository;
import com.eventqr.backend.entity.CheckIn;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CheckInRepository extends JpaRepository<CheckIn, Long> {
    List<CheckIn> findByTicketBookingEventId(Long eventId);

    @org.springframework.data.jpa.repository.EntityGraph(attributePaths = {"ticket.booking.user", "ticket.booking.event", "checkedInBy"})
    List<CheckIn> findTop5ByCheckedInByIdOrderByCheckedInAtDesc(Long organizerId);

    @org.springframework.data.jpa.repository.EntityGraph(attributePaths = {"ticket.booking.user", "ticket.booking.event", "checkedInBy"})
    org.springframework.data.domain.Page<CheckIn> findAllByOrderByCheckedInAtDesc(org.springframework.data.domain.Pageable pageable);
    @org.springframework.data.jpa.repository.EntityGraph(attributePaths = {"ticket.booking.user", "ticket.booking.event", "checkedInBy"})
    org.springframework.data.domain.Page<com.eventqr.backend.entity.CheckIn> findByTicketBookingEventIdOrderByCheckedInAtDesc(Long eventId, org.springframework.data.domain.Pageable pageable);

    long countByTicketBookingEventId(Long eventId);
}