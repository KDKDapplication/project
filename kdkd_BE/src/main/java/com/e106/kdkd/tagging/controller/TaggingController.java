package com.e106.kdkd.tagging.controller;

import com.e106.kdkd.global.security.CustomPrincipal;
import com.e106.kdkd.tagging.dto.request.TagTransferRequest;
import com.e106.kdkd.tagging.service.TaggingService;
import io.swagger.v3.oas.annotations.Operation;
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

@Tag(name = "태깅 API", description = "태깅 관련 API 엔드포인트")
@RestController
@RequiredArgsConstructor
@RequestMapping("/tagging")
@Slf4j
public class TaggingController {

    private final TaggingService taggingService;

    @PostMapping("/transfer")
    @Operation(summary = "태깅 계좌이체")
    public ResponseEntity<String> tagTransfer(@RequestBody @Valid TagTransferRequest request,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String currentUserUuid = principal.userUuid();
        taggingService.tagTransfer(request, currentUserUuid);
        return ResponseEntity.ok("송금이 완료되었습니다.");
    }
}
