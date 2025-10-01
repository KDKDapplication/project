package com.e106.kdkd.account.service;

import com.e106.kdkd.account.repository.AutoTransferRepository;
import com.e106.kdkd.global.common.entity.AutoTransfer;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class AutoTransferScheduler {

    private final AutoTransferRepository autoTransferRepository;
    private final AutoTransferRunner autoTransferRunner;
    private final AutoTransferLockService lockService;

    @Scheduled(cron = "0 * * * * *", zone = "Asia/Seoul")
    public void runDueRules() {
        var zone = ZoneId.of("Asia/Seoul");
        LocalDate today = LocalDate.now(zone);
        LocalTime nowMin = LocalTime.now(zone).withSecond(0).withNano(0);

        // 1) 현재 분과 동일한 규칙 조회
        List<AutoTransfer> candidates = autoTransferRepository.findAllByExactTime(nowMin);

        for (AutoTransfer rule : candidates) {
            // 2) 월말 보정(31/30/29)
            if (!isDueToday(rule, today)) {
                continue;
            }

            // 3) 같은 분 선점 시도(원자적)
            boolean acquired = lockService.tryAcquireMinuteLock(rule.getAutoTransferUuid());
            if (!acquired) {
                log.info("skip duplicated in same minute: {}", rule.getAutoTransferUuid());
                continue; // 이미 누가 선점함 → 중복 실행 방지
            }

            try {
                autoTransferRunner.executeById(rule.getAutoTransferUuid(), today);
            } catch (Exception e) {
                // 같은 분 재시도는 막힌 상태(정책적으로 OK)
                log.error("[AutoTransfer] execution failed. rule={}", rule.getAutoTransferUuid(),
                    e);
            }
        }
    }

    // 31일 지정이면 30/28~29일엔 그 달 마지막 날에 실행
    private boolean isDueToday(AutoTransfer rule, LocalDate today) {
        int configuredDay = rule.getTransferDay();
        int lastDay = today.lengthOfMonth();
        int effectiveDay = Math.min(configuredDay, lastDay);
        return today.getDayOfMonth() == effectiveDay;
    }
}