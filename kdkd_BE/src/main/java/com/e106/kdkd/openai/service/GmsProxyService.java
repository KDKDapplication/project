package com.e106.kdkd.openai.service;

import com.e106.kdkd.account.repository.AccountRepository;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.exception.ResourceNotFoundException;
import com.e106.kdkd.global.exception.UserNotFoundException;
import com.e106.kdkd.parents.dto.response.ChildPattern;
import com.e106.kdkd.parents.util.PatternAnalysisService;
import com.e106.kdkd.users.repository.UserRepository;
import com.fasterxml.jackson.databind.JsonNode;
import java.time.LocalDate;
import java.time.Period;
import java.time.YearMonth;
import java.util.Map;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

@Service
@RequiredArgsConstructor
@Slf4j
public class GmsProxyService {

    private final PatternAnalysisService patternAnalysisService;
    private final AccountRepository accountRepository;
    private final WebClient webClient;
    private final UserRepository userRepository;

    @Value("${gms.key:${GMS_KEY:}}")
    private String gmsKeyDefault;

    @Value("${ai.default-model:gpt-5}")
    private String defaultModel;

    private static final String BASE = "https://gms.ssafy.io/gmsapi/api.openai.com/v1";

    /**
     * 질문만 받아 기본 모델(gpt-5)로 호출
     */
    public String ask(String question) {
        return callModel(defaultModel, question, null);
    }

    /**
     * 모델 호출 후 오직 text만 반환
     */
    public String callModel(String model, String input, String gmsKeyOverride) {
        String effectiveModel = (model == null || model.isBlank()) ? defaultModel : model;
        String key =
            (gmsKeyOverride != null && !gmsKeyOverride.isBlank()) ? gmsKeyOverride : gmsKeyDefault;

        if (key == null || key.isBlank()) {
            throw new IllegalStateException("GMS key not configured.");
        }

        Map<String, Object> body = Map.of("model", effectiveModel, "input", input);
        boolean isGemini = effectiveModel.toLowerCase().startsWith("gemini");
        String url = isGemini ? (BASE + "/responses?key=" + key) : (BASE + "/responses");

        WebClient.RequestBodySpec req = webClient.post().uri(url)
            .header("Content-Type", "application/json");
        if (!isGemini) {
            req = req.header("Authorization", "Bearer " + key);
        }

        JsonNode res = req.bodyValue(body).retrieve()
            .bodyToMono(JsonNode.class)
            .block();

        // === ★ 핵심: text만 깔끔히 추출 ===
        String onlyText = extractText(res);
        return onlyText != null ? onlyText : "";
    }

    /**
     * GMS /responses 스펙에서 text만 뽑기 (견고하게)
     */
    private String extractText(JsonNode res) {
        if (res == null) {
            return null;
        }

        // 1) /v1/responses 표준: output[] 안에서 type=message → content[].type=output_text 의 text
        JsonNode output = res.path("output");
        if (output.isArray()) {
            StringBuilder sb = new StringBuilder();
            for (JsonNode node : output) {
                if ("message".equals(node.path("type").asText())) {
                    JsonNode content = node.path("content");
                    if (content.isArray()) {
                        for (JsonNode c : content) {
                            // 주로 output_text, 혹은 text 필드가 직접 있을 수 있음
                            if ("output_text".equals(c.path("type").asText()) && c.has("text")) {
                                sb.append(c.path("text").asText());
                            } else if (c.has("text")) {
                                sb.append(c.path("text").asText());
                            }
                        }
                    }
                }
            }
            if (sb.length() > 0) {
                return sb.toString();
            }
        }

        // 2) (Fallback) 예전 chat/completions 스타일
        JsonNode choices = res.path("choices");
        if (choices.isArray() && choices.size() > 0) {
            String text = choices.get(0).path("message").path("content").asText(null);
            if (text != null && !text.isBlank()) {
                return text;
            }
        }

        // 3) (Fallback) 혹시 top-level의 간단 text가 있을 때
        if (res.has("text")) {
            String t = res.path("text").asText(null);
            if (t != null && !t.isBlank()) {
                return t;
            }
        }

        // 못 찾으면 null
        return null;
    }

    public String getAiFeedback(String childUuid, YearMonth yearMonth, String gmsKeyOverride) {
        String model = "gpt-4.1";

        String effectiveModel = (model == null || model.isBlank()) ? defaultModel : model;
        String key =
            (gmsKeyOverride != null && !gmsKeyOverride.isBlank()) ? gmsKeyOverride : gmsKeyDefault;

        if (key == null || key.isBlank()) {
            throw new IllegalStateException("GMS key not configured.");
        }

        String input = makeInputText(childUuid, yearMonth);
        if (input == null) {
            return "전월 소비 내역이 없습니다.";
        }

        Map<String, Object> body = Map.of("model", effectiveModel, "input", input);
        boolean isGemini = effectiveModel.toLowerCase().startsWith("gemini");
        String url = isGemini ? (BASE + "/responses?key=" + key) : (BASE + "/responses");

        WebClient.RequestBodySpec req = webClient.post().uri(url)
            .header("Content-Type", "application/json");
        if (!isGemini) {
            req = req.header("Authorization", "Bearer " + key);
        }

        JsonNode res = req.bodyValue(body).retrieve()
            .bodyToMono(JsonNode.class)
            .block();

        // === ★ 핵심: text만 깔끔히 추출 ===
        String onlyText = extractText(res);
        return onlyText != null ? onlyText : "";
    }

    private String makeInputText(String userUuid, YearMonth yearMonth) {
        String text = null;

        log.debug("사용자 조회");
        User user = userRepository.findById(userUuid).orElseThrow(
            () -> new UserNotFoundException("존재하지 않는 사용자입니다."));

        log.debug("만 나이 계산");
        int age = internationalAge(user.getBirthdate(), LocalDate.now());

        log.debug("계좌 조회");
        Account account = accountRepository.findByUser_UserUuid(userUuid);
        if (account == null) {
            throw new ResourceNotFoundException("해당 user의 계좌가 존재하지 않습니다.");
        }

        ChildPattern pattern = patternAnalysisService.classifyCategory(account.getAccountSeq(),
            yearMonth);
        if (pattern.getTotalAmount().equals(0L)) {
            return text;
        }

        text = "아래는 아동 청소년 사용자의 만 나이와 카테고리 별 소비 금액이다."
            + "60자 이상 100자 이하로 소비 패턴 분석 한 줄 요약과 "
            + "60자 이상 100자 이하로 소비 개선 한줄 요약을 하나의 문단으로 만들어줘"
            + "만 나이 : " + age + ",\n"
            + "전월 총 일 수 :" + pattern.getTotalDays() + ",\n"
            + "전월 총 소비 금액 : " + pattern.getTotalAmount() + ",\n"
            + "전월 기타 소비 금액 : " + pattern.getEtcAmount() + ",\n"
            + "전월 교통 소비 금액 : " + pattern.getTransportationAmount() + ",\n"
            + "전월 문구/서점 소비금액 : " + pattern.getStationaryStoreAmount() + ",\n"
            + "전월 편의점 소비금액 : " + pattern.getConvenienceStoreAmount() + ",\n"
            + "전월 음식점 소비금액 : " + pattern.getRestaurantAmount() + ",\n"
            + "전월 문화 소비금액 : " + pattern.getCultureAmount() + ",\n"
            + "전월 카페 소비금액 : " + pattern.getCafeAmount() + ",\n"
            + "예시는 다음과 같다. \"자녀의 소비패턴은 문화와 음식점 소비 비중이 높고 교통·편의점 비중이 낮은 편입니다."
            + "외식 비중을 줄이고 집밥을 늘리면 건강도 챙기고 지출 금액도 절약할 수 있습니다.\"";
        return text;

    }

    public static int internationalAge(LocalDate birthDate, LocalDate today) {
        Objects.requireNonNull(birthDate, "birthDate");
        Objects.requireNonNull(today, "today");

        if (birthDate.isAfter(today)) {
            throw new IllegalArgumentException("생년월일이 오늘 날짜보다 미래입니다.");
        }
        // Period는 윤년(2/29) 생일도 올바르게 처리합니다.
        return Period.between(birthDate, today).getYears();
    }
}