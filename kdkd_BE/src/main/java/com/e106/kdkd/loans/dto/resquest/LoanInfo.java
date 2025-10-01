package com.e106.kdkd.loans.dto.resquest;

import com.e106.kdkd.global.common.entity.Loan;
import com.e106.kdkd.global.common.enums.LoanStatus;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class LoanInfo {

    LoanStatus loanStatus;
    String loanUuid;
    Long loanAmount;
    Integer loanInterest;
    String loanContent;
    LocalDateTime createdAt;
    LocalDate loanDue;
//    String signImageUrl;


    LocalDate loanDate;
    Long currentInterestAmount;

    public void applyLoanInfo(Loan loan) {
        this.loanUuid = loan.getLoanUuid();
        this.loanAmount = loan.getLoanAmount();
        this.loanInterest = loan.getLoanInterest();
        this.loanContent = loan.getLoanContent();
        this.createdAt = loan.getCreatedAt();
        this.loanDue = loan.getLoanDue();
        this.loanDate = loan.getLoanDate();
    }
}
