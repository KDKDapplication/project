package com.e106.kdkd.ssafy.controller;

import com.e106.kdkd.ssafy.dto.ResponseEnvelope;
import com.e106.kdkd.ssafy.dto.card.*;
import com.e106.kdkd.ssafy.service.CreditCardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/ssafy/credit-card")
@Tag(name = "Ssafy Card API", description = "카드관련 API")
public class CreditCardController {

    private final CreditCardService creditCardService;

    @Operation(summary = "신용카드 거래내역 조회")
    @GetMapping("/transactions")
    public ResponseEntity<ResponseEnvelope<InquireCreditCardTransactionListRec>> inquireCreditCardTransactionList(
            @Parameter(description = "카드 번호", example = "1005518816096479", required = true)
            @RequestParam String cardNo,

            @Parameter(description = "카드 CVC", example = "725", required = true)
            @RequestParam String cvc,

            @Parameter(description = "조회 시작일(YYYYMMDD)", example = "20240401", required = true)
            @RequestParam String startDate,

            @Parameter(description = "조회 종료일(YYYYMMDD)", example = "20240502", required = true)
            @RequestParam String endDate,

            @AuthenticationPrincipal(expression = "userUuid") String userUuid
    ) {
        InquireCreditCardTransactionListRequest req = new InquireCreditCardTransactionListRequest();
        req.setCardNo(cardNo);
        req.setCvc(cvc);
        req.setStartDate(startDate);
        req.setEndDate(endDate);

        var res = creditCardService.inquireCreditCardTransactionList(req, userUuid);
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "신용카드 발급(사용자별)")
    @PostMapping("/register")
    public ResponseEntity<ResponseEnvelope<CreateCreditCardRec>> createCreditCard(
        @Parameter(description = "신용카드 발급 요청 바디", required = true)
        @RequestBody CreateCreditCardRequest request,
        @AuthenticationPrincipal(expression = "userUuid") String userUuid
    ) {
        var res = creditCardService.createCreditCard(request, userUuid);
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "가입된 신용카드 목록 조회")
    @GetMapping("/sign-up-list")
    public ResponseEntity<ResponseEnvelope<List<SignUpCreditCardRec>>> inquireSignUpCreditCardList(
        @AuthenticationPrincipal(expression = "userUuid") String userUuid
    ) {
        var res = creditCardService.inquireSignUpCreditCardList(userUuid);
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "신용카드 상품 목록 조회")
    @GetMapping("/list")
    public ResponseEntity<ResponseEnvelope<List<CreateCreditCardProductRec>>> inquireCreditCardList() {
        var res = creditCardService.inquireCreditCardList();
        return ResponseEntity.ok(res);
    }

    @Operation(summary = "신용카드 상품 생성")
    @PostMapping("/product")
    public ResponseEntity<ResponseEnvelope<CreateCreditCardProductRec>> createCreditCardProduct(
        @Parameter(description = "신용카드 상품 생성 요청 바디", required = true)
        @RequestBody CreateCreditCardProductRequest request
    ) {
        var res = creditCardService.createCreditCardProduct(request);
        return ResponseEntity.ok(res);
    }

    @GetMapping("/issuers")
    @Operation(
        summary = "카드 발급사 코드 목록 조회"
    )
    public ResponseEntity<?> inquireCardIssuerCodesList() {
        return ResponseEntity.ok(creditCardService.inquireCardIssuerCodesList());
    }
}
