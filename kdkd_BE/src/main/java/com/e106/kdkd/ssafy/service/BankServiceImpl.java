package com.e106.kdkd.ssafy.service;

import com.e106.kdkd.ssafy.dto.*;
import com.e106.kdkd.ssafy.dto.accountauth.CheckAuthCodeRec;
import com.e106.kdkd.ssafy.dto.accountauth.OpenAccountAuthRec;
import com.e106.kdkd.ssafy.jpa.SsafyUserRepository;
import com.e106.kdkd.ssafy.util.BankApiException;
import com.e106.kdkd.ssafy.util.HeaderFactory;
import com.fasterxml.jackson.core.type.TypeReference;
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
public class BankServiceImpl implements BankService {

    private final WebClient bankWebClient;
    private final ObjectMapper objectMapper;
    private final SsafyUserRepository ssafyUserRepository;

    @Value("${SSAFY_API_BASE}")
    private String baseUrl;

    @Value("${BANK_API_CREATE_DEMAND_DEPOSIT_PATH}")
    private String createPath;

    @Value("${SSAFY_API_KEY}")
    private String apiKey;

    @Value("${SSAFY_DEMAND_DEPOSIT_CREATE_PATH}")
    private String createDepositPath;

    @Value("${SSAFY_DEMAND_DEPOSIT_LIST_PATH}")
    private String listPath;

    @Value("${SSAFY_DEMAND_DEPOSIT_ACCOUNT_LIST_PATH}")
    private String accountListPath;

    @Value("${SSAFY_DEMAND_DEPOSIT_ACCOUNT_HOLDER_PATH}")
    private String accountHolderPath;

    @Value("${SSAFY_DEMAND_DEPOSIT_ACCOUNT_BALANCE_PATH}")
    private String accountBalancePath;

    @Value("${SSAFY_DEMAND_DEPOSIT_ACCOUNT_DEPOSIT_PATH}")
    private String accountDepositPath;

    @Value("${SSAFY_DEMAND_DEPOSIT_ACCOUNT_WITHDRAWAL_PATH}")
    private String accountWithdrawalPath;

    @Value("${SSAFY_DEMAND_DEPOSIT_ACCOUNT_TRANSFER_PATH}")
    private String accountTransferPath;

    @Value("${SSAFY_DEMAND_DEPOSIT_TX_LIST_PATH}")
    private String txListPath;

    @Value("${SSAFY_DEMAND_DEPOSIT_TX_SINGLE_PATH}")
    private String txSinglePath;

    @Value("${SSAFY_DEMAND_DEPOSIT_ACCOUNT_DELETE_PATH}")
    private String accountDeletePath;

    @Value("${SSAFY_ACCOUNT_AUTH_OPEN_PATH}")
    private String accountAuthOpenPath;

    @Value("${SSAFY_ACCOUNT_AUTH_CHECK_PATH}")
    private String accountAuthCheckPath;

    private String getSsafyUserKeyOrThrow(String userUuid) {
        return ssafyUserRepository.findSsafyUserKeyByUserUuid(userUuid)
            .orElseThrow(() -> new IllegalArgumentException("ssafy_user_key not found for userUuid=" + userUuid));
    }

    @Override
    public ResponseEnvelope<OpenAccountAuthRec> openAccountAuth(String accountNo, String userUuid) {
        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("openAccountAuth", apiKey, ssafyUserKey);
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.put("accountNo", accountNo);
        root.put("authText", "SSAFY");
        try {
            log.info("[BankAPI][openAccountAuth] request JSON = \n{}", objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            ResponseEnvelope<OpenAccountAuthRec> resp = bankWebClient.post()
                .uri(baseUrl + accountAuthOpenPath)
                .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                .bodyValue(root).retrieve()
                .onStatus(s -> s.isError(), r -> r.bodyToMono(String.class).flatMap(errorBody -> {
                    log.error("[BankAPI][openAccountAuth] error body = \n{}", errorBody);
                    try {
                        ResponseEnvelope<?> errorResp = objectMapper.readValue(errorBody, new TypeReference<ResponseEnvelope<?>>() {});
                        return Mono.error(new BankApiException(errorResp));
                    } catch (Exception parseEx) {
                        return Mono.error(new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                    }
                }))
                .bodyToMono(new ParameterizedTypeReference<ResponseEnvelope<OpenAccountAuthRec>>() {})
                .block();
            log.info("[BankAPI][openAccountAuth] parsed response = {}", resp);
            return resp;
        } catch (Exception e) {
            log.error("[BankAPI][openAccountAuth] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    @Override
    public String checkAuthCode(String accountNo, String authCode, String userUuid) {
        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("checkAuthCode", apiKey, ssafyUserKey);
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.put("accountNo", accountNo);
        root.put("authText", "SSAFY");
        root.put("authCode", authCode);
        try {
            log.info("[BankAPI][checkAuthCode] request JSON = \n{}", objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            ResponseEnvelope<CheckAuthCodeRec> resp = bankWebClient.post()
                .uri(baseUrl + accountAuthCheckPath)
                .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                .bodyValue(root).retrieve()
                .onStatus(s -> s.isError(), r -> r.bodyToMono(String.class).flatMap(errorBody -> {
                    log.error("[BankAPI][checkAuthCode] error body = \n{}", errorBody);
                    try {
                        ResponseEnvelope<?> errorResp = objectMapper.readValue(errorBody, new TypeReference<ResponseEnvelope<?>>() {});
                        return Mono.error(new BankApiException(errorResp));
                    } catch (Exception parseEx) {
                        return Mono.error(new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                    }
                }))
                .bodyToMono(new ParameterizedTypeReference<ResponseEnvelope<CheckAuthCodeRec>>() {})
                .block();
            log.info("[BankAPI][checkAuthCode] parsed response = {}", resp);
            if (resp == null || resp.getREC() == null) throw new RuntimeException("Empty response from checkAuthCode");
            return resp.getREC().getStatus();
        } catch (Exception e) {
            log.error("[BankAPI][checkAuthCode] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    @Override
    public ResponseEnvelope<DemandDepositAccountBalance> inquireDemandDepositAccountBalance(String accountNo, String userUuid) {
        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("inquireDemandDepositAccountBalance", apiKey, ssafyUserKey);
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.put("accountNo", accountNo);
        try {
            log.info("[BankAPI][inquireDemandDepositAccountBalance] request JSON = \n{}", objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            ResponseEnvelope<DemandDepositAccountBalance> resp = bankWebClient.post()
                .uri(baseUrl + accountBalancePath)
                .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                .bodyValue(root).retrieve()
                .onStatus(s -> s.isError(), r -> r.bodyToMono(String.class).flatMap(errorBody -> {
                    log.error("[BankAPI][inquireDemandDepositAccountBalance] error body = \n{}", errorBody);
                    try {
                        ResponseEnvelope<?> errorResp = objectMapper.readValue(errorBody,
                            objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class));
                        return Mono.error(new BankApiException(errorResp));
                    } catch (Exception parseEx) {
                        return Mono.error(new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                    }
                }))
                .bodyToMono(new ParameterizedTypeReference<ResponseEnvelope<DemandDepositAccountBalance>>() {})
                .block();
            log.info("[BankAPI][inquireDemandDepositAccountBalance] parsed response = {}", resp);
            return resp;
        } catch (Exception e) {
            log.error("[BankAPI][inquireDemandDepositAccountBalance] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    @Override
    public ResponseEnvelope<DemandDepositAccountHolder> inquireDemandDepositAccountHolderName(String accountNo, String userUuid) {
        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("inquireDemandDepositAccountHolderName", apiKey, ssafyUserKey);
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.put("accountNo", accountNo);
        try {
            log.info("[BankAPI][inquireDemandDepositAccountHolderName] request JSON = \n{}", objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            ResponseEnvelope<DemandDepositAccountHolder> resp = bankWebClient.post()
                .uri(baseUrl + accountHolderPath)
                .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                .bodyValue(root).retrieve()
                .onStatus(s -> s.isError(), r -> r.bodyToMono(String.class).flatMap(errorBody -> {
                    log.error("[BankAPI][inquireDemandDepositAccountHolderName] error body = \n{}", errorBody);
                    try {
                        ResponseEnvelope<?> errorResp = objectMapper.readValue(errorBody,
                            objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class));
                        return Mono.error(new BankApiException(errorResp));
                    } catch (Exception parseEx) {
                        return Mono.error(new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                    }
                }))
                .bodyToMono(new ParameterizedTypeReference<ResponseEnvelope<DemandDepositAccountHolder>>() {})
                .block();
            log.info("[BankAPI][inquireDemandDepositAccountHolderName] parsed response = {}", resp);
            return resp;
        } catch (Exception e) {
            log.error("[BankAPI][inquireDemandDepositAccountHolderName] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    @Override
    public ResponseEnvelope<List<DemandDepositAccountItem>> inquireDemandDepositAccountList(String userUuid) {
        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("inquireDemandDepositAccountList", apiKey, ssafyUserKey);
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        try {
            log.info("[BankAPI][inquireDemandDepositAccountList] request JSON = \n{}", objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            ResponseEnvelope<List<DemandDepositAccountItem>> resp = bankWebClient.post()
                .uri(baseUrl + accountListPath)
                .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                .bodyValue(root).retrieve()
                .onStatus(s -> s.isError(), r -> r.bodyToMono(String.class).flatMap(errorBody -> {
                    log.error("[BankAPI][inquireDemandDepositAccountList] error body = \n{}", errorBody);
                    try {
                        ResponseEnvelope<?> errorResp = objectMapper.readValue(errorBody,
                            objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class));
                        return Mono.error(new BankApiException(errorResp));
                    } catch (Exception parseEx) {
                        return Mono.error(new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                    }
                }))
                .bodyToMono(new ParameterizedTypeReference<ResponseEnvelope<List<DemandDepositAccountItem>>>() {})
                .block();
            log.info("[BankAPI][inquireDemandDepositAccountList] parsed response = {}", resp);
            return resp;
        } catch (Exception e) {
            log.error("[BankAPI][inquireDemandDepositAccountList] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    @Override
    public ResponseEnvelope<DemandDepositAccountDepositRec> updateDemandDepositAccountDeposit(
        String accountNo, String transactionBalance, String transactionSummary, String userUuid) {
        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("updateDemandDepositAccountDeposit", apiKey, ssafyUserKey);
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.put("accountNo", accountNo);
        root.put("transactionBalance", transactionBalance);
        root.put("transactionSummary", transactionSummary);
        try {
            log.info("[BankAPI][updateDemandDepositAccountDeposit] request JSON = \n{}", objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            ResponseEnvelope<DemandDepositAccountDepositRec> resp = bankWebClient.post()
                .uri(baseUrl + accountDepositPath)
                .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                .bodyValue(root).retrieve()
                .onStatus(s -> s.isError(), r -> r.bodyToMono(String.class).flatMap(errorBody -> {
                    log.error("[BankAPI][updateDemandDepositAccountDeposit] error body = \n{}", errorBody);
                    try {
                        ResponseEnvelope<?> errorResp = objectMapper.readValue(errorBody,
                            objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class));
                        return Mono.error(new BankApiException(errorResp));
                    } catch (Exception parseEx) {
                        return Mono.error(new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                    }
                }))
                .bodyToMono(new ParameterizedTypeReference<ResponseEnvelope<DemandDepositAccountDepositRec>>() {})
                .block();
            log.info("[BankAPI][updateDemandDepositAccountDeposit] parsed response = {}", resp);
            return resp;
        } catch (Exception e) {
            log.error("[BankAPI][updateDemandDepositAccountDeposit] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    @Override
    public ResponseEnvelope<DemandDepositAccountWithdrawalRec> updateDemandDepositAccountWithdrawal(
        String accountNo, String transactionBalance, String transactionSummary, String userUuid) {
        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("updateDemandDepositAccountWithdrawal", apiKey, ssafyUserKey);
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.put("accountNo", accountNo);
        root.put("transactionBalance", transactionBalance);
        root.put("transactionSummary", transactionSummary);
        try {
            log.info("[BankAPI][updateDemandDepositAccountWithdrawal] request JSON = \n{}", objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            ResponseEnvelope<DemandDepositAccountWithdrawalRec> resp = bankWebClient.post()
                .uri(baseUrl + accountWithdrawalPath)
                .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                .bodyValue(root).retrieve()
                .onStatus(s -> s.isError(), r -> r.bodyToMono(String.class).flatMap(errorBody -> {
                    log.error("[BankAPI][updateDemandDepositAccountWithdrawal] error body = \n{}", errorBody);
                    try {
                        ResponseEnvelope<?> errorResp = objectMapper.readValue(errorBody,
                            objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class));
                        return Mono.error(new BankApiException(errorResp));
                    } catch (Exception parseEx) {
                        return Mono.error(new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                    }
                }))
                .bodyToMono(new ParameterizedTypeReference<ResponseEnvelope<DemandDepositAccountWithdrawalRec>>() {})
                .block();
            log.info("[BankAPI][updateDemandDepositAccountWithdrawal] parsed response = {}", resp);
            return resp;
        } catch (Exception e) {
            log.error("[BankAPI][updateDemandDepositAccountWithdrawal] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    @Override
    public ResponseEnvelope<List<DemandDepositAccountTransferItem>> updateDemandDepositAccountTransfer(
        String depositAccountNo, String depositTransactionSummary, String transactionBalance,
        String withdrawalAccountNo, String withdrawalTransactionSummary, String userUuid) {
        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("updateDemandDepositAccountTransfer", apiKey, ssafyUserKey);
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.put("depositAccountNo", depositAccountNo);
        root.put("depositTransactionSummary", depositTransactionSummary);
        root.put("transactionBalance", transactionBalance);
        root.put("withdrawalAccountNo", withdrawalAccountNo);
        root.put("withdrawalTransactionSummary", withdrawalTransactionSummary);
        try {
            log.info("[BankAPI][updateDemandDepositAccountTransfer] request JSON = \n{}", objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            ResponseEnvelope<List<DemandDepositAccountTransferItem>> resp = bankWebClient.post()
                .uri(baseUrl + accountTransferPath)
                .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                .bodyValue(root).retrieve()
                .onStatus(s -> s.isError(), r -> r.bodyToMono(String.class).flatMap(errorBody -> {
                    log.error("[BankAPI][updateDemandDepositAccountTransfer] error body = \n{}", errorBody);
                    try {
                        ResponseEnvelope<?> errorResp = objectMapper.readValue(errorBody,
                            objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class));
                        return Mono.error(new BankApiException(errorResp));
                    } catch (Exception parseEx) {
                        return Mono.error(new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                    }
                }))
                .bodyToMono(new ParameterizedTypeReference<ResponseEnvelope<List<DemandDepositAccountTransferItem>>>() {})
                .block();
            log.info("[BankAPI][updateDemandDepositAccountTransfer] parsed response = {}", resp);
            return resp;
        } catch (Exception e) {
            log.error("[BankAPI][updateDemandDepositAccountTransfer] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    @Override
    public ResponseEnvelope<TransactionHistoryRec> inquireTransactionHistoryList(
        String accountNo, String startDate, String endDate, String transactionType, String orderByType, String userUuid) {
        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("inquireTransactionHistoryList", apiKey, ssafyUserKey);
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.put("accountNo", accountNo);
        root.put("startDate", startDate);
        root.put("endDate", endDate);
        root.put("transactionType", transactionType);
        root.put("orderByType", orderByType);
        try {
            log.info("[BankAPI][inquireTransactionHistoryList] request JSON = \n{}", objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            ResponseEnvelope<TransactionHistoryRec> resp = bankWebClient.post()
                .uri(baseUrl + txListPath)
                .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                .bodyValue(root).retrieve()
                .onStatus(s -> s.isError(), r -> r.bodyToMono(String.class).flatMap(errorBody -> {
                    log.error("[BankAPI][inquireTransactionHistoryList] error body = \n{}", errorBody);
                    try {
                        ResponseEnvelope<?> errorResp = objectMapper.readValue(errorBody,
                            objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class));
                        return Mono.error(new BankApiException(errorResp));
                    } catch (Exception parseEx) {
                        return Mono.error(new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                    }
                }))
                .bodyToMono(new ParameterizedTypeReference<ResponseEnvelope<TransactionHistoryRec>>() {})
                .block();
            log.info("[BankAPI][inquireTransactionHistoryList] parsed response = {}", resp);
            return resp;
        } catch (Exception e) {
            log.error("[BankAPI][inquireTransactionHistoryList] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    @Override
    public ResponseEnvelope<TransactionHistoryItem> inquireTransactionHistory(
        String accountNo, String transactionUniqueNo, String userUuid) {
        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("inquireTransactionHistory", apiKey, ssafyUserKey);
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.put("accountNo", accountNo);
        root.put("transactionUniqueNo", transactionUniqueNo);
        try {
            log.info("[BankAPI][inquireTransactionHistory] request JSON = \n{}", objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            ResponseEnvelope<TransactionHistoryItem> resp = bankWebClient.post()
                .uri(baseUrl + txSinglePath)
                .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                .bodyValue(root).retrieve()
                .onStatus(s -> s.isError(), r -> r.bodyToMono(String.class).flatMap(errorBody -> {
                    log.error("[BankAPI][inquireTransactionHistory] error body = \n{}", errorBody);
                    try {
                        ResponseEnvelope<?> errorResp = objectMapper.readValue(errorBody,
                            objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class));
                        return Mono.error(new BankApiException(errorResp));
                    } catch (Exception parseEx) {
                        return Mono.error(new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                    }
                }))
                .bodyToMono(new ParameterizedTypeReference<ResponseEnvelope<TransactionHistoryItem>>() {})
                .block();
            log.info("[BankAPI][inquireTransactionHistory] parsed response = {}", resp);
            return resp;
        } catch (Exception e) {
            log.error("[BankAPI][inquireTransactionHistory] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    @Override
    public ResponseEnvelope<DemandDepositAccountDeleteRec> deleteDemandDepositAccount(String accountNo, String refundAccountNo, String userUuid) {
        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("deleteDemandDepositAccount", apiKey, ssafyUserKey);
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.put("accountNo", accountNo);
        root.put("refundAccountNo", refundAccountNo);
        try {
            log.info("[BankAPI][deleteDemandDepositAccount] request JSON = \n{}", objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            ResponseEnvelope<DemandDepositAccountDeleteRec> resp = bankWebClient.post()
                .uri(baseUrl + accountDeletePath)
                .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                .bodyValue(root).retrieve()
                .onStatus(s -> s.isError(), r -> r.bodyToMono(String.class).flatMap(errorBody -> {
                    log.error("[BankAPI][deleteDemandDepositAccount] error body = \n{}", errorBody);
                    try {
                        ResponseEnvelope<?> errorResp = objectMapper.readValue(errorBody,
                            objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class));
                        return Mono.error(new BankApiException(errorResp));
                    } catch (Exception parseEx) {
                        return Mono.error(new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                    }
                }))
                .bodyToMono(new ParameterizedTypeReference<ResponseEnvelope<DemandDepositAccountDeleteRec>>() {})
                .block();
            log.info("[BankAPI][deleteDemandDepositAccount] parsed response = {}", resp);
            return resp;
        } catch (Exception e) {
            log.error("[BankAPI][deleteDemandDepositAccount] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    // ===== userKey 필요 없는 메서드들 =====
    @Override
    public ResponseEnvelope<List<CreateDemandDepositRec>> inquireDemandDepositList() {
        RequestHeader header = HeaderFactory.of("inquireDemandDepositList", apiKey);
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        try {
            log.info("[BankAPI][inquireDemandDepositList] request JSON = \n{}", objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            ResponseEnvelope<List<CreateDemandDepositRec>> resp = bankWebClient.post()
                .uri(baseUrl + listPath)
                .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                .bodyValue(root).retrieve()
                .onStatus(s -> s.isError(), r -> r.bodyToMono(String.class).flatMap(errorBody -> {
                    log.error("[BankAPI][inquireDemandDepositList] error body = \n{}", errorBody);
                    try {
                        ResponseEnvelope<?> errorResp = objectMapper.readValue(errorBody,
                            objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class));
                        return Mono.error(new BankApiException(errorResp));
                    } catch (Exception parseEx) {
                        return Mono.error(new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                    }
                }))
                .bodyToMono(new ParameterizedTypeReference<ResponseEnvelope<List<CreateDemandDepositRec>>>() {})
                .block();
            log.info("[BankAPI][inquireDemandDepositList] parsed response = {}", resp);
            return resp;
        } catch (Exception e) {
            log.error("[BankAPI][inquireDemandDepositList] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    @Override
    public ResponseEnvelope<CreateDemandDepositRec> createDemandDeposit(String bankCode, String accountName, String accountDescription) {
        RequestHeader header = HeaderFactory.of("createDemandDeposit", apiKey);
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.put("bankCode", bankCode);
        root.put("accountName", accountName);
        root.put("accountDescription", accountDescription);
        try {
            log.info("[BankAPI][createDemandDeposit] request JSON = \n{}", objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            String raw = bankWebClient.post()
                .uri(baseUrl + createDepositPath)
                .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                .bodyValue(root).retrieve()
                .onStatus(s -> s.isError(), r -> r.bodyToMono(String.class).flatMap(errorBody -> {
                    log.error("[BankAPI][createDemandDeposit] error body = \n{}", errorBody);
                    try {
                        ResponseEnvelope<?> errorResp = objectMapper.readValue(errorBody,
                            objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class));
                        return Mono.error(new BankApiException(errorResp));
                    } catch (Exception parseEx) {
                        return Mono.error(new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                    }
                }))
                .bodyToMono(String.class).block();
            log.info("[BankAPI][createDemandDeposit] raw response = \n{}", raw);
            ResponseEnvelope<CreateDemandDepositRec> resp = objectMapper.readValue(
                raw,
                objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, CreateDemandDepositRec.class)
            );
            log.info("[BankAPI][createDemandDeposit] parsed response = {}", resp);
            return resp;
        } catch (Exception e) {
            log.error("[BankAPI][createDemandDeposit] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    @Override
    public ResponseEnvelope<CreateDemandDepositAccountRec> createDemandDepositAccount(String accountTypeUniqueNo, String userUuid) {
        String ssafyUserKey = getSsafyUserKeyOrThrow(userUuid);
        RequestHeader header = HeaderFactory.of("createDemandDepositAccount", apiKey, ssafyUserKey);
        var body = new CreateDemandDepositAccountBody();
        body.setAccountTypeUniqueNo(accountTypeUniqueNo);
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.setAll((ObjectNode) objectMapper.valueToTree(body));
        try {
            log.info("[BankAPI][createDemandDepositAccount] request JSON = \n{}", objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
            String raw = bankWebClient.post()
                .uri(baseUrl + createPath)
                .contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON)
                .bodyValue(root).retrieve()
                .onStatus(s -> s.isError(), r -> r.bodyToMono(String.class).flatMap(errorBody -> {
                    log.error("[BankAPI][createDemandDepositAccount] error body = \n{}", errorBody);
                    try {
                        ResponseEnvelope<?> errorResp = objectMapper.readValue(errorBody,
                            objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, Object.class));
                        return Mono.error(new BankApiException(errorResp));
                    } catch (Exception parseEx) {
                        return Mono.error(new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                    }
                }))
                .bodyToMono(String.class).block();
            log.info("[BankAPI][createDemandDepositAccount] raw response = \n{}", raw);
            ResponseEnvelope<CreateDemandDepositAccountRec> resp = objectMapper.readValue(
                raw,
                objectMapper.getTypeFactory().constructParametricType(ResponseEnvelope.class, CreateDemandDepositAccountRec.class)
            );
            log.info("[BankAPI][createDemandDepositAccount] parsed response = {}", resp);
            return resp;
        } catch (Exception e) {
            log.error("[BankAPI][createDemandDepositAccount] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }
}
