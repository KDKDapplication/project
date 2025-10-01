package com.e106.kdkd.loans.dto.response;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RequestLoanInfo {

    @NotNull(message = "loanAmount는 필수입니다.")
    @Positive(message = "loanAmount는 0보다 커야 합니다.")
    private Long loanAmount;

    @NotNull(message = "loanDue는 필수입니다.")
    @Future(message = "loanDue는 오늘 이후 날짜여야 합니다.")
    private LocalDate loanDue;

    @NotNull(message = "loanInterest는 필수입니다.")
    @PositiveOrZero(message = "loanInterest는 0 이상이어야 합니다.")
    private Integer loanInterest;

    @Size(max = 1000, message = "loanContent는 최대 1000자입니다.")
    private String loanContent;
}
