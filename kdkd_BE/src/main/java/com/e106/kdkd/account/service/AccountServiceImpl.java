package com.e106.kdkd.account.service;

import com.e106.kdkd.account.repository.AccountItemRepository;
import com.e106.kdkd.account.repository.AccountRepository;
import com.e106.kdkd.parents.dto.response.ChildLatestPaymetntInfo;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class AccountServiceImpl implements AccountService {

    private final AccountItemRepository accountItemRepository;
    private final AccountRepository accountRepository;

    @Override
    public ChildLatestPaymetntInfo queryLatestPaymentByParent(String parentUuid) {
        log.debug("부모의 자식들 중 최신 지출 내역 조회");
        ChildLatestPaymetntInfo info = accountItemRepository.findLatestPaymentByParentUuid(
            parentUuid).orElse(null);
        return info;
    }

    @Override
    public ChildLatestPaymetntInfo queryLatestPaymentByChild(String childUuid) {
        log.debug("자녀 자신의 제일 최근 지출 내역 조회");
        ChildLatestPaymetntInfo info = accountItemRepository.findLatestPaymentByChildUuid(
            childUuid).orElse(null);
        return info;
    }
}
