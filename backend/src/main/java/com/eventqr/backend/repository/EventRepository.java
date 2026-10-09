package com.eventqr.backend.repository;
import com.eventqr.backend.entity.Event;
import com.eventqr.backend.entity.enums.EventStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import jakarta.persistence.LockModeType;
import java.util.List;
import java.util.Optional;

public interface EventRepository extends JpaRepository<Event, Long> {
    Page<Event> findByStatus(EventStatus status, Pageable pageable);
    Page<Event> findByStatusAndStartTimeAfter(EventStatus status, java.time.LocalDateTime time, Pageable pageable);
    Page<Event> findByStartTimeAfter(java.time.LocalDateTime time, Pageable pageable);
    List<Event> findByOrganizerId(Long organizerId);
    
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select e from Event e where e.id = :id")
    Optional<Event> findByIdForUpdate(@Param("id") Long id);
}
