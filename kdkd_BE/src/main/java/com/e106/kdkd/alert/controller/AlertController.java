package com.e106.kdkd.alert.controller;

import com.e106.kdkd.alert.service.AlertService;
import com.e106.kdkd.global.security.CustomPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "알림 도메인 API", description = "알림 도메인 API 엔드포인트")
@RestController
@RequiredArgsConstructor
@RequestMapping("/alert")
@Slf4j
public class AlertController {

    private final AlertService alertService;

    @GetMapping("/list")
    @Operation(summary = "알림 목록 조회")
    public ResponseEntity<?> getAlerts(@AuthenticationPrincipal CustomPrincipal principal,
        @RequestParam int pageNum,
        @RequestParam int display) {
        String currentUserUuid = principal.userUuid();
        return ResponseEntity.ok(
            alertService.getAlerts(currentUserUuid, pageNum, display));
    }

    @DeleteMapping("/{alertUuid}")
    @Operation(summary = "알림 개별 삭제")
    public ResponseEntity<String> deleteAlert(@AuthenticationPrincipal CustomPrincipal principal,
        @PathVariable String alertUuid) {
        String currentUserUuid = principal.userUuid();
        alertService.deleteAlert(currentUserUuid, alertUuid);

        return ResponseEntity.ok("알림이 삭제되었습니다.");
    }

    @DeleteMapping
    @Operation(summary = "알림 전체 삭제")
    public ResponseEntity<String> deleteAllAlerts(
        @AuthenticationPrincipal CustomPrincipal principal) {
        String currentUserUuid = principal.userUuid();

        return ResponseEntity.ok(
            String.format("알림 %d개가 삭제되었습니다.", alertService.deleteAllAlert(currentUserUuid)));
    }
}
