package com.e106.kdkd.account.service;

import com.e106.kdkd.account.repository.AutoTransferRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AutoTransferLockService {

    private final AutoTransferRepository autoTransferRepository;

    @Transactional
    public boolean tryAcquireMinuteLock(String ruleUuid) {
        // 조건부 UPDATE: 같은 '분'에 한 번만 성공
        return autoTransferRepository.touchIfNotExecutedWithin1min(ruleUuid) == 1;
    }

}
