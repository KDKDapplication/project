package com.e106.kdkd.bank.service;

import com.e106.kdkd.bank.dto.*;

public interface BankAccountService {

    AccountCreateResponse createAccount(AccountCreateRequest request);

    CardIssueResponse issueCreditCardByAccountNumber(String accountNumber, String userUuid);

    void delete(String userUuid, AccountDeleteRequest request);

    AccountInquiryResponse inquireMyAccount(String userUuid);

    BalanceWithOffsetsResponse inquireDemandDepositAccountBalanceWithOffsets(String accountNo, String userUuid);

}
