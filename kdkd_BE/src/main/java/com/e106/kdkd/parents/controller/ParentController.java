package com.e106.kdkd.parents.controller;

import com.e106.kdkd.account.service.AccountService;
import com.e106.kdkd.children.dto.response.PaymentResponse;
import com.e106.kdkd.children.service.ChildrenService;
import com.e106.kdkd.global.security.CustomPrincipal;
import com.e106.kdkd.parents.dto.response.ChildAccount;
import com.e106.kdkd.parents.dto.response.ChildLatestPaymetntInfo;
import com.e106.kdkd.parents.dto.response.ChildPaymentDetail;
import com.e106.kdkd.parents.dto.response.TwoMonthPattern;
import com.e106.kdkd.parents.service.ParentService;
import io.swagger.v3.oas.annotations.Hidden;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.time.YearMonth;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "부모 도메인 API", description = "부모 도메인 API 엔드포인트")
@RestController
@RequiredArgsConstructor
@RequestMapping("/parents")
@Slf4j
public class ParentController {

    private final ParentService parentService;
    private final ChildrenService childrenService;
    private final AccountService accountService;

    @GetMapping("/children/accounts")
    @Operation(summary = "자녀 계좌 목록 조회")
    public ResponseEntity<List<ChildAccount>> getChildAccounts(
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String parentUuid = principal.userUuid();
        log.debug("자녀 계좌 목록 조회");
        List<ChildAccount> childAccounts = parentService.queryChildAccounts(parentUuid);

        return ResponseEntity.ok(childAccounts);
    }

    @GetMapping("/{childUuid}/payments")
    @Operation(summary = "자녀 결제 내역 조회")
    public ResponseEntity<PaymentResponse> getChildPayments(
        @PathVariable String childUuid,
        @RequestParam @DateTimeFormat(pattern = "yyyyMM") YearMonth month,
        @RequestParam int pageNum,
        @RequestParam int display,
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String parentUuid = principal.userUuid();
        log.debug("자녀 부모 연결 관계 검증");
        parentService.isLinked(parentUuid, childUuid);
        log.debug("자녀 결제 내역 조회");

        PaymentResponse paymentResponse = childrenService.getPayments(childUuid, month.atDay(1),
            pageNum, display);

        return ResponseEntity.ok(paymentResponse);
    }

    @GetMapping("/{childUuid}/payments/{accountItemSeq}")
    @Operation(summary = "자녀 결제 내역 상세 조회")
    public ResponseEntity<ChildPaymentDetail> getChildPaymentDetail(
        @PathVariable String childUuid,
        @PathVariable Long accountItemSeq,
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String parentUuid = principal.userUuid();
        log.debug("자녀 부모 연결 관계 검증");
        parentService.isLinked(parentUuid, childUuid);
        log.debug("자녀 결제 내역 상세 조회");
        ChildPaymentDetail childPaymentDetail = parentService.queryChildPaymentDetail(childUuid,
            accountItemSeq);

        return ResponseEntity.ok(childPaymentDetail);
    }

    @GetMapping("/{childUuid}/pattern")
    @Operation(summary = "자녀 소비 패턴 조회")
    public ResponseEntity<TwoMonthPattern> getChildPattern(
        @PathVariable String childUuid,
        @RequestParam YearMonth yearMonth,
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String parentUuid = principal.userUuid();

        log.debug("자녀 부모 연결 관계 검증");
        parentService.isLinked(parentUuid, childUuid);

        log.debug("자녀 소비 패턴 조회");
        TwoMonthPattern twoMonthPattern = parentService.queryChildPattern(childUuid, yearMonth);

        return ResponseEntity.ok(twoMonthPattern);
    }

    @GetMapping("/{childUuid}/feedback")
    @Operation(summary = "자녀 소비 내역 AI 피드백 조회")
    @Hidden
    public ResponseEntity<?> getAiFeedback(
        @PathVariable String childUuid,
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String parentUuid = principal.userUuid();
        log.debug("자녀 부모 연결 관계 검증");
        parentService.isLinked(parentUuid, childUuid);
        return ResponseEntity.ok("OK");
    }

    @GetMapping("/auto-transfer")
    @Operation(summary = "자녀 용돈 자동이체 총액 조회")
    public ResponseEntity<?> getAutoTransferAmount(
        @AuthenticationPrincipal CustomPrincipal principal) {
        String parentUuid = principal.userUuid();

        return ResponseEntity.ok(parentService.getAutoTransferAmount(parentUuid));
    }

    @GetMapping("/latest-payment")
    @Operation(summary = "자녀들 중 제일 최근 결제 조회 API")
    public ResponseEntity<?> queryLatestPayment(
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String parentUuid = principal.userUuid();

        ChildLatestPaymetntInfo info = accountService.queryLatestPaymentByParent(parentUuid);
        return ResponseEntity.ok(info);
    }

}
