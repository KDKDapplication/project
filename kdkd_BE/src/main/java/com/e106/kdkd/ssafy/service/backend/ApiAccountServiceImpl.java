package com.e106.kdkd.ssafy.service.backend;

import com.e106.kdkd.boxes.repository.SaveBoxRepository;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.SaveBox;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.common.enums.BoxStatus;
import com.e106.kdkd.global.common.enums.Role;
import com.e106.kdkd.global.exception.InsufficientFundsException;
import com.e106.kdkd.ssafy.dto.DemandDepositAccountBalance;
import com.e106.kdkd.ssafy.dto.DemandDepositAccountTransferItem;
import com.e106.kdkd.ssafy.dto.RequestHeader;
import com.e106.kdkd.ssafy.dto.ResponseEnvelope;
import com.e106.kdkd.ssafy.util.BankApiException;
import com.e106.kdkd.ssafy.util.HeaderFactory;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
@Slf4j
public class ApiAccountServiceImpl implements ApiAccountService {

    private final WebClient bankWebClient;
    private final ObjectMapper objectMapper;
    private final SaveBoxRepository saveBoxRepository;

    @Value("${SSAFY_DEMAND_DEPOSIT_ACCOUNT_BALANCE_PATH}")
    private String accountBalancePath;

    @Value("${SSAFY_API_KEY}")
    private String apiKey;

    @Value("${SSAFY_API_BASE}")
    private String baseUrl;

    @Value("${SSAFY_DEMAND_DEPOSIT_ACCOUNT_TRANSFER_PATH}")
    private String accountTransferPath;

    @Override
    public DemandDepositAccountBalance inquireDemandDepositAccountBalance(String userKey,
        String accountNo) {
        RequestHeader header = HeaderFactory.of("inquireDemandDepositAccountBalance", apiKey,
            userKey);

        // 2) 요청 JSON: Header + accountNo
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.put("accountNo", accountNo);

        try {
            log.info("[BankAPI][inquireDemandDepositAccountBalance] request JSON = \n{}",
                objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));

            ResponseEnvelope<DemandDepositAccountBalance> resp = bankWebClient.post()
                .uri(baseUrl + accountBalancePath)
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
                .bodyValue(root)
                .retrieve()
                .onStatus(s -> s.isError(), clientResponse ->
                    clientResponse.bodyToMono(String.class).flatMap(errorBody -> {
                        log.error("[BankAPI][inquireDemandDepositAccountBalance] error body = \n{}",
                            errorBody);
                        try {
                            ResponseEnvelope<?> errorResp = objectMapper.readValue(
                                errorBody,
                                objectMapper.getTypeFactory()
                                    .constructParametricType(ResponseEnvelope.class, Object.class)
                            );
                            return Mono.error(new BankApiException(errorResp));
                        } catch (Exception parseEx) {
                            return Mono.error(
                                new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                        }
                    })
                )
                .bodyToMono(
                    new ParameterizedTypeReference<ResponseEnvelope<DemandDepositAccountBalance>>() {
                    })
                .block();

            log.info("[BankAPI][inquireDemandDepositAccountBalance] parsed response = {}", resp);
            return Objects.requireNonNull(
                Objects.requireNonNull(resp, "response null(ssafyapi 응답이 null입니다.)").getREC(),
                "REC null"
            );

        } catch (Exception e) {
            log.error("[BankAPI][inquireDemandDepositAccountBalance] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    @Override
    public void updateDemandDepositAccountTransfer(
        String depositAccountNo, String depositTransactionSummary, String transactionBalance,
        String withdrawalAccountNo, String withdrawalTransactionSummary, String userKey
    ) {
        // 1) Header (userKey 포함)
        RequestHeader header = HeaderFactory.of("updateDemandDepositAccountTransfer", apiKey,
            userKey);

        // 2) 요청 JSON: Header + 필드들
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.put("depositAccountNo", depositAccountNo);
        root.put("depositTransactionSummary", depositTransactionSummary);
        root.put("transactionBalance", transactionBalance);
        root.put("withdrawalAccountNo", withdrawalAccountNo);
        root.put("withdrawalTransactionSummary", withdrawalTransactionSummary);

        try {
            log.info("[BankAPI][updateDemandDepositAccountTransfer] request JSON = \n{}",
                objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));

            ResponseEnvelope<List<DemandDepositAccountTransferItem>> resp = bankWebClient.post()
                .uri(baseUrl + accountTransferPath)
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
                .bodyValue(root)
                .retrieve()
                .onStatus(s -> s.isError(), clientResponse ->
                    clientResponse.bodyToMono(String.class).flatMap(errorBody -> {
                        log.error("[BankAPI][updateDemandDepositAccountTransfer] error body = \n{}",
                            errorBody);
                        try {
                            ResponseEnvelope<?> errorResp = objectMapper.readValue(
                                errorBody,
                                objectMapper.getTypeFactory()
                                    .constructParametricType(ResponseEnvelope.class, Object.class)
                            );
                            return Mono.error(new BankApiException(errorResp));
                        } catch (Exception parseEx) {
                            return Mono.error(
                                new RuntimeException("Bank API error, raw=" + errorBody, parseEx));
                        }
                    })
                )
                .bodyToMono(
                    new ParameterizedTypeReference<ResponseEnvelope<List<DemandDepositAccountTransferItem>>>() {
                    })
                .block();

            log.info("[BankAPI][updateDemandDepositAccountTransfer] parsed response = {}", resp);

        } catch (Exception e) {
            log.error("[BankAPI][updateDemandDepositAccountTransfer] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }

    @Override
    public void checkCanTransfer(String userKey, String accountNo, Long amount) {
        String ssafyRemain = inquireDemandDepositAccountBalance(userKey, accountNo)
            .getAccountBalance();
        Long actualRemain = subtractSafe(ssafyRemain, amount.toString());

        if (actualRemain < 0L) {
            throw new IllegalArgumentException("잔액이 부족하여 해당 금액을 결제 or 이체 할 수 없습니다.");
        }
    }

    @Override
    public void checkUserCanTransfer(User user, Account account, Long amount) {
        String ssafyRemain = inquireDemandDepositAccountBalance(
            user.getSsafyUserKey(), account.getAccountNumber()).getAccountBalance();

        Long actualRemain = subtractSafe(ssafyRemain, account.getTotalUsePayment().toString());
        if (user.getRole() == Role.CHILD) {
            List<SaveBox> saveBoxes = saveBoxRepository.findAllByChildren_UserUuidAndStatusOrderByCreatedAtDesc(
                user.getUserUuid(), BoxStatus.IN_PROGRESS);

            for (SaveBox box : saveBoxes) {
                actualRemain -= box.getRemain();
            }
        }
        if (actualRemain < amount) {
            throw new IllegalArgumentException("잔액이 부족하여 해당 금액을 결제 or 이체 할 수 없습니다.");
        }
    }


    @Override
    public void customChildAccountTransfer(Account withdrawalAccount, Account depositAccount,
        Long amount, User user, String depositTransactionSummary,
        String withdrawalTransactionSummary) {
        log.debug("이체 전 잔액 검증");
        checkUserCanTransfer(user, withdrawalAccount, amount);

        log.debug("계좌 이체");
        updateDemandDepositAccountTransfer(depositAccount.getAccountNumber()
            , depositTransactionSummary, amount.toString(), withdrawalAccount.getAccountNumber()
            , withdrawalTransactionSummary, user.getSsafyUserKey());
    }

    @Transactional
    @Override
    public void customAccountTransfer(Account withdrawalAccount,
        Account depositAccount, Long amount, String userKey,
        String depositTransactionSummary, String withdrawalTransactionSummary) {
        log.debug("계좌 잔액 조회");
        Long ssafyRemain = Long.valueOf(inquireDemandDepositAccountBalance(userKey,
            withdrawalAccount.getAccountNumber()).getAccountBalance());

        Long actualRemain = 0L;
        if (withdrawalAccount.getTotalUsePayment() == null) {
            actualRemain = ssafyRemain;
        } else {
            actualRemain = ssafyRemain - withdrawalAccount.getTotalUsePayment();
        }

        if (actualRemain < amount) {
            throw new InsufficientFundsException("잔액이 부족하여 이체할 수 없습니다.");
        }

        log.debug("계좌 이체");
        updateDemandDepositAccountTransfer(depositAccount.getAccountNumber()
            , depositTransactionSummary, amount.toString(), withdrawalAccount.getAccountNumber()
            , withdrawalTransactionSummary, userKey);

    }

    // 문자열 타입 long 숫자 뺴기
    public static Long subtractSafe(String x, String y) {
        if (x == null || y == null) {
            throw new IllegalArgumentException("null 불가");
        }
        try {
            long a = Long.parseLong(x.trim());
            long b = Long.parseLong(y.trim());
            return Math.subtractExact(a, b); // long → Long 오토박싱
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("숫자 형식 아님: x=" + x + ", y=" + y, e);
        }
    }


}
