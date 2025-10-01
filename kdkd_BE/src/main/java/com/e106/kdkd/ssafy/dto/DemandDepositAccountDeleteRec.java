package com.e106.kdkd.ssafy.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class DemandDepositAccountDeleteRec {
    private String status;          // "CLOSED"
    private String accountNo;
    private String refundAccountNo;
    @Schema(description = "해지시 잔액이 없으면 null입력/잔액이 있으면 받을 계좌 입력")
    private String accountBalance;
}
