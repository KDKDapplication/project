package com.e106.kdkd.boxes.repository;

import com.e106.kdkd.global.common.entity.SaveBox;
import com.e106.kdkd.global.common.enums.BoxStatus;
import jakarta.persistence.LockModeType;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface SaveBoxRepository extends JpaRepository<SaveBox, String> {

    List<SaveBox> findAllByChildren_UserUuidAndStatusOrderByCreatedAtDesc(String childUuid,
        BoxStatus boxStatus);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
          select b
          from SaveBox b
          where b.children.userUuid = :childUuid
            and b.status = com.e106.kdkd.global.common.enums.BoxStatus.IN_PROGRESS
        """)
    List<SaveBox> findAllInProgressForChildForUpdate(@Param("childUuid") String childUuid);

    List<SaveBox> findAllByChildren_UserUuid(String userUuid);
}
