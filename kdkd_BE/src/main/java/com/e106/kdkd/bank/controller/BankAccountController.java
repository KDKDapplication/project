package com.e106.kdkd.bank.controller;

import com.e106.kdkd.bank.dto.*;
import com.e106.kdkd.bank.service.BankAccountService;
import com.e106.kdkd.global.security.CustomPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/accounts")
@Tag(name = "계좌 도메인 컨트롤러", description = "계좌 관련 API 엔드포인트")
public class BankAccountController {

    private final BankAccountService bankAccountService;

    @GetMapping("/demand-deposit/account/balance-with-offsets")
    @Operation(summary = "total_use_payment와 remain뺀값 ")
    public ResponseEntity<BalanceWithOffsetsResponse> inquireBalanceWithOffsets(
        @RequestParam String accountNo,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String userUuid = principal.userUuid();
        var res = bankAccountService.inquireDemandDepositAccountBalanceWithOffsets(accountNo, userUuid);
        return ResponseEntity.ok(res);
    }

    @GetMapping("/me")
    @Operation(
            summary = "내 계좌 조회 (JWT) — 소유자명/계좌번호/보정잔액",
            security = @SecurityRequirement(name = "bearerAuth")
    )
    public ResponseEntity<AccountInquiryResponse> inquireMyAccount(
            @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String userUuid = principal.userUuid();
        return ResponseEntity.ok(bankAccountService.inquireMyAccount(userUuid));
    }

    @DeleteMapping("/delete")
    @Operation(summary = "우리DB에서 계좌 삭제 (Hard Delete)")
    public ResponseEntity<?> deleteAccount(
        @RequestBody @Valid AccountDeleteRequest request,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String userUuid = principal.userUuid();
        bankAccountService.delete(userUuid, request);
        return ResponseEntity.ok(Map.of("message", "계좌가 삭제되었습니다."));
    }

    @PostMapping("/account-first")
    public ResponseEntity<CardIssueResponse> issueCardByAccountNumber(@Valid @RequestBody CardIssueByNumberRequest request, @AuthenticationPrincipal CustomPrincipal principal
        ) {
        String userUuid = principal.userUuid();
        return ResponseEntity.ok(
            bankAccountService.issueCreditCardByAccountNumber(request.getAccountNumber(), userUuid)
        );
    }

    @PostMapping("/account-second")
    @Operation(summary = "우리DB에 계좌 생성 1단계")
    public ResponseEntity<AccountCreateResponse> createAccount(
        @Valid @RequestBody AccountCreateRequest request) {
        AccountCreateResponse resp = bankAccountService.createAccount(request);
        return ResponseEntity.ok(resp);
    }
}
