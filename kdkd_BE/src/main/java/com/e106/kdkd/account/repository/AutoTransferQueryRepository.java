package com.e106.kdkd.account.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.e106.kdkd.global.common.entity.AutoTransfer;

public interface AutoTransferQueryRepository extends JpaRepository<AutoTransfer, String> {

    @Query("""
        select c.name as childName,
               a.amount as amount,
               a.transferDay as transferDay,
               a.transferTime as transferTime
        from AutoTransfer a
        join a.relation pr
        join pr.child c
        where pr.parent.userUuid = :parentUuid
        order by a.transferDay asc, a.transferTime asc
    """)
    List<AutoTransferView> findAllForParent(String parentUuid);
}