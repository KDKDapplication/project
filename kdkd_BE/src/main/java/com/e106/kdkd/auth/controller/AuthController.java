package com.e106.kdkd.auth.controller;


import com.e106.kdkd.auth.dto.internal.TempSignupData;
import com.e106.kdkd.auth.dto.request.DevUuidRequest;
import com.e106.kdkd.auth.dto.request.GoogleLoginRequest;
import com.e106.kdkd.auth.dto.request.OnboardRequest;
import com.e106.kdkd.auth.dto.request.RefreshRequest;
import com.e106.kdkd.auth.dto.response.AuthResponse;
import com.e106.kdkd.auth.dto.response.SignupTokenResponse;
import com.e106.kdkd.auth.service.GoogleTokenVerifierService;
import com.e106.kdkd.auth.service.TempSignupService;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.common.enums.FileCategory;
import com.e106.kdkd.global.common.enums.Provider;
import com.e106.kdkd.global.common.enums.RelatedType;
import com.e106.kdkd.global.security.CustomPrincipal;
import com.e106.kdkd.global.util.JWTService;
import com.e106.kdkd.global.util.RefreshTokenService;
import com.e106.kdkd.s3.service.S3Service;
import com.e106.kdkd.users.repository.UserRepository;
import com.e106.kdkd.users.service.UserService;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "Auth", description = "인증 관련 API")
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final GoogleTokenVerifierService googleVerifier;
    private final TempSignupService tempSignupService;
    private final UserService userService;
    private final JWTService jwtService;
    private final RefreshTokenService refreshTokenService;
    private final S3Service fileService;
    private final UserRepository userRepository;

    @Operation(
        summary = "구글 로그인 (idToken)",
        description = "클라이언트에서 발급받은 Google id_token 을 서버로 전달하여 검증하고, " +
            "검증 성공 시 서비스 전용 accessToken(짧음)과 refreshToken(장기)을 발급합니다. " +
            "자동 회원가입이 진행됩니다."
    )
    @PostMapping("/login/google")
    public ResponseEntity<?> googleLogin(@Valid @RequestBody GoogleLoginRequest req) {
        String raw = req.getIdToken();
        if (raw == null || raw.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "idToken_required"));
        }
        String idToken = raw.trim();

        // dev용 디버깅: 길이/앞뒤 일부만 찍음(운영에서는 비활성화)
        log.debug("received idToken length={}, start={}..., end={}...",
            idToken.length(),
            idToken.length() > 20 ? idToken.substring(0, 10) : idToken,
            idToken.length() > 20 ? idToken.substring(idToken.length() - 10) : idToken
        );

        try {
            // 1) Google id_token 검증
            GoogleIdToken.Payload payload = googleVerifier.verify(idToken);

            // 2) payload에서 정보 추출
            String googleSub = payload.getSubject();
            String email = payload.getEmail();
            boolean emailVerified = Boolean.TRUE.equals(payload.getEmailVerified());

            if (!emailVerified) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "email_not_verified"));
            }

            // 1) 기존 사용자 체크 (활성 사용자만)
            Optional<User> existing = userService.findActiveByProviderSub(Provider.GOOGLE,
                googleSub);
            if (existing.isPresent()) {
                User user = existing.get();
                String access = jwtService.createAccessToken(user);
                String refresh = refreshTokenService.createAndSave(user.getUserUuid());

                long expiresInSec =
                    (jwtService.parseToken(access).getBody().getExpiration().getTime()
                        - Instant.now().toEpochMilli()) / 1000;
                AuthResponse resp = AuthResponse.builder()
                    .accessToken(access)
                    .refreshToken(refresh)
                    .userUuid(user.getUserUuid())
                    .expiresIn(expiresInSec)
                    .build();
                return ResponseEntity.ok(resp);
            }
            // 2) 신규 온보딩 필요 → signupToken 발급
            String signupToken = tempSignupService.createAndSave(googleSub, email);
            SignupTokenResponse resp = SignupTokenResponse.builder()
                .onboardingRequired(true)
                .signupToken(signupToken)
                .isNewUser(true)
                .build();
            return ResponseEntity.ok(resp);

        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(Map.of("error", ex.getMessage()));
        } catch (Exception ex) {
            // google token 검증 실패, 네트워크 문제 등
            log.warn("google verify failed: {}", ex.getMessage(), ex); // dev에서만 찍도록 로깅 레벨/프로파일 관리
            return ResponseEntity.status(401)
                .body(Map.of("error", "invalid_google_token", "detail", ex.getMessage()));
        }
    }


    @Operation(summary = "온보딩 완료", description = "signupToken과 사용자가 입력한 정보(role, name, birthdate) + 프로필 이미지를 받아 계정을 생성하고 토큰을 발급")
    @PostMapping(value = "/onboard", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> onboard(
        @RequestPart("payload") @Valid OnboardRequest req,
        @RequestPart(value = "profile", required = false) MultipartFile profile
    ) {
        // 1) signupToken 검증 및 소비
        Optional<TempSignupData> opt = tempSignupService.verifyAndConsume(req.getSignupToken());
        if (opt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(Map.of("error", "invalid_or_expired_signup_token"));
        }
        TempSignupData signup = opt.get();

        // 2) 실제 사용자 생성
        User user = userService.createUserForGoogleOnboarding(
            signup.getGoogleSub(),
            signup.getEmail(),
            req.getName(),
            req.getBirthdate(), // null 허용
            req.getRole()       // 타입 맞춰 전달
        );

        // 3) (선택) 프로필 업로드
        if (profile != null && !profile.isEmpty()) {
            try {
                fileService.uploadFile(
                    profile,
                    FileCategory.IMAGES,
                    RelatedType.USER_PROFILE,
                    user.getUserUuid(), // << 여기!
                    1
                );
            } catch (Exception e) {
                log.warn("Profile upload failed for userUuid={}, reason={}", user.getUserUuid(),
                    e.getMessage());
            }
        }

        // 4) 토큰 발급 (새로 생성)
        String access = jwtService.createAccessToken(user);
        String refresh = refreshTokenService.createAndSave(user.getUserUuid());
        long expiresInSec =
            (jwtService.parseToken(access).getBody().getExpiration().getTime() - Instant.now()
                .toEpochMilli()) / 1000;
        AuthResponse resp = AuthResponse.builder()
            .accessToken(access)
            .refreshToken(refresh)
            .userUuid(user.getUserUuid())
            .expiresIn(expiresInSec)
            .build();

        return ResponseEntity.ok(resp);
    }

    @Operation(
        summary = "리프레시 토큰으로 Access 재발급",
        description = "클라이언트가 보유한 refreshToken 을 전달하면 서버에서 유효성 검증 후 " +
            "새로운 refreshToken 과 accessToken을 발급합니다."
    )
    @PostMapping("/refresh")
    public ResponseEntity<?> refresh(@Valid @RequestBody RefreshRequest req) {
        String rawRefresh = req.getRefreshToken();
        Optional<RefreshTokenService.RefreshTokenData> opt = refreshTokenService.verifyAndGet(
            rawRefresh);
        if (opt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("error", "invalid_refresh_token"));
        }

        String userUuid = opt.get().getUserUuid();
        User user = userRepository.findById(userUuid).orElse(null);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("error", "user_not_found"));
        }

        String newRefresh = refreshTokenService.rotate(rawRefresh, userUuid);
        String newAccess = jwtService.createAccessToken(user);

        AuthResponse resp = AuthResponse.builder()
            .accessToken(newAccess)
            .refreshToken(newRefresh)
            .userUuid(user.getUserUuid())
            .expiresIn((jwtService.parseToken(newAccess).getBody().getExpiration().getTime()
                - System.currentTimeMillis()) / 1000L)
            .build();

        return ResponseEntity.ok(resp);
    }

    @Operation(
        summary = "로그아웃 (토큰/사용자 기준)",
        description = "refreshToken 이 바디에 있으면 해당 토큰만 삭제합니다. " +
            "refreshToken 이 없고 userUuid 가 주어지면 해당 사용자의 모든 refresh 토큰을 삭제합니다."
    )
    @PostMapping("/logout")
    public ResponseEntity<?> logout(
        @AuthenticationPrincipal CustomPrincipal principal,
        @RequestBody(required = false) Map<String, Object> body
    ) {
        if (principal == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("error", "unauthorized"));
        }
        String rawRefresh = body != null ? (String) body.get("refreshToken") : null;

        if (rawRefresh == null || rawRefresh.isBlank()) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "refreshToken_required_or_all=true"));
        }
        refreshTokenService.deleteByRawToken(rawRefresh, principal.userUuid());

        return ResponseEntity.ok(Map.of("msg", "logged_out"));
    }

    @Operation(
        summary = "유저 UUID로 JWT 발급(간단형)",
        description = "userUuid 하나만 받아 accessToken과 refreshToken을 발급합니다."
    )
    @PostMapping("/issue-by-uuid")
    public ResponseEntity<?> issueByUuid(@Valid @RequestBody DevUuidRequest req) {
        String userUuid = req.getUserUuid().trim();

        // 존재 사용자 확인
        User user = userRepository.findById(userUuid).orElse(null);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of("error", "user_not_found", "userUuid", userUuid));
        }

        // (선택) UUID 포맷 체크 — PK가 문자열이라도 포맷 점검하고 싶을 때
        try {
            java.util.UUID.fromString(userUuid);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "invalid_uuid_format", "userUuid", userUuid));
        }

        // 토큰 발급
        String access = jwtService.createAccessToken(user);
        String refresh = refreshTokenService.createAndSave(user.getUserUuid());

        long expiresInSec = (jwtService.parseToken(access).getBody().getExpiration().getTime()
            - System.currentTimeMillis()) / 1000L;

        AuthResponse resp = AuthResponse.builder()
            .accessToken(access)
            .refreshToken(refresh)
            .userUuid(user.getUserUuid())
            .expiresIn(expiresInSec)
            .build();

        return ResponseEntity.ok(resp);
    }
}
