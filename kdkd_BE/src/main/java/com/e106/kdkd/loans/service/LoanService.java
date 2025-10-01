package com.e106.kdkd.loans.service;

import com.e106.kdkd.loans.dto.response.RequestLoanInfo;
import com.e106.kdkd.loans.dto.resquest.LoanInfo;

public interface LoanService {

    void createLoan(String childUuid, RequestLoanInfo requestLoanInfo);

    void payBackLoan(String childUuid, String loanUuid);

    LoanInfo queryLoan(String childUuid);

    void acceptLoan(String parentUuid, String loanUuid);

    void rejectLoan(String parentUuid, String loanUuid);

    void deleteLoan(String parentUuid, String loanUuid);
}
