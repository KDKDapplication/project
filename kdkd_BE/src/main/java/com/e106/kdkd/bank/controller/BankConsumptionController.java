package com.e106.kdkd.bank.controller;

import com.e106.kdkd.bank.dto.SourceType;
import com.e106.kdkd.bank.dto.UnifiedConsumptionListRec;
import com.e106.kdkd.bank.service.BankConsumptionService;
import com.e106.kdkd.global.security.CustomPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "소비 내역 통합 조회")
@RestController
@RequestMapping("/api/bank/consumptions")
@RequiredArgsConstructor
public class BankConsumptionController {

    private final BankConsumptionService consumptionService;

    @Operation(summary = "월/일 기준 카드+계좌 소비내역 통합 조회(시간순 정렬)")
    @GetMapping
    public ResponseEntity<UnifiedConsumptionListRec> getConsumptions(
            @Parameter(description = "조회 월(YYYYMM)", example = "202509", required = true)
            @RequestParam String month,

            @Parameter(description = "조회 일(DD) — 선택. 없으면 월 전체", example = "05")
            @RequestParam(required = false) String day,

            @Parameter(description = "원천: ACCOUNT/CARD/ALL", example = "ALL")
            @RequestParam(defaultValue = "ALL") SourceType sourceType,

            @AuthenticationPrincipal(expression = "userUuid") String userUuid
    ) {
        var rec = consumptionService.queryMonthly(userUuid, month, day, sourceType);
        return ResponseEntity.ok(rec);
    }
}
