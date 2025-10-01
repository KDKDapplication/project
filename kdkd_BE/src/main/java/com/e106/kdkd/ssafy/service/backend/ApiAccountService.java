package com.e106.kdkd.ssafy.service.backend;

import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.ssafy.dto.DemandDepositAccountBalance;

public interface ApiAccountService {

    DemandDepositAccountBalance inquireDemandDepositAccountBalance(String userKety,
        String accountNo);


    void customAccountTransfer(Account withdrawalAccount, Account depositAccount, Long amount,
        String userKey, String depositTransactionSummary, String withdrawalTransactionSummary);

    void updateDemandDepositAccountTransfer(
        String depositAccountNo, String depositTransactionSummary, String transactionBalance,
        String withdrawalAccountNo, String withdrawalTransactionSummary, String userKey);

    void checkCanTransfer(String userKey, String accountNo, Long amount);

    void checkUserCanTransfer(User user, Account account, Long amount);

    void customChildAccountTransfer(Account withdrawalAccount, Account depositAccount, Long amount,
        User user, String depositTransactionSummary, String withdrawalTransactionSummary);


}
