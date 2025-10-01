package com.e106.kdkd.ssafy.dto.card;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateCreditCardProductRec {

    private String cardUniqueNo;
    private String cardIssuerCode;
    private String cardIssuerName;
    private String cardName;
    private String cardTypeCode;
    private String cardTypeName;
    private String baselinePerformance;
    private String maxBenefitLimit;
    private String cardDescription;
    private List<CardBenefitInfo> cardBenefitsInfo;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CardBenefitInfo {

        private String categoryId;
        private String categoryName;
        private String discountRate;
    }
}
