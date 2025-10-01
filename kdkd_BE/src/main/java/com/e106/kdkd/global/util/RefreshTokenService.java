package com.e106.kdkd.global.util;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class RefreshTokenService {

    private final StringRedisTemplate redis;
    private final PasswordEncoder passwordEncoder;
    private final long refreshExpMs;
    private final SecureRandom secureRandom = new SecureRandom();

    public RefreshTokenService(StringRedisTemplate redis,
        PasswordEncoder passwordEncoder,
        @Value("${APP_JWT_REFRESH_EXP_MS:2592000000}") long refreshExpMs) {
        this.redis = redis;
        this.passwordEncoder = passwordEncoder;
        this.refreshExpMs = refreshExpMs;
    }

    // Create token and save metadata
    public String createAndSave(String userUuid) {
        String tokenId = UUID.randomUUID().toString();
        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        String secret = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        String rawToken = tokenId + "." + secret;
        String hash = passwordEncoder.encode(secret);

        String redisKey = redisKey(tokenId);
        Map<String, String> map = new HashMap<>();
        map.put("hash", hash);
        map.put("userUuid", userUuid);
        map.put("createdAt", String.valueOf(Instant.now().toEpochMilli()));
        map.put("lastUsedAt", String.valueOf(Instant.now().toEpochMilli()));

        redis.opsForHash().putAll(redisKey, map);
        redis.expire(redisKey, Duration.ofMillis(refreshExpMs));

        String userSet = userSetKey(userUuid);
        redis.opsForSet().add(userSet, tokenId);
        redis.expire(userSet, Duration.ofMillis(refreshExpMs));

        return rawToken;
    }

    // Verify raw token and return tokenId/userUuid if valid
    public Optional<RefreshTokenData> verifyAndGet(String rawToken) {
        if (rawToken == null || !rawToken.contains(".")) {
            return Optional.empty();
        }
        String[] parts = rawToken.split("\\.", 2);
        if (parts.length != 2) {
            return Optional.empty();
        }
        String tokenId = parts[0];
        String secret = parts[1];

        String redisKey = redisKey(tokenId);
        Map<Object, Object> entries = redis.opsForHash().entries(redisKey);
        if (entries == null || entries.isEmpty()) {
            return Optional.empty();
        }

        String storedHash = Objects.toString(entries.get("hash"), null);
        String userUuid = Objects.toString(entries.get("userUuid"), null);
        if (storedHash == null || userUuid == null) {
            return Optional.empty();
        }

        if (!passwordEncoder.matches(secret, storedHash)) {
            return Optional.empty();
        }

        try {
            redis.opsForHash()
                .put(redisKey, "lastUsedAt", String.valueOf(Instant.now().toEpochMilli()));
            redis.expire(redisKey, Duration.ofMillis(refreshExpMs));
            redis.expire(userSetKey(userUuid), Duration.ofMillis(refreshExpMs));
        } catch (Exception ignored) {
        }

        return Optional.of(new RefreshTokenData(tokenId, userUuid));
    }

    // Rotate token: delete old (only if ownership matches) and create new
    public String rotate(String oldRawToken, String userUuid) {
        if (oldRawToken != null && oldRawToken.contains(".")) {
            String oldId = oldRawToken.split("\\.", 2)[0];
            String oldKey = redisKey(oldId);
            try {
                String storedUser = (String) redis.opsForHash().get(oldKey, "userUuid");
                if (storedUser != null && storedUser.equals(userUuid)) {
                    redis.delete(oldKey);
                    redis.opsForSet().remove(userSetKey(userUuid), oldId);
                }
            } catch (Exception ignored) {
            }
        }
        return createAndSave(userUuid);
    }

    public void deleteByRawToken(String rawToken, String requesterUserUuid) {
        if (rawToken == null || requesterUserUuid == null || !rawToken.contains(".")) {
            return;
        }
        String tokenId = rawToken.split("\\.", 2)[0];
        String key = redisKey(tokenId);
        try {
            String storedUser = (String) redis.opsForHash().get(key, "userUuid");
            redis.delete(key);
            if (storedUser != null) {
                redis.opsForSet().remove(userSetKey(storedUser), tokenId);
            }
        } catch (Exception ignored) {
        }
    }

    public void deleteAllByUser(String userUuid) {
        String userSet = userSetKey(userUuid);
        Set<String> tokenIds = Optional.ofNullable(redis.opsForSet().members(userSet)).orElse(
            Collections.emptySet());
        if (tokenIds.isEmpty()) {
            redis.delete(userSet);
            return;
        }
        List<String> keys = tokenIds.stream().map(this::redisKey).collect(Collectors.toList());
        try {
            redis.delete(keys);
            redis.delete(userSet);
        } catch (Exception ignored) {
        }
    }

    private String redisKey(String tokenId) {
        return "refresh:" + tokenId;
    }

    private String userSetKey(String userUuid) {
        return "user_refresh:" + userUuid;
    }

    public static class RefreshTokenData {

        private final String tokenId;
        private final String userUuid;

        public RefreshTokenData(String tokenId, String userUuid) {
            this.tokenId = tokenId;
            this.userUuid = userUuid;
        }

        public String getTokenId() {
            return tokenId;
        }

        public String getUserUuid() {
            return userUuid;
        }
    }
}
