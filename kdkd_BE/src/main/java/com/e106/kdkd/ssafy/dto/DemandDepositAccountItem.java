package com.e106.kdkd.ssafy.dto;

import lombok.Data;

@Data
public class DemandDepositAccountItem {
    private String bankCode;
    private String bankName;
    private String userName;
    private String accountNo;
    private String accountName;
    private String accountTypeCode;
    private String accountTypeName;
    private String accountCreatedDate;
    private String accountExpiryDate;
    private String dailyTransferLimit;
    private String oneTimeTransferLimit;
    private String accountBalance;
    private String lastTransactionDate; // 빈 문자열 올 수 있음
    private String currency;
}
