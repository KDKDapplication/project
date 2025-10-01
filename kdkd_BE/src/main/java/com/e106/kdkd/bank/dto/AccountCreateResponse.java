package com.e106.kdkd.bank.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class AccountCreateResponse {

    private Long accountSeq;
    private String userUuid;
    private String bankName;
    private Integer totalUsePayment; // 항상 0으로 초기화
}
