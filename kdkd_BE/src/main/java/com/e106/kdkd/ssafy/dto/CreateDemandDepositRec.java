package com.e106.kdkd.ssafy.dto;

import lombok.Data;

@Data
public class CreateDemandDepositRec {
    private String accountTypeUniqueNo;
    private String bankCode;
    private String bankName;
    private String accountTypeCode;     // "1"
    private String accountTypeName;     // "수시입출금"
    private String accountName;         // 상품명
    private String accountDescription;  // 상품설명
    private String accountType;         // "DOMESTIC"
}
