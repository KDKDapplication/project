package com.e106.kdkd.account.repository.custom;

import com.e106.kdkd.children.dto.response.PaymentResponseItem;
import com.e106.kdkd.global.common.entity.AccountItem;
import com.e106.kdkd.global.common.entity.QAccount;
import com.e106.kdkd.global.common.entity.QAccountItem;
import com.e106.kdkd.global.common.entity.QLifestyleMerchant;
import com.e106.kdkd.global.common.entity.QParentRelation;
import com.e106.kdkd.global.common.entity.QUser;
import com.e106.kdkd.parents.dto.AccountItemWithSubcategory;
import com.e106.kdkd.parents.dto.response.ChildLatestPaymetntInfo;
import com.querydsl.core.types.Projections;
import com.querydsl.core.types.dsl.Wildcard;
import com.querydsl.jpa.impl.JPAQueryFactory;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.YearMonth;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class CustomAccountItemRepositoryImpl implements CustomAccountItemRepository {

    private final JPAQueryFactory queryFactory;

    private final QAccountItem accountItem = QAccountItem.accountItem;
    private final QLifestyleMerchant lifestyleMerchant = QLifestyleMerchant.lifestyleMerchant;
    private final QParentRelation parentRelation = QParentRelation.parentRelation;

    private final QUser user = QUser.user;
    private final QAccount account = QAccount.account;


    @Override
    public List<AccountItem> findAllByAccountSeqAndDate(Long accountSeq, LocalDate date) {
        // 해당 날짜의 시작과 끝 시간
        LocalDateTime startOfDay = date.atStartOfDay();           // 00:00:00
        LocalDateTime endOfDay = date.atTime(LocalTime.MAX);      // 23:59:59.999999999

        return queryFactory
            .selectFrom(accountItem)
            .where(
                accountItem.account.accountSeq.eq(accountSeq),
                accountItem.transactedAt.between(startOfDay, endOfDay)
            )
            .orderBy(
                accountItem.transactedAt.desc(),     // 최신순
                accountItem.accountItemSeq.desc()    // 동시각일 때 안정적 정렬(선택)
            )
            .fetch();
    }

    @Override
    public Page<PaymentResponseItem> findAllByAccountSeqAndMonth(Long accountSeq, LocalDate month,
        Pageable pageable) {
        LocalDateTime start = month.withDayOfMonth(1).atStartOfDay();
        LocalDateTime end = month.with(TemporalAdjusters.lastDayOfMonth()).atTime(LocalTime.MAX);

        Long total = queryFactory
            .select(Wildcard.count)
            .from(accountItem)
            .where(
                accountItem.account.accountSeq.eq(accountSeq),
                accountItem.transactedAt.between(start, end)
            )
            .fetchOne();

        // DTO로 프로젝션
        var content = queryFactory
            .select(Projections.constructor(
                PaymentResponseItem.class,
                accountItem.accountItemSeq,
                accountItem.merchantName,
                accountItem.paymentBalance.intValue(),
                accountItem.transactedAt
            ))
            .from(accountItem)
            .where(
                accountItem.account.accountSeq.eq(accountSeq),
                accountItem.transactedAt.between(start, end)
            )
            .orderBy(
                accountItem.transactedAt.desc(),
                accountItem.accountItemSeq.desc()
            )
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .fetch();

        return new PageImpl<>(content, pageable, total == null ? 0L : total);
    }

    @Override
    public List<AccountItemWithSubcategory> findAccountItemsWithSubcategory(Long accountSeq,
        YearMonth yearMonth) {
        LocalDateTime start = yearMonth.atDay(1).atStartOfDay();
        LocalDateTime endExclusive = yearMonth.plusMonths(1).atDay(1).atStartOfDay();

        return queryFactory
            .select(Projections.constructor(
                AccountItemWithSubcategory.class,
                accountItem.categoryName,          // String
                accountItem.paymentBalance,        // Long
                lifestyleMerchant.subcategory.id         // Long (LEFT JOIN이므로 없으면 null)
            ))
            .from(accountItem)
            .leftJoin(lifestyleMerchant)
            .on(lifestyleMerchant.id.eq(accountItem.merchantId)) // AccountItem 기준 LEFT JOIN
            .where(
                accountItem.account.accountSeq.eq(accountSeq),
                accountItem.transactedAt.goe(start),
                accountItem.transactedAt.lt(endExclusive)
            )
            .fetch();
    }

    @Override
    public Optional<ChildLatestPaymetntInfo> findLatestPaymentByParentUuid(String parentUuid) {
        ChildLatestPaymetntInfo row = queryFactory
            .select(Projections.constructor(
                ChildLatestPaymetntInfo.class,
                user.userUuid,           // String childUuid
                user.name,               // String childName
                accountItem.accountItemSeq,    // Long accountItemSeq
                accountItem.merchantName,      // String merchantName
                accountItem.paymentBalance,    // Long paymentBalance
                accountItem.transactedAt       // LocalDateTime transactedAt
            ))
            .from(parentRelation)
            .join(parentRelation.child, user)
            .join(account).on(account.user.eq(user))
            .join(accountItem).on(accountItem.account.eq(account))
            .where(parentRelation.parent.userUuid.eq(parentUuid))
            .orderBy(accountItem.transactedAt.desc(), accountItem.accountItemSeq.desc())
            .limit(1)
            .fetchOne();

        return Optional.ofNullable(row);
    }

    @Override
    public Optional<ChildLatestPaymetntInfo> findLatestPaymentByChildUuid(String childUuid) {
        ChildLatestPaymetntInfo row = queryFactory
            .select(Projections.constructor(
                ChildLatestPaymetntInfo.class,
                user.userUuid,           // String childUuid
                user.name,               // String childName
                accountItem.accountItemSeq,    // Long accountItemSeq
                accountItem.merchantName,      // String merchantName
                accountItem.paymentBalance,    // Long paymentBalance
                accountItem.transactedAt       // LocalDateTime transactedAt
            ))
            .from(accountItem)
            .join(accountItem.account, account)
            .join(account.user, user)
            .where(user.userUuid.eq(childUuid))
            .orderBy(accountItem.transactedAt.desc(), accountItem.accountItemSeq.desc())
            .limit(1)
            .fetchOne();

        return Optional.ofNullable(row);
    }
}
