package com.e106.kdkd.ssafy.dto.accountauth;

import lombok.Data;

@Data
public class CheckAuthCodeRec {

    private String status;               // SUCCESS / FAIL 등
    private String transactionUniqueNo;  // (참고용)
    private String accountNo;            // (참고용)
}
