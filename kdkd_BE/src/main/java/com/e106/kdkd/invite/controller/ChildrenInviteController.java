package com.e106.kdkd.invite.controller;

import com.e106.kdkd.global.security.CustomPrincipal;
import com.e106.kdkd.invite.dto.ActivateInviteResponse;
import com.e106.kdkd.invite.service.InviteCodeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "관계 연결(자녀) API", description = "관계 연결(자녀) API엔드포인트")
@RestController
@RequiredArgsConstructor
@RequestMapping("/children/invites")
public class ChildrenInviteController {

    private final InviteCodeService service;

    // 자녀: 코드 사용(1회용) → 부모-자녀 연결
    @Operation(summary = "부모 코드 입력으로 자녀 등록 API")
    @PostMapping("/activate")
    public ResponseEntity<ActivateInviteResponse> activate(@RequestParam String code,
        @AuthenticationPrincipal CustomPrincipal principal) {
        String childUuid = principal.userUuid();
        return ResponseEntity.ok(service.activate(code, childUuid));
    }
}
