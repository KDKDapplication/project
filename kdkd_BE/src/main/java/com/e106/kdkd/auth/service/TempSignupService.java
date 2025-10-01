package com.e106.kdkd.auth.service;

import com.e106.kdkd.auth.dto.internal.TempSignupData;
import java.security.SecureRandom;
import java.time.Duration;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * 임시 회원가입(signup) 토큰 서비스
 * <p>
 * 사용 흐름: - createAndSave(googleSub, email, name) -> raw signup token (tokenId.secret) 반환 -
 * verifyAndGet(rawToken) -> Redis에 저장된 데이터 읽기(검증만, 키는 삭제하지 않음) - verifyAndConsume(rawToken) -> 검증 후
 * Redis 키 삭제(consume)
 * <p>
 * 저장 포맷: Redis Hash key = signup:{tokenId} fields: hash (bcrypt of secret), googleSub, email, name,
 * createdAt
 * <p>
 * TTL: APP_SIGNUP_TTL_MS (기본 15분)
 * <p>
 * 보안: - raw token(토큰 원문)은 클라이언트에게만 전달하고 서버에는 secret의 bcrypt 해시만 저장합니다. - 토큰 원문/secret은 로그에 남기지
 * 마세요.
 */
@Service
public class TempSignupService {

    private final StringRedisTemplate redis;
    private final PasswordEncoder passwordEncoder;

    private final long signupTtlMs;
    private final SecureRandom secureRandom = new SecureRandom();


    @Autowired
    public TempSignupService(
        StringRedisTemplate redis,
        PasswordEncoder passwordEncoder,
        @Value("${auth.signup.ttl-ms:300000}") long signupTtlMs) {
        this.redis = redis;
        this.passwordEncoder = passwordEncoder;
        this.signupTtlMs = signupTtlMs;
    }

    public String createAndSave(String googleSub, String email) {
        String tokenId = UUID.randomUUID().toString();

        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        String secret = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);

        String rawToken = tokenId + "." + secret;
        String hash = passwordEncoder.encode(secret);

        String key = redisKey(tokenId);
        Map<String, String> map = new HashMap<>();
        map.put("hash", hash);
        map.put("googleSub", safe(googleSub));
        map.put("email", safe(email));

        redis.opsForHash().putAll(key, map);
        redis.expire(key, Duration.ofMillis(signupTtlMs));

        return rawToken;
    }

    public Optional<TempSignupData> verifyAndGet(String rawToken) {
        if (rawToken == null || !rawToken.contains(".")) {
            return Optional.empty();
        }
        String[] parts = rawToken.split("\\.", 2);
        if (parts.length != 2) {
            return Optional.empty();
        }
        String tokenId = parts[0];
        String secret = parts[1];

        String key = redisKey(tokenId);
        Map<Object, Object> entries = redis.opsForHash().entries(key);
        if (entries == null || entries.isEmpty()) {
            return Optional.empty();
        }

        String storedHash = asString(entries.get("hash"));
        if (storedHash == null) {
            return Optional.empty();
        }

        if (!passwordEncoder.matches(secret, storedHash)) {
            return Optional.empty();
        }

        String googleSub = asString(entries.get("googleSub"));
        String email = asString(entries.get("email"));

        return Optional.of(new TempSignupData(tokenId, googleSub, email));
    }

    public Optional<TempSignupData> verifyAndConsume(String rawToken) {
        Optional<TempSignupData> opt = verifyAndGet(rawToken);
        if (opt.isPresent()) {
            try {
                redis.delete(redisKey(opt.get().getTokenId()));
            } catch (Exception ignored) {
                // best-effort delete; if delete fails the key will expire by TTL
            }
        }
        return opt;
    }

    private String redisKey(String tokenId) {
        return "signup:" + tokenId;
    }

    private String safe(String s) {
        return s == null ? "" : s.replaceAll("[\\r\\n]", "_");
    }

    private String asString(Object o) {
        return o == null ? null : String.valueOf(o);
    }
}
