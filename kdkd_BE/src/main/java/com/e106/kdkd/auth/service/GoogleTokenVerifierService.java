package com.e106.kdkd.auth.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.jackson2.JacksonFactory;
import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Service;

/**
 * 안정적인 Google ID token 검증 서비스 (GoogleIdTokenVerifier 사용) - app.google.client-ids (CSV) 를 우선 읽고, 없으면
 * app.google.client-id 를 사용 - aud 필드가 string 또는 list 인 경우 모두 처리 - azp (authorized party) 검사 보조
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Primary
public class GoogleTokenVerifierService {

    // CSV로 여러 client ids를 허용 (우선), 없으면 singleClientIdFallback 사용
    @Value("${app.google.client-ids:}")
    private String googleClientIdsCsv;

    @Value("${app.google.client-id:}")
    private String singleClientIdFallback;

    private List<String> allowedAudiences = List.of(); // 불변 기본

    private GoogleIdTokenVerifier verifier;

    private final List<String> allowedClientIds;

    @PostConstruct
    public void init() {
        if (googleClientIdsCsv != null && !googleClientIdsCsv.isBlank()) {
            allowedAudiences = Arrays.stream(googleClientIdsCsv.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toList());
        } else if (singleClientIdFallback != null && !singleClientIdFallback.isBlank()) {
            allowedAudiences = List.of(singleClientIdFallback.trim());
        } else {
            log.warn(
                "No Google client id configured (app.google.client-ids or app.google.client-id). Verification will likely fail.");
        }

        try {
            verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(),
                JacksonFactory.getDefaultInstance())
                .setAudience(new ArrayList<>(allowedAudiences))
                .build();
            log.info("GoogleTokenVerifierService initialized. allowedAudiences={}",
                allowedAudiences);
        } catch (Exception ex) {
            log.error("Failed to create GoogleIdTokenVerifier: {}", ex.getMessage(), ex);
            verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(),
                JacksonFactory.getDefaultInstance())
                .setAudience(new ArrayList<>(allowedAudiences))
                .build();
        }
    }

    /**
     * Verify idToken and return payload. Throws IllegalArgumentException on failure with
     * descriptive message.
     */
    public GoogleIdToken.Payload verify(String idTokenString)
        throws GeneralSecurityException, IOException {
        if (idTokenString == null || idTokenString.isBlank()) {
            throw new IllegalArgumentException("idToken is required");
        }

        // Google client 라이브러리의 verify() 사용
        GoogleIdToken idToken = verifier.verify(idTokenString);
        if (idToken == null) {
            try {
                GoogleIdToken.Payload tmp = GoogleIdToken.parse(JacksonFactory.getDefaultInstance(),
                    idTokenString).getPayload();
                // build audiences list defensively
                List<String> tokenAudiences = extractAudiences(tmp);
                String azp = tmp.getAuthorizedParty(); // may be null
                log.warn(
                    "GoogleIdTokenVerifier returned null. token aud={}, azp={}, iss={}, email_verified={}",
                    tokenAudiences, azp, tmp.getIssuer(), tmp.getEmailVerified());
            } catch (Exception e) {
                log.warn(
                    "GoogleIdTokenVerifier returned null and failed to parse minimal payload: {}",
                    e.getMessage());
            }
            throw new IllegalArgumentException(
                "Token verification failed (verifier returned null)");
        }

        GoogleIdToken.Payload payload = idToken.getPayload();

        // issuer 검증
        String issuer = payload.getIssuer();
        if (!"accounts.google.com".equals(issuer) && !"https://accounts.google.com".equals(
            issuer)) {
            throw new IllegalArgumentException("Invalid token issuer: " + issuer);
        }

        // audience 검증 (aud may be String or List)
        List<String> tokenAudiences = extractAudiences(payload);
        boolean audMatch = tokenAudiences.stream().anyMatch(allowedAudiences::contains);

        // azp(authorized party)도 확인 (특정 상황에서 aud 대신 azp 체크 필요)
        String azp = payload.getAuthorizedParty();
        if (!audMatch && azp != null && !azp.isBlank()) {
            audMatch = allowedAudiences.contains(azp);
        }

        if (!audMatch) {
            throw new IllegalArgumentException(
                "Token audience mismatch. token aud=" + tokenAudiences + ", allowed="
                    + allowedAudiences);
        }

        // 이메일 검증(정책에 따라 필수)
        Boolean emailVerified = payload.getEmailVerified();
        if (emailVerified == null || !emailVerified) {
            throw new IllegalArgumentException("Email not verified by Google");
        }

        return payload;
    }

    // 안전하게 aud를 추출해서 문자열 목록으로 반환
    @SuppressWarnings("unchecked")
    private static List<String> extractAudiences(GoogleIdToken.Payload payload) {
        List<String> result = new ArrayList<>();
        try {
            Object audObj = payload.getAudience();
            if (audObj == null) {
                // sometimes aud claim accessible via get("aud")
                Object audRaw = payload.get("aud");
                if (audRaw != null) {
                    audObj = audRaw;
                }
            }
            if (audObj instanceof List) {
                for (Object o : (List<?>) audObj) {
                    if (o != null) {
                        result.add(String.valueOf(o));
                    }
                }
            } else if (audObj != null) {
                // single string
                result.add(String.valueOf(audObj));
            }
            // also include azp if present (authorized party)
            Object azp = payload.get("azp");
            if (azp != null) {
                result.add(String.valueOf(azp));
            }
        } catch (Exception ex) {
            // defensive: if anything fails, fallback to empty list
        }
        return result;
    }
}