// 응답 DTO
package com.e106.kdkd.ssafy.dto.card;

import java.util.List;
import lombok.Data;

@Data
public class InquireCreditCardTransactionListRec {
    private String cardIssuerCode;
    private String cardIssuerName;
    private String cardName;
    private String cardNo;
    private String estimatedBalance;
    private List<TransactionItem> transactionList;

    @Data
    public static class TransactionItem {
        private String transactionUniqueNo;
        private String categoryId;
        private String categoryName;
        private String merchantId;
        private String merchantName;
        private String transactionDate;
        private String transactionTime;
        private String transactionBalance;
        private String cardStatus;
        private String billStatementsYn;
        private String billStatementsStatus;
    }
}
