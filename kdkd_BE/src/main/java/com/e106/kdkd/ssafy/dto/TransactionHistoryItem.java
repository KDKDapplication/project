package com.e106.kdkd.ssafy.dto;

import lombok.Data;

@Data
public class TransactionHistoryItem {
    private String transactionUniqueNo;
    private String transactionDate;         // yyyymmdd
    private String transactionTime;         // HHmmss
    private String transactionType;         // "1" 입금 / "2" 출금 ...
    private String transactionTypeName;     // 입금/출금(이체) 등
    private String transactionAccountNo;    // 상대계좌 (없을 수 있음)
    private String transactionBalance;      // 이번 거래 금액
    private String transactionAfterBalance; // 거래 후 잔액
    private String transactionSummary;      // 요약
    private String transactionMemo;         // 메모 (빈 문자열 가능)
}
