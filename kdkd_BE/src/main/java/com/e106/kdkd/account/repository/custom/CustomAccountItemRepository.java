package com.e106.kdkd.account.repository.custom;

import com.e106.kdkd.children.dto.response.PaymentResponseItem;
import com.e106.kdkd.global.common.entity.AccountItem;
import com.e106.kdkd.parents.dto.AccountItemWithSubcategory;
import com.e106.kdkd.parents.dto.response.ChildLatestPaymetntInfo;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface CustomAccountItemRepository {

    List<AccountItem> findAllByAccountSeqAndDate(Long accountSeq, LocalDate date);

    Page<PaymentResponseItem> findAllByAccountSeqAndMonth(Long accountSeq, LocalDate month,
        Pageable pageable);

    List<AccountItemWithSubcategory> findAccountItemsWithSubcategory(Long accountSeq,
        YearMonth yearMonth);

    Optional<ChildLatestPaymetntInfo> findLatestPaymentByParentUuid(String parentUuid);

    Optional<ChildLatestPaymetntInfo> findLatestPaymentByChildUuid(String childUuid);
}
