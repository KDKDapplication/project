package com.e106.kdkd.alert.repository;

import com.e106.kdkd.alert.dto.response.GetAlertResponseItem;
import com.e106.kdkd.global.common.entity.QAlert;
import com.e106.kdkd.global.common.entity.QUser;
import com.querydsl.core.types.Projections;
import com.querydsl.core.types.dsl.Wildcard;
import com.querydsl.jpa.impl.JPAQueryFactory;
import java.util.List;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@RequiredArgsConstructor
public class CustomAlertRepositoryImpl implements CustomAlertRepository {

    private final JPAQueryFactory queryFactory;
    private static final QAlert qAlert = QAlert.alert;
    private static final QUser qSender = new QUser("sender");
    private static final QUser qReceiver = new QUser("receiver");

    @Override
    public Page<GetAlertResponseItem> findAllByUserUuid(String userUuid, Pageable pageable) {
        // total count
        Long total = queryFactory
            .select(Wildcard.count)
            .from(qAlert)
            .join(qAlert.receiver, qReceiver)
            .where(qReceiver.userUuid.eq(userUuid))
            .fetchOne();
        long totalCount = Objects.requireNonNullElse(total, 0L);

        if (totalCount == 0L) {
            return new PageImpl<>(List.of(), pageable, 0);
        }

        List<GetAlertResponseItem> content = queryFactory
            .select(Projections.constructor(
                GetAlertResponseItem.class,
                qAlert.alertUuid,
                qAlert.content,
                qAlert.createdAt,
                qAlert.sender.name
            ))
            .from(qAlert)
            .join(qAlert.receiver, qReceiver)
            .join(qAlert.sender, qSender)
            .where(qReceiver.userUuid.eq(userUuid))
            .orderBy(qAlert.createdAt.desc())
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        return new PageImpl<>(content, pageable, totalCount);
    }

    @Override
    @Transactional
    public void deleteAlertByUuidAndReceiver(String userUuid, String alertUuid) {
        queryFactory
            .delete(qAlert)
            .where(
                qAlert.alertUuid.eq(alertUuid),
                qAlert.receiver.userUuid.eq(userUuid)
            )
            .execute();
    }
}
