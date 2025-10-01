package com.e106.kdkd.users.controller;

import com.e106.kdkd.global.security.CustomPrincipal;
import com.e106.kdkd.users.dto.request.UserUpdateRequest;
import com.e106.kdkd.users.dto.response.UserResponse;
import com.e106.kdkd.users.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "유저 API", description = "유저 정보 관련 API")
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<?> me(@AuthenticationPrincipal CustomPrincipal principal) {
        if (principal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("토큰 없음/인증 실패");
        }
        UserResponse body = userService.getMyProfile(principal.userUuid());

        return ResponseEntity.ok(body);
    }

    @Operation(summary = "내 정보 수정", description = "name, birthdate(YYYY-MM-DD) 수정")
    @PatchMapping("/me")
    public ResponseEntity<?> updateMe(
        @AuthenticationPrincipal CustomPrincipal principal,
        @Valid @RequestBody UserUpdateRequest req
    ) {
        if (principal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("토큰 없음/인증 실패");
        }
        UserResponse body = userService.updateMyProfile(principal.userUuid(), req);
        return ResponseEntity.ok(body);
    }

    @PostMapping(value = "/users/me/profile", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> uploadMyProfile(
        @AuthenticationPrincipal CustomPrincipal principal,
        @RequestPart("file") MultipartFile file
    ) {
        if (principal == null) {
            return ResponseEntity.status(401).body(Map.of("error", "unauthorized"));
        }

        String url = userService.updateMyProfileImage(principal.userUuid(), file);
        return ResponseEntity.ok(Map.of("profileUrl", url));
    }

    @DeleteMapping("/users/me")
    public ResponseEntity<?> deleteMyAccount(
        @AuthenticationPrincipal CustomPrincipal principal,
        @RequestBody(required = false) Map<String, Object> body
    ) {
        if (principal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("error", "unauthorized"));
        }
        String providerName = body != null ? (String) body.get("reauthProvider") : null;
        String providerAccessToken = body != null ? (String) body.get("providerAccessToken") : null;

        userService.deleteMyAccount(principal.userUuid(), providerName, providerAccessToken);

        return ResponseEntity.ok(Map.of("msg", "account_deleted"));
    }
}
