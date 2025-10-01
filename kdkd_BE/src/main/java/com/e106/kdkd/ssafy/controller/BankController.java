package com.e106.kdkd.ssafy.controller;

import com.e106.kdkd.ssafy.dto.*;
import com.e106.kdkd.ssafy.service.BankService;
import com.e106.kdkd.ssafy.util.BankApiException;
import io.swagger.v3.oas.annotations.*;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import com.e106.kdkd.global.security.CustomPrincipal;

@RestController
@RequestMapping("/api/banks")
@RequiredArgsConstructor
@Tag(name = "Ssafy Bank API")
public class BankController {

    private final BankService bankService;

    @Operation(summary = "수시입출금 계좌 잔액 조회")
    @GetMapping("/demand-deposit/account/balance")
    public ResponseEntity<ResponseEnvelope<DemandDepositAccountBalance>> inquireDemandDepositAccountBalance(
        @Parameter(description = "조회할 계좌번호", example = "0016174648358792", required = true)
        @RequestParam String accountNo,
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String userUuid = principal.userUuid();
        var res = bankService.inquireDemandDepositAccountBalance(accountNo, userUuid);
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "수시입출금 계좌 소유주명 조회")
    @GetMapping("/demand-deposit/account/holder")
    public ResponseEntity<ResponseEnvelope<DemandDepositAccountHolder>> inquireDemandDepositAccountHolderName(
        @Parameter(description = "조회할 계좌번호", required = true, example = "0016174648358792")
        @RequestParam String accountNo,
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String userUuid = principal.userUuid();
        var res = bankService.inquireDemandDepositAccountHolderName(accountNo, userUuid);
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "수시입출금 계좌 목록 조회")
    @GetMapping("/demand-deposit/accounts")
    public ResponseEntity<ResponseEnvelope<List<DemandDepositAccountItem>>> inquireDemandDepositAccountList(
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String userUuid = principal.userUuid();
        var res = bankService.inquireDemandDepositAccountList(userUuid);
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "수시입출금 계좌 입금")
    @PostMapping("/demand-deposit/account/deposit")
    public ResponseEntity<ResponseEnvelope<DemandDepositAccountDepositRec>> updateDemandDepositAccountDeposit(
        @Parameter(description = "입금 계좌번호", required = true) @RequestParam String accountNo,
        @Parameter(description = "거래 금액(원)", required = true) @RequestParam String transactionBalance,
        @Parameter(description = "거래 요약", required = true) @RequestParam String transactionSummary,
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String userUuid = principal.userUuid();
        var res = bankService.updateDemandDepositAccountDeposit(accountNo, transactionBalance, transactionSummary, userUuid);
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "수시입출금 계좌 출금")
    @PostMapping("/demand-deposit/account/withdrawal")
    public ResponseEntity<ResponseEnvelope<DemandDepositAccountWithdrawalRec>> updateDemandDepositAccountWithdrawal(
        @RequestParam String accountNo,
        @RequestParam String transactionBalance,
        @RequestParam String transactionSummary,
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String userUuid = principal.userUuid();
        var res = bankService.updateDemandDepositAccountWithdrawal(accountNo, transactionBalance, transactionSummary, userUuid);
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "수시입출금 계좌 이체")
    @PostMapping("/demand-deposit/account/transfer")
    public ResponseEntity<ResponseEnvelope<List<DemandDepositAccountTransferItem>>> updateDemandDepositAccountTransfer(
            @Parameter(description = "입금 계좌번호", example = "0204667768182760", required = true)
            @RequestParam String depositAccountNo,

            @Parameter(description = "입금 거래 요약", example = "(수시입출금) : 입금(이체)", required = true)
            @RequestParam String depositTransactionSummary,

            @Parameter(description = "거래 금액", example = "10000000", required = true)
            @RequestParam String transactionBalance,

            @Parameter(description = "출금 계좌번호", example = "0016174648358792", required = true)
            @RequestParam String withdrawalAccountNo,

            @Parameter(description = "출금 거래 요약", example = "(수시입출금) : 출금(이체)", required = true)
            @RequestParam String withdrawalTransactionSummary,

            @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String userUuid = principal.userUuid();
        var res = bankService.updateDemandDepositAccountTransfer(
                depositAccountNo, depositTransactionSummary, transactionBalance,
                withdrawalAccountNo, withdrawalTransactionSummary, userUuid
        );
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "수시입출금 거래내역 조회")
    @GetMapping("/demand-deposit/account/transactions")
    public ResponseEntity<ResponseEnvelope<TransactionHistoryRec>> inquireTransactionHistoryList(
            @Parameter(description = "계좌번호", example = "0016174648358792")
            @RequestParam String accountNo,

            @Parameter(description = "조회 시작일(YYYYMMDD)", example = "20250901")
            @RequestParam String startDate,

            @Parameter(description = "조회 종료일(YYYYMMDD)", example = "20250923")
            @RequestParam String endDate,

            @Parameter(description = "거래유형: A(전체) / D(출금) / C(입금)", example = "A")
            @RequestParam(defaultValue = "A") String transactionType,

            @Parameter(description = "정렬: ASC / DESC", example = "ASC")
            @RequestParam(defaultValue = "ASC") String orderByType,

            @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String userUuid = principal.userUuid();
        var res = bankService.inquireTransactionHistoryList(accountNo, startDate, endDate, transactionType, orderByType, userUuid);
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "수시입출금 거래 단건 조회")
    @GetMapping("/demand-deposit/account/transaction")
    public ResponseEntity<ResponseEnvelope<TransactionHistoryItem>> inquireTransactionHistory(
        @RequestParam String accountNo,
        @RequestParam String transactionUniqueNo,
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String userUuid = principal.userUuid();
        var res = bankService.inquireTransactionHistory(accountNo, transactionUniqueNo, userUuid);
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "수시입출금 계좌 해지")
    @PostMapping("/demand-deposit/account/delete")
    public ResponseEntity<ResponseEnvelope<DemandDepositAccountDeleteRec>> deleteDemandDepositAccount(
        @RequestParam String accountNo,
        @RequestParam String refundAccountNo,
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String userUuid = principal.userUuid();
        var res = bankService.deleteDemandDepositAccount(accountNo, refundAccountNo, userUuid);
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "수시입출금 상품 목록 조회")
    @GetMapping("/demand-deposit/list")
    public ResponseEntity<ResponseEnvelope<List<CreateDemandDepositRec>>> inquireDemandDepositList() {
        var res = bankService.inquireDemandDepositList();
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "수시입출금 상품 등록")
    @PostMapping("/demand-deposit")
    public ResponseEntity<ResponseEnvelope<CreateDemandDepositRec>> createDemandDeposit(
        @RequestParam String bankCode,
        @RequestParam String accountName,
        @RequestParam String accountDescription
    ) {
        var res = bankService.createDemandDeposit(bankCode, accountName, accountDescription);
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "수시입출금 계좌 생성")
    @PostMapping("/demand-deposit/account")
    public ResponseEntity<ResponseEnvelope<CreateDemandDepositAccountRec>> createDemandDepositAccount(
        @RequestParam String accountTypeUniqueNo,
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String userUuid = principal.userUuid();
        var res = bankService.createDemandDepositAccount(accountTypeUniqueNo, userUuid);
        return ResponseEntity.ok(res);
    }

    @ExceptionHandler(BankApiException.class)
    public ResponseEntity<ResponseEnvelope<?>> handleBankApiException(BankApiException e) {
        return ResponseEntity.badRequest().body(e.getErrorResponse());
    }
}
