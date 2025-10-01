package com.e106.kdkd.children.controller;

import com.e106.kdkd.account.service.AccountService;
import com.e106.kdkd.children.dto.request.ChildrenRegisterRequest;
import com.e106.kdkd.children.service.ChildrenService;
import com.e106.kdkd.global.security.CustomPrincipal;
import com.e106.kdkd.parents.dto.response.ChildLatestPaymetntInfo;
import io.swagger.v3.oas.annotations.Hidden;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.time.YearMonth;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "자식 도메인 API", description = "자식 도메인 API 엔드포인트")
@RestController
@RequiredArgsConstructor
@RequestMapping("/children")
@Slf4j
public class ChildrenController {

    private final ChildrenService childrenService;
    private final AccountService accountService;

    @PostMapping("/register")
    @Operation(summary = "자녀 신청 API")
    @Hidden
    public ResponseEntity<?> registerChildren(@RequestBody ChildrenRegisterRequest request,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String currentUserUuid = principal.userUuid();
        return ResponseEntity.ok(childrenService.registerChild(currentUserUuid, request));
    }

    @GetMapping("/characters")
    @Operation(summary = "키덕키덕 데이터 조회")
    public ResponseEntity<?> getCharacters(@AuthenticationPrincipal CustomPrincipal principal) {

        String currentUserUuid = principal.userUuid();
        return ResponseEntity.ok(childrenService.getCharacters(currentUserUuid));
    }

    @GetMapping("/payments")
    @Operation(summary = "결제 내역 조회")
    public ResponseEntity<?> getPayments(@AuthenticationPrincipal CustomPrincipal principal,
        @RequestParam @DateTimeFormat(pattern = "yyyyMM") YearMonth month,
        @RequestParam int pageNum,
        @RequestParam int display) {

        String currentUserUuid = principal.userUuid();
        return ResponseEntity.ok(
            childrenService.getPayments(currentUserUuid, month.atDay(1), pageNum, display));
    }

    @GetMapping("/latest-payment")
    @Operation(summary = "자녀 자신의 제일 최근 결제 조회 API")
    public ResponseEntity<?> queryLatestPayment(
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String childUuid = principal.userUuid();

        ChildLatestPaymetntInfo info = accountService.queryLatestPaymentByChild(childUuid);
        return ResponseEntity.ok(info);
    }

}
