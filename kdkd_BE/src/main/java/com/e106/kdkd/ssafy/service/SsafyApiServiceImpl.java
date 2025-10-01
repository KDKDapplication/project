package com.e106.kdkd.ssafy.service;

import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.common.enums.Role;
import com.e106.kdkd.ssafy.dto.SsafyMemberResponse;
import com.e106.kdkd.users.repository.UserRepository;
import jakarta.transaction.Transactional;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@RequiredArgsConstructor
public class SsafyApiServiceImpl implements SsafyApiService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final UserRepository userRepository;

    @Value("${SSAFY_API_BASE}")
    private String base;

    @Value("${SSAFY_ISSUE_PATH}")
    private String issuePath;

    @Value("${SSAFY_REISSUE_PATH}")
    private String reIssuePath;

    @Value("${SSAFY_MANAGER_ID}")
    private String managerId;

    @Value("${SSAFY_MEMBER_PATH}")
    private String memberPath;

    @Value("${SSAFY_MEMBER_SEARCH_PATH}")
    private String memberSearchPath;

    @Value("${SSAFY_API_KEY}")
    private String apiKey;

    @Override
    public Map<String, Object> issueApiKey() {
        String url = base + issuePath;

        Map<String, Object> request = new HashMap<>();
        request.put("managerId", managerId);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(java.util.List.of(MediaType.APPLICATION_JSON));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

        ResponseEntity<Map> response = restTemplate.exchange(
            url,
            HttpMethod.POST,
            entity,
            Map.class
        );

        return response.getBody();
    }

    @Override
    public Map<String, Object> reIssueApiKey() {
        String url = base + reIssuePath;

        Map<String, Object> request = new HashMap<>();
        request.put("managerId", managerId);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(java.util.List.of(MediaType.APPLICATION_JSON));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

        ResponseEntity<Map> response = restTemplate.exchange(
            url,
            HttpMethod.POST,
            entity,
            Map.class
        );

        return response.getBody();
    }

    @Override
    public Map<String, Object> enrollMember(String userEmail) {
        String url = base + memberPath;

        Map<String, Object> request = new HashMap<>();
        request.put("apiKey", apiKey);     // 서버에서 env 주입
        request.put("userId", userEmail);  // SSAFY 스펙에서 userId가 이메일

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(java.util.List.of(MediaType.APPLICATION_JSON));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

        ResponseEntity<Map> response = restTemplate.exchange(
            url,
            HttpMethod.POST,
            entity,
            Map.class
        );

        return response.getBody();
    }

    @Transactional
    @Override
    public Optional<SsafyMemberResponse> searchMember(String userEmail) {
        String url = base + memberSearchPath;

        Map<String, Object> request = new HashMap<>();
        request.put("apiKey", apiKey);
        request.put("userId", userEmail);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(java.util.List.of(MediaType.APPLICATION_JSON));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

        ResponseEntity<Map> response = restTemplate.exchange(
            url,
            HttpMethod.POST,
            entity,
            Map.class
        );

        Map<String, Object> body = response.getBody();
        if (body == null) {
            throw new IllegalStateException("회원 조회 실패: response body null");
        }

        String userKey = (String) body.get("userKey");
        String userName = (String) body.get("userName");
        String userId = (String) body.get("userId");

        // === DB 반영 ===
        userRepository.findByEmailAndDeletedAtIsNull(userId)
            .ifPresentOrElse(
                user -> {
                    user.setSsafyUserKey(userKey);
                    userRepository.save(user);
                },
                () -> {
                    User newUser = User.builder()
                        .userUuid(java.util.UUID.randomUUID().toString())
                        .email(userId)
                        .name(userName)
                        .ssafyUserKey(userKey)
                        .role(Role.CHILD) // 기본값
                        .build();
                    userRepository.save(newUser);
                }
            );

        return Optional.of(
            SsafyMemberResponse.builder()
                .userId(userId)
                .userName(userName)
                .userKey(userKey)
                .build()
        );
    }

    @Transactional
    @Override
    public Optional<SsafyMemberResponse> searchMemberOnboard(String userEmail) {
        String url = base + memberSearchPath;

        Map<String, Object> request = new HashMap<>();
        request.put("apiKey", apiKey);
        request.put("userId", userEmail);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(java.util.List.of(MediaType.APPLICATION_JSON));

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

        ResponseEntity<Map> response = restTemplate.exchange(
            url,
            HttpMethod.POST,
            entity,
            Map.class
        );

        Map<String, Object> body = response.getBody();
        if (body == null) {
            throw new IllegalStateException("회원 조회 실패: response body null");
        }
        String userKey = (String) body.get("userKey");
        String userName = (String) body.get("userName");
        String userId = (String) body.get("userId");

        return Optional.of(
            SsafyMemberResponse.builder()
                .userId(userId)
                .userName(userName)
                .userKey(userKey)
                .build()
        );
    }
}


