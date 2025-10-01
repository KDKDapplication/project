package com.e106.kdkd.ssafy.dto;

import lombok.Data;

@Data
public class DemandDepositAccountBalance {
    private String bankCode;
    private String accountNo;
    private String accountBalance;
    private String accountCreatedDate;
    private String accountExpiryDate;
    private String lastTransactionDate; // 빈 문자열 가능
    private String currency;
}
