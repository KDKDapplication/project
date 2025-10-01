package com.e106.kdkd.ssafy.service;

import com.e106.kdkd.ssafy.dto.CardIssuerCodeItem;
import com.e106.kdkd.ssafy.dto.RequestEnvelope;
import com.e106.kdkd.ssafy.dto.RequestHeader;
import com.e106.kdkd.ssafy.dto.ResponseEnvelope;
import com.e106.kdkd.ssafy.dto.card.*;
import com.e106.kdkd.ssafy.jpa.SsafyUserRepository;
import com.e106.kdkd.ssafy.util.BankApiException;
import com.e106.kdkd.ssafy.util.HeaderFactory;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Slf4j
@Service
@RequiredArgsConstructor
public class CreditCardServiceImpl implements CreditCardService {

    private final WebClient webClient;
    private final ObjectMapper objectMapper;
    private final SsafyUserRepository ssafyUserRepository; // 🔸 userUuid → ssafy_user_key 조회

    @Value("${SSAFY_API_BASE}")
    private String baseUrl;

    @Value("${SSAFY_API_KEY}")
    private String apiKey;

    @Value("${SSAFY_API_PATH_CARD_ISSUER_CODES}")
    private String pathCardIssuerCodes;

    @Value("${SSAFY_CREDIT_CARD_CREATE_PRODUCT_PATH}")
    private String createProductPath;

    @Value("${SSAFY_CREDIT_CARD_LIST_PATH}")
    private String cardListPath;

    @Value("${SSAFY_CREDIT_CARD_CREATE_PATH}")
    private String createCardPath;

    @Value("${SSAFY_CREDIT_CARD_SIGNUP_LIST_PATH}")
    private String signUpListPath;

    @Value("${SSAFY_CREDIT_CARD_TRANSACTION_LIST}")
    private String transactionListPath;

    private String getSsafyUserKeyOrThrow(String userUuid) {
        return ssafyUserRepository.findSsafyUserKeyByUserUuid(userUuid)
            .orElseThrow(() -> new IllegalArgumentException("ssafy_user_key not found for userUuid=" + userUuid));
    }

    @Override
    public ResponseEnvelope<InquireCreditCardTransactionListRec> inquireCreditCardTransactionList(
            InquireCreditCardTransactionListRequest request, String userUuid) {

        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("inquireCreditCardTransactionList", apiKey, ssafyUserKey);

        ObjectNode root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        ObjectNode body = objectMapper.convertValue(request, ObjectNode.class);
        root.setAll(body);

        try {
            String reqJson = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root);
            log.info("[CreditCardAPI][inquireCreditCardTransactionList] request JSON = \n{}", reqJson);

            String raw = webClient.post()
                    .uri(baseUrl + transactionListPath)
                    .contentType(MediaType.APPLICATION_JSON)
                    .accept(MediaType.APPLICATION_JSON)
                    .bodyValue(root)
                    .retrieve()
                    .onStatus(status -> status.isError(), clientResponse ->
                            clientResponse.bodyToMono(String.class).flatMap(errorBody -> {
                                log.error("[CreditCardAPI][inquireCreditCardTransactionList] error body = \n{}", errorBody);
                                try {
                                    ResponseEnvelope<?> errorResp = objectMapper.readValue(
                                            errorBody,
                                            objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class)
                                    );
                                    return Mono.error(new BankApiException(errorResp));
                                } catch (Exception parseEx) {
                                    return Mono.error(new RuntimeException("CreditCard API error, raw=" + errorBody, parseEx));
                                }
                            })
                    )
                    .bodyToMono(String.class)
                    .block();

            log.info("[CreditCardAPI][inquireCreditCardTransactionList] raw response = \n{}", raw);

            return objectMapper.readValue(
                    raw,
                    objectMapper.getTypeFactory().constructParametricType(
                            ResponseEnvelope.class, InquireCreditCardTransactionListRec.class
                    )
            );

        } catch (Exception e) {
            log.error("[CreditCardAPI][inquireCreditCardTransactionList] error", e);
            throw new RuntimeException("CreditCard API call failed", e);
        }
    }

    @Override
    public ResponseEnvelope<List<CardIssuerCodeItem>> inquireCardIssuerCodesList() {
        final String apiName = "inquireCardIssuerCodesList";
        RequestHeader header = HeaderFactory.of(apiName, apiKey);
        RequestEnvelope<Void> payload = new RequestEnvelope<>(header, null);

        return webClient.post()
            .uri(baseUrl + pathCardIssuerCodes)
            .bodyValue(payload)
            .retrieve()
            .bodyToMono(new ParameterizedTypeReference<ResponseEnvelope<List<CardIssuerCodeItem>>>() {})
            .block();
    }

    @Override
    public ResponseEnvelope<List<CreateCreditCardProductRec>> inquireCreditCardList() {
        RequestHeader header = HeaderFactory.of("inquireCreditCardList", apiKey);
        ObjectNode root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));

        try {
            String reqJson = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root);
            log.info("[CreditCardAPI][inquireCreditCardList] request JSON = \n{}", reqJson);

            String raw = webClient.post()
                .uri(baseUrl + cardListPath)
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
                .bodyValue(root)
                .retrieve()
                .onStatus(status -> status.isError(), clientResponse ->
                    clientResponse.bodyToMono(String.class).flatMap(errorBody -> {
                        log.error("[CreditCardAPI][inquireCreditCardList] error body = \n{}", errorBody);
                        try {
                            ResponseEnvelope<?> errorResp = objectMapper.readValue(
                                errorBody,
                                objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class)
                            );
                            return Mono.error(new BankApiException(errorResp));
                        } catch (Exception parseEx) {
                            return Mono.error(new RuntimeException("CreditCard API error, raw=" + errorBody, parseEx));
                        }
                    })
                )
                .bodyToMono(String.class)
                .block();

            log.info("[CreditCardAPI][inquireCreditCardList] raw response = \n{}", raw);

            return objectMapper.readValue(
                raw,
                objectMapper.getTypeFactory().constructParametricType(
                    ResponseEnvelope.class,
                    objectMapper.getTypeFactory().constructCollectionType(List.class, CreateCreditCardProductRec.class)
                )
            );
        } catch (Exception e) {
            log.error("[CreditCardAPI][inquireCreditCardList] error", e);
            throw new RuntimeException("CreditCard API call failed", e);
        }
    }

    @Override
    public ResponseEnvelope<CreateCreditCardProductRec> createCreditCardProduct(CreateCreditCardProductRequest request) {
        RequestHeader header = HeaderFactory.of("createCreditCardProduct", apiKey);
        ObjectNode body = objectMapper.valueToTree(request);

        ObjectNode root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.setAll(body);

        try {
            String reqJson = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root);
            log.info("[CreditCardAPI][createCreditCardProduct] request JSON = \n{}", reqJson);

            String raw = webClient.post()
                .uri(baseUrl + createProductPath)
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
                .bodyValue(root)
                .retrieve()
                .onStatus(status -> status.isError(), clientResponse ->
                    clientResponse.bodyToMono(String.class).flatMap(errorBody -> {
                        log.error("[CreditCardAPI][createCreditCardProduct] error body = \n{}", errorBody);
                        try {
                            ResponseEnvelope<?> errorResp = objectMapper.readValue(
                                errorBody,
                                objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class)
                            );
                            return Mono.error(new BankApiException(errorResp));
                        } catch (Exception parseEx) {
                            return Mono.error(new RuntimeException("CreditCard API error, raw=" + errorBody, parseEx));
                        }
                    })
                )
                .bodyToMono(String.class)
                .block();

            log.info("[CreditCardAPI][createCreditCardProduct] raw response = \n{}", raw);

            ResponseEnvelope<CreateCreditCardProductRec> resp = objectMapper.readValue(
                raw,
                objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, CreateCreditCardProductRec.class)
            );
            log.info("[CreditCardAPI][createCreditCardProduct] parsed response = {}", resp);
            return resp;

        } catch (Exception e) {
            log.error("[CreditCardAPI][createCreditCardProduct] error", e);
            throw new RuntimeException("CreditCard API call failed", e);
        }
    }

    // =============== userKey 필요한 API (userUuid로 대체) ===============

    @Override
    public ResponseEnvelope<CreateCreditCardRec> createCreditCard(CreateCreditCardRequest request, String userUuid) {
        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("createCreditCard", apiKey, ssafyUserKey);

        ObjectNode root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        ObjectNode body = objectMapper.convertValue(request, ObjectNode.class);
        root.setAll(body);

        try {
            String reqJson = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root);
            log.info("[CreditCardAPI][createCreditCard] request JSON = \n{}", reqJson);

            String raw = webClient.post()
                .uri(baseUrl + createCardPath)
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
                .bodyValue(root)
                .retrieve()
                .onStatus(status -> status.isError(), clientResponse ->
                    clientResponse.bodyToMono(String.class).flatMap(errorBody -> {
                        log.error("[CreditCardAPI][createCreditCard] error body = \n{}", errorBody);
                        try {
                            ResponseEnvelope<?> errorResp = objectMapper.readValue(
                                errorBody,
                                objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class)
                            );
                            return Mono.error(new BankApiException(errorResp));
                        } catch (Exception parseEx) {
                            return Mono.error(new RuntimeException("CreditCard API error, raw=" + errorBody, parseEx));
                        }
                    })
                )
                .bodyToMono(String.class)
                .block();

            log.info("[CreditCardAPI][createCreditCard] raw response = \n{}", raw);

            return objectMapper.readValue(
                raw,
                objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, CreateCreditCardRec.class)
            );

        } catch (Exception e) {
            log.error("[CreditCardAPI][createCreditCard] error", e);
            throw new RuntimeException("CreditCard API call failed", e);
        }
    }

    @Override
    public ResponseEnvelope<List<SignUpCreditCardRec>> inquireSignUpCreditCardList(String userUuid) {
        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("inquireSignUpCreditCardList", apiKey, ssafyUserKey);

        ObjectNode root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));

        try {
            String reqJson = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root);
            log.info("[CreditCardAPI][inquireSignUpCreditCardList] request JSON = \n{}", reqJson);

            String raw = webClient.post()
                .uri(baseUrl + signUpListPath)
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
                .bodyValue(root)
                .retrieve()
                .onStatus(status -> status.isError(), clientResponse ->
                    clientResponse.bodyToMono(String.class).flatMap(errorBody -> {
                        log.error("[CreditCardAPI][inquireSignUpCreditCardList] error body = \n{}", errorBody);
                        try {
                            ResponseEnvelope<?> errorResp = objectMapper.readValue(
                                errorBody,
                                objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class)
                            );
                            return Mono.error(new BankApiException(errorResp));
                        } catch (Exception parseEx) {
                            return Mono.error(new RuntimeException("CreditCard API error, raw=" + errorBody, parseEx));
                        }
                    })
                )
                .bodyToMono(String.class)
                .block();

            log.info("[CreditCardAPI][inquireSignUpCreditCardList] raw response = \n{}", raw);

            return objectMapper.readValue(
                raw,
                objectMapper.getTypeFactory().constructParametricType(
                    ResponseEnvelope.class,
                    objectMapper.getTypeFactory().constructCollectionType(List.class, SignUpCreditCardRec.class)
                )
            );

        } catch (Exception e) {
            log.error("[CreditCardAPI][inquireSignUpCreditCardList] error", e);
            throw new RuntimeException("CreditCard API call failed", e);
        }
    }
}
