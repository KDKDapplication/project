package com.e106.kdkd.ssafy.dto;

import lombok.Data;

@Data
public class DemandDepositAccountTransferItem {
    private String transactionUniqueNo;   // "61"
    private String accountNo;             // 주체 계좌
    private String transactionDate;       // "20240401"
    private String transactionType;       // "1" 입금, "2" 출금
    private String transactionTypeName;   // "입금(이체)" / "출금(이체)"
    private String transactionAccountNo;  // 상대 계좌
}
