package com.e106.kdkd.ssafy.dto.card;

import lombok.Data;

@Data
public class InquireCreditCardTransactionListRequest {
    private String cardNo;
    private String cvc;
    private String startDate;
    private String endDate;
}
