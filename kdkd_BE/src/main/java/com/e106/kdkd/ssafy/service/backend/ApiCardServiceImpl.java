package com.e106.kdkd.ssafy.service.backend;

import com.e106.kdkd.ssafy.dto.RequestHeader;
import com.e106.kdkd.ssafy.dto.ResponseEnvelope;
import com.e106.kdkd.ssafy.dto.card.CreateCreditCardTransactionRec;
import com.e106.kdkd.ssafy.util.BankApiException;
import com.e106.kdkd.ssafy.util.HeaderFactory;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
@Slf4j
public class ApiCardServiceImpl implements ApiCardService {

    private final WebClient cardWebClient;
    private final ObjectMapper objectMapper;

    @Value("${SSAFY_API_KEY}")
    private String apiKey;

    @Value("${SSAFY_API_BASE}")
    private String baseUrl;

    @Value("${SSAFY_CREDIT_CARD_CREATE_TRANSACTION_PATH}")
    private String creditCardCreateTransactionPath;

    @Override
    public CreateCreditCardTransactionRec createCreditCardTransaction(String userKey, String cardNo,
        String cvc,
        String merchantId, String paymentBanlance) {
        RequestHeader header = HeaderFactory.of("createCreditCardTransaction", apiKey,
            userKey);

        // 2) 요청 JSON: Header + accountNo
        var root = objectMapper.createObjectNode();
        root.set("Header", objectMapper.valueToTree(header));
        root.put("cardNo", cardNo);
        root.put("cvc", cvc);
        root.put("merchantId", merchantId);
        root.put("paymentBalance", paymentBanlance);

        try {
            log.info("[CardAPI][createCreditCardTransaction] request JSON = \n{}",
                objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));

            ResponseEnvelope<CreateCreditCardTransactionRec> resp = cardWebClient.post()
                .uri(baseUrl + creditCardCreateTransactionPath)
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
                .bodyValue(root)
                .retrieve()
                .onStatus(s -> s.isError(), clientResponse ->
                    clientResponse.bodyToMono(String.class).flatMap(errorBody -> {
                        log.error("[CardAPI][createCreditCardTransaction] error body = \n{}",
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
                    new ParameterizedTypeReference<ResponseEnvelope<CreateCreditCardTransactionRec>>() {
                    })
                .block();

            log.info("[CardAPI][createCreditCardTransaction] parsed response = {}", resp);
            return Objects.requireNonNull(
                Objects.requireNonNull(resp, "response null(ssafyapi 응답이 null입니다.)").getREC(),
                "REC null"
            );

        } catch (Exception e) {
            log.error("[BankAPI][inquireDemandDepositAccountBalance] error", e);
            throw new RuntimeException("Bank API call failed", e);
        }
    }
}
