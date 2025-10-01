package com.e106.kdkd.openai.controller;

import com.e106.kdkd.global.security.CustomPrincipal;
import com.e106.kdkd.openai.service.GmsProxyService;
import com.e106.kdkd.parents.service.ParentService;
import io.swagger.v3.oas.annotations.Hidden;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.time.YearMonth;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
@Tag(name = "AI 모델 API", description = "JWT 인증 후 GMS 프록시 호출")
@Slf4j
public class GmsController {

    private final GmsProxyService gmsProxyService;
    private final ParentService parentService;

    @Operation(
        summary = "질문하고 답변 받기 (기본 모델: gpt-5)",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @PostMapping(value = "/ask", produces = MediaType.TEXT_PLAIN_VALUE) // ← 오직 text/plain
    @Hidden
    public ResponseEntity<String> ask(
        @AuthenticationPrincipal CustomPrincipal principal,
        @Parameter(description = "모델에 보낼 질문", required = true,
            example = "2024년 총 생산량 요약해줘")
        @RequestParam(name = "question") String question
    ) {
        String answer = gmsProxyService.ask(question); // ← 내부에서 text만 추출
        return ResponseEntity.ok()
            .contentType(MediaType.TEXT_PLAIN)
            .body(answer);
    }

    @GetMapping("{childUuid}/feedback")
    @Operation(summary = "해당 월연 소비내역 ai 피드백")
    public ResponseEntity<String> getAiFeedback(
        @AuthenticationPrincipal CustomPrincipal principal,
        @RequestParam YearMonth yearMonth,
        @PathVariable String childUuid
    ) {
        String parentUuid = principal.userUuid();

        log.debug("부모 자녀 연결 관계 검증");
        parentService.isLinked(parentUuid, childUuid);

        String feedbackText = gmsProxyService.getAiFeedback(childUuid, yearMonth, null);

        return ResponseEntity.ok(feedbackText);
    }
}