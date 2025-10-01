package com.e106.kdkd.ssafy.controller;

import com.e106.kdkd.ssafy.dto.ResponseEnvelope;
import com.e106.kdkd.ssafy.dto.accountauth.OpenAccountAuthRec;
import com.e106.kdkd.ssafy.service.BankService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/accounts")
@RequiredArgsConstructor
@Tag(name = "계좌 도메인 컨트롤러")
public class AccountAuthController {

    private final BankService bankService;

    @PostMapping("/one-won-send")
    public ResponseEnvelope<OpenAccountAuthRec> openAccountAuth(
        @RequestParam String accountNo,
        @AuthenticationPrincipal(expression = "userUuid") String userUuid
    ) {
        return bankService.openAccountAuth(accountNo, userUuid);
    }

    @PostMapping("/one-won-verification")
    public String checkAuthCode(
        @RequestParam String accountNo,
        @RequestParam String authCode,
        @AuthenticationPrincipal(expression = "userUuid") String userUuid
    ) {
        return bankService.checkAuthCode(accountNo, authCode, userUuid);
    }
}
