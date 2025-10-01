package com.e106.kdkd.qr.controller;

import com.e106.kdkd.qr.dto.request.RequestPayInfo;
import com.e106.kdkd.qr.service.QrService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "qr 결제 도메인 API", description = "qr 결제 도메인 API 엔드포인트")
@RestController
@RequiredArgsConstructor
@RequestMapping("/qr")
@Slf4j
public class QrController {

    private final QrService qrService;

    @PostMapping("")
    @Operation(summary = "qr 결제 api")
    public ResponseEntity<?> processQrPayment(
        @RequestBody RequestPayInfo requestPayInfo
    ) {
        Long merchantId = 13784L;
        qrService.processQrPayment(merchantId, requestPayInfo);
        return ResponseEntity.ok("qr 결제 성공");
    }

    @PostMapping("{merchantId}/test")
    @Operation(summary = "qr 결제 test api")
    public ResponseEntity<?> processQrPaymentWithMerchantId(
        @RequestBody RequestPayInfo requestPayInfo,
        @PathVariable Long merchantId

    ) {
        qrService.processQrPayment(merchantId, requestPayInfo);
        return ResponseEntity.ok("qr 결제 성공");
    }
}
