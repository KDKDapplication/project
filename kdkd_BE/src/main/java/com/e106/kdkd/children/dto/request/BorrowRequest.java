package com.e106.kdkd.children.dto.request;

import java.time.LocalDate;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class BorrowRequest {

    private Long loanAmount;

    private Double interestRate;

    private String loanContent;

    private LocalDate loanDate;

    private LocalDate loanDue;

    private String signatureImage;
}
