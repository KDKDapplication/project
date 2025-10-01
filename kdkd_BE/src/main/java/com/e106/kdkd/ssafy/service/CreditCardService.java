package com.e106.kdkd.ssafy.service;

import com.e106.kdkd.ssafy.dto.CardIssuerCodeItem;
import com.e106.kdkd.ssafy.dto.ResponseEnvelope;
import com.e106.kdkd.ssafy.dto.card.*;

import java.util.List;

public interface CreditCardService {

    ResponseEnvelope<List<CardIssuerCodeItem>> inquireCardIssuerCodesList();

    ResponseEnvelope<CreateCreditCardProductRec> createCreditCardProduct(
        CreateCreditCardProductRequest request);

    ResponseEnvelope<List<CreateCreditCardProductRec>> inquireCreditCardList(); // userKey 불필요

    ResponseEnvelope<CreateCreditCardRec> createCreditCard(CreateCreditCardRequest request, String userUuid);

    ResponseEnvelope<List<SignUpCreditCardRec>> inquireSignUpCreditCardList(String userUuid);

    ResponseEnvelope<InquireCreditCardTransactionListRec> inquireCreditCardTransactionList(
            InquireCreditCardTransactionListRequest request, String userUuid);
}
