package com.e106.kdkd.ssafy.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Data;

@Data
@Builder(toBuilder = true)   // toBuilder() 가능
@JsonInclude(JsonInclude.Include.NON_NULL) // null 필드 제외
public class RequestHeader {
    private String apiName;
    private String transmissionDate;
    private String transmissionTime;
    private String institutionCode;
    private String fintechAppNo;
    private String apiServiceCode;
    private String institutionTransactionUniqueNo;
    private String apiKey;
    private String userKey; // 선택
}
