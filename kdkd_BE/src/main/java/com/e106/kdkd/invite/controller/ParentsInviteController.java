package com.e106.kdkd.invite.controller;

import com.e106.kdkd.global.security.CustomPrincipal;
import com.e106.kdkd.invite.dto.CreateInviteCodeResponse;
import com.e106.kdkd.invite.service.InviteCodeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "관계 연결(부모) API", description = "관계 연결(부모) API 엔드포인트")
@RestController
@RequiredArgsConstructor
@RequestMapping("/parents/invites")
public class ParentsInviteController {

    private final InviteCodeService service;

    // 부모: 코드 발급/재발급 (기존 코드가 있으면 삭제 후 새로 발급)
    @Operation(summary = "부모 코드 생성 API")
    @PostMapping("/code")
    public ResponseEntity<CreateInviteCodeResponse> create(
        @AuthenticationPrincipal CustomPrincipal principal) {
        String parentUuid = principal.userUuid();
        return ResponseEntity.ok(service.createCode(parentUuid, 600L));
    }
}
