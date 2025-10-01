package com.e106.kdkd.ssafy.service.backend;

import com.e106.kdkd.ssafy.dto.card.CreateCreditCardTransactionRec;

public interface ApiCardService {

    CreateCreditCardTransactionRec createCreditCardTransaction(String userKey,
        String cardNo, String cvc, String merchantId, String paymentBanlance);

}
