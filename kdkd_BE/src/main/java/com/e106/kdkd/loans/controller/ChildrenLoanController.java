package com.e106.kdkd.loans.controller;

import com.e106.kdkd.global.security.CustomPrincipal;
import com.e106.kdkd.loans.dto.response.RequestLoanInfo;
import com.e106.kdkd.loans.dto.resquest.LoanInfo;
import com.e106.kdkd.loans.service.LoanService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "빌리기(자녀) API", description = "빌리기(자녀) API 엔드포인트")
@RestController
@RequiredArgsConstructor
@RequestMapping("/children/loans")
@Slf4j
public class ChildrenLoanController {

    private final LoanService loanService;

    @PostMapping("")
    @Operation(summary = "빌리기 신청 API")
    public ResponseEntity<String> createLoan(
        @Valid @RequestBody RequestLoanInfo requestLoanInfo,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String childUuid = principal.userUuid();
        loanService.createLoan(childUuid, requestLoanInfo);
        return ResponseEntity.ok("빌리기 신청 성공");
    }

    @PostMapping("/{loanUuid}/payback")
    @Operation(summary = "빌리기 상환 API")
    public ResponseEntity<String> payBackLoan(
        @PathVariable String loanUuid,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String childUuid = principal.userUuid();
        loanService.payBackLoan(childUuid, loanUuid);

        return ResponseEntity.ok("빌리기 상환 성공");
    }

    @GetMapping("")
    @Operation(summary = "빌리기 조회")
    public ResponseEntity<LoanInfo> queryLoan(
        @AuthenticationPrincipal CustomPrincipal principal) {

        String childUuid = principal.userUuid();
        LoanInfo loanInfo = loanService.queryLoan(childUuid);

        return ResponseEntity.ok(loanInfo);
    }
}
