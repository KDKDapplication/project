package com.e106.kdkd.ssafy.service;

import com.e106.kdkd.ssafy.dto.*;
import com.e106.kdkd.ssafy.dto.accountauth.OpenAccountAuthRec;
import java.util.List;

public interface BankService {

    ResponseEnvelope<CreateDemandDepositAccountRec> createDemandDepositAccount(
        String accountTypeUniqueNo, String userUuid);

    ResponseEnvelope<CreateDemandDepositRec> createDemandDeposit(
        String bankCode, String accountName, String accountDescription);

    ResponseEnvelope<List<CreateDemandDepositRec>> inquireDemandDepositList();

    ResponseEnvelope<List<DemandDepositAccountItem>> inquireDemandDepositAccountList(String userUuid);

    ResponseEnvelope<DemandDepositAccountHolder> inquireDemandDepositAccountHolderName(
        String accountNo, String userUuid);

    ResponseEnvelope<DemandDepositAccountBalance> inquireDemandDepositAccountBalance(
        String accountNo, String userUuid);

    ResponseEnvelope<DemandDepositAccountDepositRec> updateDemandDepositAccountDeposit(
        String accountNo, String transactionBalance, String transactionSummary, String userUuid);

    ResponseEnvelope<DemandDepositAccountWithdrawalRec> updateDemandDepositAccountWithdrawal(
        String accountNo, String transactionBalance, String transactionSummary, String userUuid);

    ResponseEnvelope<List<DemandDepositAccountTransferItem>> updateDemandDepositAccountTransfer(
        String depositAccountNo,
        String depositTransactionSummary,
        String transactionBalance,
        String withdrawalAccountNo,
        String withdrawalTransactionSummary,
        String userUuid
    );

    ResponseEnvelope<TransactionHistoryRec> inquireTransactionHistoryList(
        String accountNo, String startDate, String endDate, String transactionType, String orderByType, String userUuid);

    ResponseEnvelope<TransactionHistoryItem> inquireTransactionHistory(
        String accountNo, String transactionUniqueNo, String userUuid);

    ResponseEnvelope<DemandDepositAccountDeleteRec> deleteDemandDepositAccount(
        String accountNo, String refundAccountNo, String userUuid);

    ResponseEnvelope<OpenAccountAuthRec> openAccountAuth(String accountNo, String userUuid);

    String checkAuthCode(String accountNo, String authCode, String userUuid);
}
