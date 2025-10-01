package com.e106.kdkd.account.repository;

import com.e106.kdkd.account.repository.custom.CustomAutoTransferRepository;
import com.e106.kdkd.global.common.entity.AutoTransfer;
import com.e106.kdkd.global.common.entity.ParentRelation;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AutoTransferRepository extends JpaRepository<AutoTransfer, String>,
    CustomAutoTransferRepository {

    Optional<AutoTransfer> findByRelation_RelationUuidAndTransferDayAndTransferTime(
        String relationUuid, Integer transferDay, LocalTime transferTime);

    Optional<AutoTransfer> findByRelation_RelationUuid(String relationUuid);

    // 같은 '분'에 한 번만 실행되도록 원자적 선점
    @Modifying
    @Query(value = """
        UPDATE auto_transfer
           SET updated_at = NOW(3)
         WHERE auto_transfer_uuid = :uuid
           AND (
                updated_at IS NULL
                OR TIMESTAMPDIFF(SECOND, updated_at, NOW(3)) >= 60
           )
        """, nativeQuery = true)
    int touchIfNotExecutedWithin1min(@Param("uuid") String uuid);

    // 현재 분과 정확히 같은 규칙 조회 (초는 00으로 저장되어 있어야 함)
    @Query("""
            SELECT at FROM AutoTransfer at
            WHERE at.transferTime = :time
        """)
    List<AutoTransfer> findAllByExactTime(@Param("time") LocalTime time);

    AutoTransfer findByRelation(ParentRelation relation);
}
