package com.e106.kdkd.fcm.controller;

import com.e106.kdkd.fcm.dto.request.RegisterTokenRequest;
import com.e106.kdkd.fcm.dto.request.UnregisterTokenRequest;
import com.e106.kdkd.fcm.dto.response.UnregisterTokenResponse;
import com.e106.kdkd.fcm.service.FcmService;
import com.e106.kdkd.global.security.CustomPrincipal;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "FCM 알림 API", description = "FCM 관련 API 엔드포인트")
@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/fcm")
public class FcmController {

    private final FcmService fcmService;

    @PostMapping("/register")
    public ResponseEntity<?> register(
        @Valid @RequestBody RegisterTokenRequest registerTokenRequest,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String currentUserUuid = principal.userUuid();
        var res = fcmService.registerToken(currentUserUuid, registerTokenRequest);
        return ResponseEntity.ok(res);
    }

    @PostMapping("/unregister")
    public ResponseEntity<?> unregister(
        @Valid @RequestBody UnregisterTokenRequest unregisterTokenRequest,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String currentUserUuid = principal.userUuid();
        int affected = fcmService.unregisterToken(currentUserUuid, unregisterTokenRequest);
        return ResponseEntity.ok(new UnregisterTokenResponse(affected));
    }
}
