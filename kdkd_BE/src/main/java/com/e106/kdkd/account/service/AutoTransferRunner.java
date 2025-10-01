package com.e106.kdkd.account.service;

import com.e106.kdkd.account.repository.AccountRepository;
import com.e106.kdkd.account.repository.AutoTransferRepository;
import com.e106.kdkd.boxes.service.SaveBoxService;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.AutoTransfer;
import com.e106.kdkd.global.common.entity.ParentRelation;
import com.e106.kdkd.global.exception.InsufficientFundsException;
import com.e106.kdkd.ssafy.jpa.SsafyUserRepository;
import com.e106.kdkd.ssafy.service.backend.ApiAccountService;
import java.time.LocalDate;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AutoTransferRunner {

    private final SsafyUserRepository ssafyUserRepository; // parentUuid -> ssafy_user_key
    private final AccountRepository accountRepository;     // 기본 계좌 조회
    private final ApiAccountService apiAccountService;     // 잔액검증 + 이체
    private final AutoTransferRepository autoTransferRepository;
    private final SaveBoxService saveBoxService;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void executeById(String ruleUuid, LocalDate today) {
        // 1) 규칙 재조회(영속 상태 확보)
        AutoTransfer rule = autoTransferRepository.findById(ruleUuid)
            .orElseThrow(() -> new IllegalStateException("AutoTransfer not found: " + ruleUuid));

        // 2) 관계/사용자 정보 (LAZY여도 트랜잭션 내라 안전)
        ParentRelation relation = rule.getRelation();
        String parentUuid = relation.getParent().getUserUuid();
        String childUuid = relation.getChild().getUserUuid();

        // 3) 부모 SSAFY userKey
        String parentUserKey = ssafyUserRepository.findSsafyUserKeyByUserUuid(parentUuid)
            .orElseThrow(() -> new IllegalStateException(
                "ssafy_user_key not found for parent=" + parentUuid));

        // 4) 출금/입금 계좌 (사용자당 1계좌 전제)
        Account withdrawal = accountRepository.findPrimaryByUserUuid(parentUuid)
            .orElseThrow(
                () -> new IllegalStateException("parent account not found: " + parentUuid));
        Account deposit = accountRepository.findPrimaryByUserUuid(childUuid)
            .orElseThrow(() -> new IllegalStateException("child account not found: " + childUuid));

        // 5) 금액 검증
        Long amount = rule.getAmount();
        if (amount == null || amount <= 0) {
            throw new IllegalArgumentException("amount must be positive. rule=" + ruleUuid);
        }

        // 6) 이체 수행 (잔액 부족/은행 오류는 예외로 전파)
        String memo = "Auto allowance";
        try {
            apiAccountService.customAccountTransfer(
                withdrawal,      // 출금(부모)
                deposit,         // 입금(자녀)
                amount,
                parentUserKey,
                memo, memo
            );
            log.info("[AutoTransfer] success rule={} date={} amount={}", ruleUuid, today, amount);

            try {
                saveBoxService.applyAutoSavingForChild(childUuid, "정기적금");
            } catch (Exception e) {
                log.error("[SaveBox] auto saving failed childUuid={}", childUuid, e);
            }

        } catch (InsufficientFundsException e) {
            // 잔액 부족: 재시도 무의미 → 로그만 남기고 예외 재전파(스케줄러 상위에서 잡아 로그/알림)
            log.warn("[AutoTransfer] insufficient funds. rule={} parent={} amount={}", ruleUuid,
                parentUuid, amount);
            throw e;

        } catch (RuntimeException e) {
            // 은행 점검/일시 오류/기타 시스템 예외
            log.error("[AutoTransfer] failed. rule={} parent={} amount={}", ruleUuid, parentUuid,
                amount, e);
            throw e;
        }
    }


}
