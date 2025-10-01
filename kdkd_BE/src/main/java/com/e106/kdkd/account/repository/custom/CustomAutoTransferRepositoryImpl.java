package com.e106.kdkd.account.repository.custom;

import com.e106.kdkd.global.common.entity.AutoTransfer;
import com.e106.kdkd.global.common.entity.QAutoTransfer;
import com.e106.kdkd.global.common.entity.QParentRelation;
import com.e106.kdkd.global.common.entity.QUser;
import com.querydsl.jpa.impl.JPAQueryFactory;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.time.LocalTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class CustomAutoTransferRepositoryImpl implements CustomAutoTransferRepository {

    private final JPAQueryFactory queryFactory;

    @PersistenceContext
    private EntityManager em;

    private final QAutoTransfer autoTransfer = QAutoTransfer.autoTransfer;
    private final QParentRelation parentRelation = QParentRelation.parentRelation;
    private final QUser parent = QUser.user;

    @Override
    public boolean existsSameSchedule(String relationUuid, int transferDay,
        LocalTime transferTime) {
        Long cnt = em.createQuery(
                "select count(a) from AutoTransfer a " +
                    "where a.relation.relationUuid = :relationUuid " +
                    "and a.transferDay = :day and a.transferTime = :time", Long.class)
            .setParameter("relationUuid", relationUuid)
            .setParameter("day", transferDay)
            .setParameter("time", transferTime)
            .getSingleResult();
        return cnt != null && cnt > 0;
    }

    @Override
    public List<AutoTransfer> findAllByRelationUuidOrderByTime(String relationUuid) {
        return em.createQuery(
                "select a from AutoTransfer a " +
                    "where a.relation.relationUuid = :relationUuid " +
                    "order by a.transferDay asc, a.transferTime asc", AutoTransfer.class)
            .setParameter("relationUuid", relationUuid)
            .getResultList();
    }

    @Override
    public Long sumByParentUuid(String parentUuid) {
        Long result = queryFactory
            .select(autoTransfer.amount.sum())
            .from(autoTransfer)
            .join(autoTransfer.relation, parentRelation)
            .join(parentRelation.parent, parent)
            .where(parent.userUuid.eq(parentUuid))
            .fetchOne();

        return result == null ? 0L : result;
    }
}
