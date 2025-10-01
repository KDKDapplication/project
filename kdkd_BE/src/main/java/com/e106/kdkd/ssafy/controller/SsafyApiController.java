package com.e106.kdkd.ssafy.controller;

import com.e106.kdkd.ssafy.dto.SsafyMemberEnrollRequest;
import com.e106.kdkd.ssafy.service.SsafyApiService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/ssafy")
@Tag(name = "Ssafy API", description = "SSAFY key 발급 및 회원관리")
public class SsafyApiController {

    private final SsafyApiService ssafyApiService; // 인터페이스 타입으로 주입

    @GetMapping("/issue")
    @Operation(summary = "SSAFY Api key 발급")
    public ResponseEntity<?> issue() {
        return ResponseEntity.ok(ssafyApiService.issueApiKey());
    }

    @GetMapping("/reissue")
    @Operation(summary = "SSAFY Api key 재발급, 누르지마시오.")
    public ResponseEntity<?> reIssue() {
        return ResponseEntity.ok(ssafyApiService.reIssueApiKey());
    }

    @PostMapping("/member")
    @Operation(summary = "SSAFY 은행 회원 등록", description = "JSON body로 userEmail을 전달하면 서버가 apiKey를 붙여 SSAFY에 등록")
    public ResponseEntity<?> enroll(@RequestBody SsafyMemberEnrollRequest req) {
        return ResponseEntity.ok(ssafyApiService.enrollMember(req.getUserEmail()));
    }

    @GetMapping("/member/search")
    @Operation(summary = "SSAFY 회원 조회")
    public ResponseEntity<?> search(@RequestParam("userEmail") String userEmail) {
        return ssafyApiService.searchMember(userEmail)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("error", "member_not_found")));
    }
}
