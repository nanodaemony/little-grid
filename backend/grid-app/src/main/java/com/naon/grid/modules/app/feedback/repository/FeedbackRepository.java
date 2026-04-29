package com.naon.grid.modules.app.feedback.repository;

import com.naon.grid.modules.app.feedback.domain.Feedback;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface FeedbackRepository extends JpaRepository<Feedback, Long> {

    @Query("SELECT f FROM Feedback f WHERE " +
           "(:type IS NULL OR f.type = :type) AND " +
           "(:status IS NULL OR f.status = :status) " +
           "ORDER BY f.createdAt DESC")
    Page<Feedback> findByTypeAndStatus(
            @Param("type") String type,
            @Param("status") String status,
            Pageable pageable);
}
