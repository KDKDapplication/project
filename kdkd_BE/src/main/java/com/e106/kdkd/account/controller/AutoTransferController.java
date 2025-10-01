package com.e106.kdkd.account.controller;

import com.e106.kdkd.account.dto.request.AutoTransferCreateRequest;
import com.e106.kdkd.account.dto.request.AutoTransferDeleteRequest;
import com.e106.kdkd.account.dto.request.AutoTransferUpdateRequest;
import com.e106.kdkd.account.service.AutoTransferService;
import com.e106.kdkd.global.security.CustomPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@Tag(name = "계좌 도메인 컨트롤러")
@RequestMapping("/accounts/auto-transfer")
public class AutoTransferController {

    private final AutoTransferService autoTransferService;

    @DeleteMapping("/delete")
    @Operation(summary = "자동이체 규칙 삭제")
    public ResponseEntity<?> delete(@RequestBody @Valid AutoTransferDeleteRequest request,
        @AuthenticationPrincipal CustomPrincipal principal) {
        String parentUuid = principal.userUuid();
        autoTransferService.delete(parentUuid, request);
        return ResponseEntity.ok(Map.of("message", "자동이체 규칙이 삭제되었습니다."));
    }

    @PatchMapping("/modify")
    @Operation(summary = "자동이체 규칙 수정")
    public ResponseEntity<?> update(@RequestBody @Valid AutoTransferUpdateRequest request,
        @AuthenticationPrincipal CustomPrincipal principal) {
        String parentUuid = principal.userUuid();
        autoTransferService.update(parentUuid, request);
        return ResponseEntity.ok(Map.of("message", "자동이체 규칙이 수정되었습니다."));
    }

    @GetMapping("/list")
    @Operation(summary = "부모 자동이체 목록")
    public ResponseEntity<?> list(
        @AuthenticationPrincipal com.e106.kdkd.global.security.CustomPrincipal principal) {
        String parentUuid = principal.userUuid();

        var resp = autoTransferService.listForParent(parentUuid);

        return ResponseEntity.ok(Map.of("auto-transfers", resp.getAutoTransfers()));
    }

    @PostMapping("/register")
    @Operation(summary = "자녀 자동이체 규칙 등록")
    public ResponseEntity<?> register(@RequestBody @Valid AutoTransferCreateRequest request,
        @AuthenticationPrincipal CustomPrincipal principal) {
        String parentUuid = principal.userUuid();

        return ResponseEntity.ok(autoTransferService.create(parentUuid, request));
    }

    @GetMapping("/children")
    @Operation(summary = "자녀의 자동이체 금액 조회")
    public ResponseEntity<?> queryChildAutoTransferAmount(
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String childUuid = principal.userUuid();
        Long amount = autoTransferService.queryChildAutoTransferAmount(childUuid);
        return ResponseEntity.ok(amount);
    }
}
