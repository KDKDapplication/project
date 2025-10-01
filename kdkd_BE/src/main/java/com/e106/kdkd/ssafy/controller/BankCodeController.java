package com.e106.kdkd.ssafy.controller;

import com.e106.kdkd.ssafy.dto.BankCodeItem;
import com.e106.kdkd.ssafy.dto.ResponseEnvelope;
import com.e106.kdkd.ssafy.service.BankCodeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@Tag(name = "Ssafy Bank API", description = "은행 관련 API")
public class BankCodeController {

    private final BankCodeService bankCodeService;

    @GetMapping("/api/banks/codes")
    @Operation(summary = "은행 목록 조회")
    public ResponseEnvelope<List<BankCodeItem>> getBankCodes() {
        return bankCodeService.inquireBankCodes();
    }
}
