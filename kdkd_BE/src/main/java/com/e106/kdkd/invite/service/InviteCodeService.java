package com.e106.kdkd.invite.service;

import com.e106.kdkd.alert.service.AlertService;
import com.e106.kdkd.fcm.service.FcmService;
import com.e106.kdkd.global.common.entity.ParentRelation;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.exception.UserNotFoundException;
import com.e106.kdkd.invite.dto.ActivateInviteResponse;
import com.e106.kdkd.invite.dto.CreateInviteCodeResponse;
import com.e106.kdkd.invite.util.InviteCodeGenerator;
import com.e106.kdkd.parents.repository.ParentRelationRepository;
import com.e106.kdkd.users.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.firebase.messaging.FirebaseMessagingException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class InviteCodeService {

    private final StringRedisTemplate redis;
    private final InviteCodeGenerator generator;
    private final ObjectMapper objectMapper;

    private final ParentRelationRepository parentRelationRepository; // JPA
    private final UserRepository userRepository;                     // 존재 검증

    private final FcmService fcmService;
    private final AlertService alertService;

    @Value("${app.invite.redis-key-prefix:invite}")
    private String prefix;
    @Value("${app.invite.code-length:6}")
    private int defaultCodeLen;
    @Value("${app.invite.ttl-seconds:600}")
    private long defaultTtlSeconds;

    private String codeKey(String code) {
        return prefix + ":code:" + code;
    }

    private String parentKey(String parentUuid) {
        return prefix + ":parent:" + parentUuid;
    }


    //부모가 코드 발급/재발급: 기존 코드 있으면 삭제 후 새로 발급
    public CreateInviteCodeResponse createCode(String parentUuid, Long ttlSeconds) {
        if (parentUuid == null || parentUuid.isBlank()) {
            throw new IllegalArgumentException("parentUuid는 필수입니다.");
        }

        long ttl = (ttlSeconds == null || ttlSeconds <= 0) ? defaultTtlSeconds : ttlSeconds;
        Duration ttlDur = Duration.ofSeconds(ttl);

        // 1) 기존 코드가 있으면 모두 제거 (재발급 정책)
        String pKey = parentKey(parentUuid);
        String oldCode = redis.opsForValue().get(pKey);
        if (oldCode != null) {
            redis.delete(codeKey(oldCode));
            redis.delete(pKey);
        }

        // 2) 새 코드 생성 및 저장 (충돌 방지: NX + TTL)
        for (int i = 0; i < 5; i++) {
            String code = generator.generate(defaultCodeLen);
            String cKey = codeKey(code);

            String payload = toJson(Map.of(
                "parentUuid", parentUuid,
                "issuedAt", LocalDateTime.now().toString()
            ));

            Boolean ok = redis.opsForValue().setIfAbsent(cKey, payload, ttlDur); // SET NX EX
            if (Boolean.TRUE.equals(ok)) {
                // 부모→코드 매핑
                redis.opsForValue().set(pKey, code, ttlDur);
                return new CreateInviteCodeResponse(code, ttl);
            }
        }
        throw new IllegalStateException("코드 생성 충돌: 잠시 후 다시 시도해주세요.");
    }

    /**
     * 자녀가 코드로 연결(1회용, 원자적으로 소비)
     */
    // 검증(원샷)
    @Transactional
    public ActivateInviteResponse activate(String code, String childUuid) {
        if (code == null || code.isBlank()) {
            throw new IllegalArgumentException("code는 필수입니다.");
        }
        if (childUuid == null || childUuid.isBlank()) {
            throw new IllegalArgumentException("childUuid는 필수입니다.");
        }

        String norm = normalizeCode(code);
        String cKey = codeKey(norm);

        // Redis 6.2+ : 원샷
        String payload = redis.opsForValue().getAndDelete(cKey);

        // (디버그 도움)
        Long ttl = redis.getExpire(cKey);
        // log.info("activate key={}, ttl={}", cKey, ttl);

        if (payload == null) {
            throw new IllegalArgumentException("유효하지 않거나 만료/사용된 코드입니다.");
        }

        Map<String, Object> map = fromJson(payload);
        String parentUuid = (String) map.get("parentUuid");
        if (parentUuid == null || parentUuid.isBlank()) {
            throw new IllegalStateException("코드 데이터 손상");
        }
        if (parentUuid.equals(childUuid)) {
            throw new IllegalArgumentException("부모와 자녀가 동일할 수 없습니다.");
        }

        redis.delete(parentKey(parentUuid)); // 새 발급 허용

        requireExistsUser(parentUuid);
        requireExistsUser(childUuid);

        if (parentRelationRepository.existsByParent_UserUuidAndChild_UserUuid(parentUuid,
            childUuid)) {
            throw new IllegalStateException("이미 연결된 부모-자녀입니다.");
        }

        User parent = userRepository.findById(parentUuid)
            .orElseThrow(() -> new UserNotFoundException("해당 parentId는 존재하지 않는 User Id입니다."));
        User child = userRepository.findById(childUuid)
            .orElseThrow(() -> new UserNotFoundException("해당 childId는 존재하지 않는 User Id입니다."));

        ParentRelation relation = new ParentRelation(parent, child);
        parentRelationRepository.save(relation);

        log.debug("알림 기능 설정");
        String message = String.format("자녀 %s(이)가 등록되었습니다.", child.getName());
        try {
            fcmService.sendToUser(parentUuid, "자녀 등록",
                message);

        } catch (FirebaseMessagingException e) {
            log.warn("[FCM] 자녀 등록 알림 전송 실패: parentUuid={}, err={}", parentUuid, e.getMessage());
        }

        // 알림 DB에 저장
        alertService.createAlert(childUuid, parentUuid, message);

        return new ActivateInviteResponse(true, relation.getRelationUuid());
    }

    private void requireExistsUser(String userUuid) {
        if (!userRepository.existsByUserUuid(userUuid)) {
            throw new IllegalArgumentException("존재하지 않는 사용자: " + userUuid);
        }
    }

    private String toJson(Object o) {
        try {
            return objectMapper.writeValueAsString(o);
        } catch (Exception e) {
            throw new IllegalStateException("직렬화 실패", e);
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> fromJson(String json) {
        try {
            return objectMapper.readValue(json, Map.class);
        } catch (Exception e) {
            throw new IllegalStateException("역직렬화 실패", e);
        }
    }

    private String normalizeCode(String raw) {
        return raw.trim().toUpperCase();
    }
}
