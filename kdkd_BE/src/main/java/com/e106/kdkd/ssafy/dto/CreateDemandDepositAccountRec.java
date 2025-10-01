package com.e106.kdkd.ssafy.dto;

import lombok.Data;

@Data
public class CreateDemandDepositAccountRec {
    private String bankCode;
    private String accountNo;
    private CurrencyInfo currency;
}
