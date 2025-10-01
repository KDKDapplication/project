package com.e106.kdkd.ssafy.service;

import com.e106.kdkd.ssafy.dto.BankCodeItem;
import com.e106.kdkd.ssafy.dto.RequestEnvelope;
import com.e106.kdkd.ssafy.dto.RequestHeader;
import com.e106.kdkd.ssafy.dto.ResponseEnvelope;
import com.e106.kdkd.ssafy.util.HeaderFactory;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BankCodeServiceImpl implements BankCodeService {

    private final WebClient webClient;

    @Value("${SSAFY_API_BASE}")
    private String base;

    @Value("${SSAFY_API_KEY}")
    private String apiKey;

    @Value("${SSAFY_API_PATH_BANK_CODES}")
    private String pathBankCodes;

    @Override
    public ResponseEnvelope<List<BankCodeItem>> inquireBankCodes() {
        String apiName = "inquireBankCodes";

        RequestHeader header = HeaderFactory.of(apiName, apiKey);
        RequestEnvelope<Void> payload = new RequestEnvelope<>(header, null);

        return webClient.post()
                .uri(base + pathBankCodes)
                .bodyValue(payload)
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<ResponseEnvelope<List<BankCodeItem>>>() {})
                .block();
    }
}
