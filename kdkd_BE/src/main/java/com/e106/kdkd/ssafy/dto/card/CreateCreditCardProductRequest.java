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
public class CreateCreditCardProductRequest {

    private String cardIssuerCode;
    private String cardName;
    private String baselinePerformance;
    private String maxBenefitLimit;
    private String cardDescription;
    private List<CardBenefitItem> cardBenefits;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CardBenefitItem {

        private String categoryId;
        private String discountRate;
    }
}
