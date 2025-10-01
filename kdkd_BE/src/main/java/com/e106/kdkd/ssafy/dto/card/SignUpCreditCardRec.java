package com.e106.kdkd.ssafy.dto.card;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SignUpCreditCardRec {

    private String cardNo;
    private String cvc;
    private String cardUniqueNo;
    private String cardIssuerCode;
    private String cardIssuerName;
    private String cardName;
    private String baselinePerformance;
    private String maxBenefitLimit;
    private String cardDescription;
    private String cardExpiryDate;
    private String withdrawalAccountNo;
    private String withdrawalDate;
}
