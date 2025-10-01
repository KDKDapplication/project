package com.e106.kdkd.loans.controller;

import com.e106.kdkd.global.security.CustomPrincipal;
import com.e106.kdkd.loans.dto.resquest.LoanInfo;
import com.e106.kdkd.loans.service.LoanService;
import com.e106.kdkd.parents.service.ParentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "빌리기(부모) API", description = "빌리기(부모) API 엔드포인트")
@RestController
@RequiredArgsConstructor
@RequestMapping("/parents/loans")
@Slf4j
public class ParentLoanController {

    private final LoanService loanService;
    private final ParentService parentService;

    @GetMapping("")
    @Operation(summary = "빌리기 조회(부모) API")
    public ResponseEntity<LoanInfo> queryLoan(
        @RequestParam String childUuid,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String parentUuid = principal.userUuid();

        log.debug("부모 자녀 관계 검증");
        parentService.checkRelation(parentUuid, childUuid);

        LoanInfo loanInfo = loanService.queryLoan(childUuid);

        return ResponseEntity.ok(loanInfo);
    }

    @PostMapping("/{loanUuid}/accept")
    @Operation(summary = "빌리기 수락 API")
    public ResponseEntity<?> acceptLoan(
        @PathVariable String loanUuid,
        @AuthenticationPrincipal CustomPrincipal principal) {
        String parentUuid = principal.userUuid();

        loanService.acceptLoan(parentUuid, loanUuid);
        return ResponseEntity.ok("빌리기 수락 성공");
    }

    @DeleteMapping("/{loanUuid}/rejcet")
    @Operation(summary = "빌리기 거절 API")
    public ResponseEntity<?> rejectLoan(
        @PathVariable String loanUuid,
        @AuthenticationPrincipal CustomPrincipal principal) {
        String parentUuid = principal.userUuid();

        loanService.rejectLoan(parentUuid, loanUuid);
        return ResponseEntity.ok("빌리기 거절 성공");
    }

    @DeleteMapping("/loans/{loanUuid}")
    @Operation(summary = "빌리기 삭제 API")
    public ResponseEntity<?> deleteLoan(
        @PathVariable String loanUuid,
        @AuthenticationPrincipal CustomPrincipal principal) {
        String parentUuid = principal.userUuid();

        loanService.deleteLoan(parentUuid, loanUuid);
        return ResponseEntity.ok("빌리기 삭제 성공");
    }
}
